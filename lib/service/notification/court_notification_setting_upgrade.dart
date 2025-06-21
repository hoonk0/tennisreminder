import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

import '../../const/static/global.dart';

class CourtNotificationSettingUpgrade {
  static Future<void> saveAlarmToFirestoreExternal({
    required ModelCourt court,
    required DateTime selectedDateTime,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      throw Exception('FCM 토큰을 가져올 수 없습니다.');
    }

    final data = {
      keyCourtUid: court.uid,
      keyUserUid: FirebaseAuth.instance.currentUser?.uid ?? '',
      keyCourtName: court.courtName,
      keyAlarmDateTime: Timestamp.fromDate(selectedDateTime),
      keyAlarmEnabled: true,
      keyDateCreate: Timestamp.now(),
      keyFcmToken: fcmToken,
    };

    await FirebaseFirestore.instance.collection(keyCourtAlarms).add(data);

    final snapshot = await FirebaseFirestore.instance
        .collection(keyCourtAlarms)
        .where(keyUserUid, isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    Global.vnCourtAlarms.value = snapshot.docs
        .map((e) => ModelCourtAlarm.fromJson(e.data()))
        .toList();
  }
}

// FCM 토큰을 출력하는 디버그 함수
void printFcmToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print('📱 현재 기기의 FCM 토큰: $token');
}

void checkNotificationSetup() async {
  print('🔍 알림 설정 체크 시작');

  // 1. 알림 권한 요청
  final settings = await FirebaseMessaging.instance.requestPermission();
  print('🔔 알림 권한 상태: ${settings.authorizationStatus}');

  // 2. 포그라운드 메시지 수신 리스너
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📨 포그라운드 알림 수신: ${message.notification?.title ?? '제목 없음'}');
  });

  // 3. FCM 토큰 확인
  final token = await FirebaseMessaging.instance.getToken();
  print('📱 FCM 토큰: $token');

  // 4. Android 알림 채널 설정 확인 메시지
  print('📡 Android 알림 채널 설정은 main.dart 또는 알림 초기화 함수에서 확인 필요');
}

void setupFirebaseForegroundHandler() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 포그라운드 메시지 수신: ${message.notification?.title}');
    if (message.notification != null) {
      // 여기에 FlutterLocalNotificationsPlugin 등으로 알림 띄우는 코드 추가 가능
    }
  });
}