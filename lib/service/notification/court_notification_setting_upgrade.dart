import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

import '../../const/static/global.dart';
import '../../ui/dialog/dialog_confirm.dart';


///특정일에 알람
class CourtNotificationFixedDayEachMonth {
  /// 🔔 FCM 토큰 출력
  static Future<void> printFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('📱 현재 기기의 FCM 토큰: $token');
  }

  /// 🔔 알람을 Firestore에 저장
  static Future<void> saveAlarmToFirestore({
    required BuildContext context,
    required ModelCourt court,
    required int reservationDay,
    required int reservationHour,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      throw Exception('FCM 토큰을 가져올 수 없습니다.');
    }

    final userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();

    for (int i = 0; i < 6; i++) {
      final targetDateTime = DateTime(now.year, now.month + i, reservationDay, reservationHour).subtract(const Duration(minutes: 10));
      final targetMonth = Timestamp.fromDate(targetDateTime);

      final querySnapshot = await FirebaseFirestore.instance
          .collection(keyCourtAlarms)
          .where(keyUserUid, isEqualTo: userUid)
          .where(keyCourtUid, isEqualTo: court.uid)
          .where(keyAlarmDateTime, isEqualTo: targetMonth)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
/*        showDialog(
          context: context,
          builder: (context) => const DialogConfirm(
            desc: '이미 알림이 설정되어 있습니다.',
          ),
        );*/
        continue;
      }

      final data = {
        keyCourtUid: court.uid,
        keyUserUid: userUid,
        keyCourtName: court.courtName,
        keyAlarmDateTime: targetMonth,
        keyAlarmEnabled: true,
        keyDateCreate: Timestamp.now(),
        keyFcmToken: fcmToken,
      };

      await FirebaseFirestore.instance.collection(keyCourtAlarms).add(data);

      final snapshot = await FirebaseFirestore.instance
          .collection(keyCourtAlarms)
          .where(keyUserUid, isEqualTo: userUid)
          .get();

      Global.vnCourtAlarms.value = snapshot.docs
          .map((e) => ModelCourtAlarm.fromJson(e.data()))
          .toList();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogConfirm(desc: '매달 ${reservationDay}일 ${reservationHour}시\n예약을 위한 알림이 등록되었습니다.'),
      );
    }
  }

  /// 🧠 알림 설정 확인 및 포그라운드 리스너 등록
  static Future<void> checkNotificationSetup() async {
    print('🔍 알림 설정 체크 시작');

    final settings = await FirebaseMessaging.instance.requestPermission();
    print('🔔 알림 권한 상태: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 포그라운드 알림 수신: ${message.notification?.title ?? '제목 없음'}');
    });

    final token = await FirebaseMessaging.instance.getToken();
    print('📱 FCM 토큰: $token');

    print('📡 Android 알림 채널 설정은 main.dart 또는 알림 초기화 함수에서 확인 필요');
  }

  /// 📡 포그라운드 핸들러만 따로 등록할 때
  static void setupFirebaseForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 포그라운드 메시지 수신: ${message.notification?.title}');
      // 여기서 FlutterLocalNotificationsPlugin 등으로 알림 띄우기 가능
    });
  }
}

///플레이 몇일전 알람
class CourtNotificationDaysBeforePlay {
  static Future<void> saveAlarmToFirestoreExternal({
    required ModelCourt court,
    required DateTime selectedDateTime,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      throw Exception('FCM 토큰을 가져올 수 없습니다.');
    }

    final userUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // 중복 알람 체크: 이미 같은 날짜, 같은 court_uid로 등록된 알람이 있는지 확인
    final querySnapshot = await FirebaseFirestore.instance
        .collection(keyCourtAlarms)
        .where(keyUserUid, isEqualTo: userUid)
        .where(keyCourtUid, isEqualTo: court.uid)
        .where(keyAlarmDateTime, isEqualTo: Timestamp.fromDate(selectedDateTime))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // 이미 같은 시간, 같은 코트의 알람이 있으면 저장 및 알람 설정을 하지 않음
      print('[SKIP] 이미 같은 시간에 알람이 존재함: $selectedDateTime');
      return;
    }

    final data = {
      keyCourtUid: court.uid,
      keyUserUid: userUid,
      keyCourtName: court.courtName,
      keyAlarmDateTime: Timestamp.fromDate(selectedDateTime),
      keyAlarmEnabled: true,
      keyDateCreate: Timestamp.now(),
      keyFcmToken: fcmToken,
    };

    await FirebaseFirestore.instance.collection(keyCourtAlarms).add(data);

    final snapshot = await FirebaseFirestore.instance
        .collection(keyCourtAlarms)
        .where(keyUserUid, isEqualTo: userUid)
        .get();

    Global.vnCourtAlarms.value = snapshot.docs
        .map((e) => ModelCourtAlarm.fromJson(e.data()))
        .toList();
  }
}


/// 매달 N번째 주의 특정 요일 알람
class CourtNotificationNthWeekdayOfMonth {
  /// 🔔 알람을 Firestore에 저장
  static Future<void> saveAlarmToFirestore({
    required BuildContext context,
    required ModelCourt court,
    required int reservationWeekNumber, // 예: 2번째 주
    required int reservationWeekday,    // 예: 월요일 = 1
    required int reservationHour,       // 예: 오전 9시
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      throw Exception('FCM 토큰을 가져올 수 없습니다.');
    }

    final userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();

    for (int i = 0; i < 6; i++) {
      final base = DateTime(now.year, now.month + i, 1);
      final int baseWeekday = base.weekday;

      // 첫 번째 reservationWeekday가 몇 번째 날인지 계산
      int offset = (reservationWeekday - baseWeekday + 7) % 7;
      int day = 1 + offset + (reservationWeekNumber - 1) * 7;

      if (day > DateTime(now.year, now.month + i + 1, 0).day) continue; // 유효하지 않은 날짜는 건너뜀

      final targetDate = DateTime(now.year, now.month + i, day, reservationHour).subtract(const Duration(minutes: 10));
      final targetTimestamp = Timestamp.fromDate(targetDate);

      final querySnapshot = await FirebaseFirestore.instance
          .collection(keyCourtAlarms)
          .where(keyUserUid, isEqualTo: userUid)
          .where(keyCourtUid, isEqualTo: court.uid)
          .where(keyAlarmDateTime, isEqualTo: targetTimestamp)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
/*        showDialog(
          context: context,
          builder: (context) => const DialogConfirm(
            desc: '이미 알림이 설정되어 있습니다.',
          ),
        );*/
        continue;
      }

      final data = {
        keyCourtUid: court.uid,
        keyUserUid: userUid,
        keyCourtName: court.courtName,
        keyAlarmDateTime: targetTimestamp,
        keyAlarmEnabled: true,
        keyDateCreate: Timestamp.now(),
        keyFcmToken: fcmToken,
      };

      await FirebaseFirestore.instance.collection(keyCourtAlarms).add(data);

      final snapshot = await FirebaseFirestore.instance
          .collection(keyCourtAlarms)
          .where(keyUserUid, isEqualTo: userUid)
          .get();

      Global.vnCourtAlarms.value = snapshot.docs
          .map((e) => ModelCourtAlarm.fromJson(e.data()))
          .toList();


    }
  }


}