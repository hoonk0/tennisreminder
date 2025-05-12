import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;


class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static int _repeatAlarmId = 500;
  static bool _isRepeating = false;

  static init() async {
    await _notification.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        ));
    tz.initializeTimeZones();
  }

  ///알람 5초 후 울리기
  static scheduleNotification(
      String title,
      String body,
      int userDayInput,
      ) async {
    var androidDetails = const AndroidNotificationDetails(
      "important_notification",
      "My Channel",
      importance: Importance.max,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    try {
/*      if (Platform.isAndroid) {
        var intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      }*/
      await _notification.zonedSchedule(
        0,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(
          seconds: userDayInput,
        )),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (e) {
      print('⛔ 알림 스케줄 실패: ${e.code} - ${e.message}');
    }
  }

  ///알람즉시울리기
  static Future<void> showInstantNotification() async {
    var androidDetails = const AndroidNotificationDetails(
      "instant_channel",
      "즉시 알림 채널",
      channelDescription: "테스트 알림 채널",
      importance: Importance.max,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await _notification.show(
      999,
      '즉시 알림',
      '이건 바로 나와야 함',
      notificationDetails,
      payload: 'instant_test',
    );
  }

  /// 매일 특정시간에 울리는 알람
  static Future<void> scheduleDailyTenPmNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = const AndroidNotificationDetails(
      "daily_channel",
      "매일 알림 채널",
      channelDescription: "매일 10시에 알림 채널",
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    final targetTimeToday = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);
    final scheduledDate = targetTimeToday.isAfter(now)
        ? targetTimeToday
        : targetTimeToday.add(const Duration(days: 1));

    try {
      await _notification.zonedSchedule(
        1,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      print('⛔ 매일 알림 스케줄 실패: ${e.code} - ${e.message}');
    }
  }

  /// 1분 후 알람 재귀적으로 설정
  static Future<void> scheduleRepeatingAlarmManually({
    required String title,
    required String body,
  }) async {
    _isRepeating = true;
    final androidDetails = const AndroidNotificationDetails(
      "manual_repeat_channel",
      "수동 반복 알림 채널",
      channelDescription: "재귀 방식으로 반복 알림 설정",
      importance: Importance.max,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    try {
      await _notification.zonedSchedule(
        _repeatAlarmId,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('✅ 반복 알림 스케줄 성공: $scheduledTime');

      // 다음 알람 예약 (현재 알람이 울릴 시간이 지나면 다시 예약)
      Future.delayed(const Duration(seconds: 10), () async {
        if (_isRepeating) {
          await scheduleRepeatingAlarmManually(title: title, body: body);
        }
      });
    } on PlatformException catch (e) {
      print('⛔ 반복 알림 실패: ${e.code} - ${e.message}');
    }
  }

  /// 반복 알람 취소
  static Future<void> cancelRepeatingAlarm() async {
    _isRepeating = false;
    await _notification.cancel(_repeatAlarmId);
    print('🛑 반복 알람 취소됨');
  }

  static Future<void> scheduleDailyAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'daily_channel_id',
      '매일 알림',
      channelDescription: '매일 같은 시간에 보내는 알림',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notification.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간 반복
    );
  }

  cancelAllNotifications() {
    _notification.cancelAll();
  }
}