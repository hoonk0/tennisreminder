import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tennisreminder_app/ui/component/basic_button_shadow.dart';
import 'package:tennisreminder_app/ui/dialog/dialog_confirm.dart';
import 'package:tennisreminder_app/ui/dialog/dialog_notification_confirm.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

import '../../service/notification/court_notification_setting_upgrade.dart';
import '../../service/utils/utils.dart';
import '../bottom_sheet/bottom_sheet_calendar.dart';
import '../dialog/dialog_confirm_reservation.dart';
import 'basic_button.dart';

class CourtReservationSection extends StatelessWidget {
  final ModelCourt court;

  const CourtReservationSection({required this.court});

  @override
  Widget build(BuildContext context) {
    final ruleType = court.reservationInfo?.reservationRuleType;

    switch (ruleType) {
      case ReservationRuleType.fixedDayEachMonth:
        return BasicButtonShadow(

          title: '알람 등록하기',
          onTap: () async {
            final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

            bool? isGranted;

            if (Platform.isAndroid) {
              isGranted = await flutterLocalNotificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      AndroidFlutterLocalNotificationsPlugin>()
                  ?.areNotificationsEnabled();
            } else if (Platform.isIOS) {
              final settings = await FirebaseMessaging.instance.getNotificationSettings();
              isGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
            }

            print('🟡 시스템 알림 권한 상태: ${isGranted == true ? 'ON' : 'OFF'}');

            // 예약일과 시간 정보가 있어야 함
            final reservationDay = court.reservationInfo?.reservationDay;
            final reservationHour = court.reservationInfo?.reservationHour;
            if (reservationDay != null && reservationHour != null) {
              await CourtNotificationFixedDayEachMonth.saveAlarmToFirestore(
                court: court,
                reservationDay: reservationDay,
                reservationHour: reservationHour, context: context,
              );


              if (isGranted == true) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => DialogConfirm(desc: '매달 ${reservationDay}일 ${reservationHour}시\n예약을 위한 알림이 등록되었습니다.'),
                );
              }


            } else {
              // 예약일 또는 시간이 없을 때 예외 처리 (예: 안내 메시지)
              print('예약일 또는 예약 시간이 없습니다.');
            }
          },
        );

      case ReservationRuleType.daysBeforePlay:
        return BasicButtonShadow(
          title: '플레이 일정 선택하기',
          onTap: () async {
              final vnSelectedDate = ValueNotifier<DateTime?>(DateTime.now());
            final int? hour = court.reservationInfo?.reservationHour;
            if (hour != null) {
              final now = DateTime.now();
              final scheduled = DateTime(now.year, now.month, now.day, hour);
              final alarmTime = scheduled.subtract(const Duration(minutes: 10));
              print('🕓 저장된 예약 시간: $scheduled');
              print('🔔 알람 예정 시간: $alarmTime');
            }

            BottomSheetCalendar(
              context,
              reservationHour: court.reservationInfo?.reservationHour?.toString() ?? '',
              court: court,
              vnSelectedDate: vnSelectedDate,
            );

    /*        showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => DialogConfirmReservation(
                desc: '플레이 0일전에\n예약 알림이 등록되었습니다.',
              ),
            );
*/
          },
        );
      case ReservationRuleType.nthWeekdayOfMonth:
        return BasicButtonShadow(
          title: '알람 등록하기',
          onTap: () async {
            final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

            bool? isGranted;

            if (Platform.isAndroid) {
              isGranted = await flutterLocalNotificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      AndroidFlutterLocalNotificationsPlugin>()
                  ?.areNotificationsEnabled();
            } else if (Platform.isIOS) {
              final settings = await FirebaseMessaging.instance.getNotificationSettings();
              isGranted = settings.authorizationStatus == AuthorizationStatus.authorized;
            }

            print('🟡 시스템 알림 권한 상태: ${isGranted == true ? 'ON' : 'OFF'}');

            final reservationWeekNumber = court.reservationInfo?.reservationWeekNumber;
            final reservationWeekday = court.reservationInfo?.reservationWeekday;
            final reservationHour = court.reservationInfo?.reservationHour;

            if (reservationWeekNumber != null && reservationWeekday != null && reservationHour != null) {
              await CourtNotificationNthWeekdayOfMonth.saveAlarmToFirestore(
                court: court,
                reservationWeekNumber: reservationWeekNumber,
                reservationWeekday: reservationWeekday,
                reservationHour: reservationHour,
                context: context,
              );


              if (isGranted == true) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => DialogConfirm(
                    desc: '매달 ${reservationWeekNumber}번째주 ${_weekdayToStr(reservationWeekday)}요일 ${reservationHour}시에\n예약 알림이 등록되었습니다.',
                  ),
                );
              }


            } else {
              print('n번째 주, 요일, 시간 중 누락된 정보가 있습니다.');
            }
          },
        );
      case ReservationRuleType.etc:
        return BasicButtonShadow(
          colorBg: colorGray400,
          showIcon: false,
          title: '알람 서비스 미제공 코트',
          onTap: () {

          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
  static String _weekNumber(int weekday) {
    const weekdays = ['첫', '둘', '셋', '넷', '다섯'];
    return weekdays[(weekday - 1) % 5];
  }
  static String _weekdayToStr(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[(weekday - 1) % 7];
  }
}