import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;


class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static init() async {
    await _notification.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        ));
    tz.initializeTimeZones();
  }

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
      // Prompt for exact alarm permission on Android
      if (Platform.isAndroid) {
        var intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      }
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

  cancelAllNotifications() {
    _notification.cancelAll();
  }
}