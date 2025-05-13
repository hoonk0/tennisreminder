import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/service/notification/court_alarm_setting.dart';
import 'package:tennisreminder_app/service/notification/notification_helper.dart';
import 'package:tennisreminder_app/ui/bottom_sheet/bottom_sheet_notification.dart';
import 'package:tennisreminder_app/ui/component/basic_button.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../service/notification/notification_helper.dart';

class RouteCourtInformation extends StatefulWidget {
  final ModelCourt court;

  const RouteCourtInformation({required this.court, Key? key})
    : super(key: key);

  @override
  State<RouteCourtInformation> createState() => _RouteCourtInformationState();
}

class _RouteCourtInformationState extends State<RouteCourtInformation> {
  TimeOfDay selectedTime = const TimeOfDay(
    hour: 22,
    minute: 0,
  ); // mutable for UI input
  int selectedWeekday = DateTime.sunday; // mutable for UI input

  final ValueNotifier<bool> vnAlarmSet = ValueNotifier(false);

  Future<String?> getFcmToken() async {
    // TODO: Replace with your actual FCM token fetch logic
    return await FirebaseMessaging.instance.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('코트 정보')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Image (temporary placeholder)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              widget.court.imageUrls != null &&
                                      widget.court.imageUrls!.isNotEmpty
                                  ? NetworkImage(widget.court.imageUrls!.first)
                                      as ImageProvider
                                  : const AssetImage(
                                    'assets/images/mainicon.png',
                                  ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Gaps.v20,
                    Text(
                      widget.court.courtName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v5,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.court.courtAddress,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    Gaps.v10,
                    const Text(
                      'Field Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Gaps.v10,
                    Text(
                      widget.court.courtInfo,
                      style: const TextStyle(color: Colors.black87),
                    ),

                    ///알람설정
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorGray100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorGray300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: vnAlarmSet,
                            builder: (
                              BuildContext context,
                              alarmSet,
                              Widget? child,
                            ) {
                              return Icon(
                                alarmSet
                                    ? Icons.notifications_active
                                    : Icons.notifications_none,
                                color: alarmSet ? colorMain900 : Colors.grey,
                              );
                            },
                          ),
                          Gaps.h12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '원하는 시간에 알림을 받을 수 있어요!',
                                  style: const TS.s16w600(colorGray900),
                                ),
                                Gaps.v5,
                                const Text(
                                  '매주 예약하고 싶은 요일과 시간을 설정하세요.',
                                  style: TS.s14w400(Colors.black87),
                                ),
                                Gaps.v10,
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: colorGray100,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                        builder: (context) {
                                          return BottomSheetNotification(
                                            court: widget.court,
                                            vnAlarmSet:vnAlarmSet,
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      '알림 설정하기 >',
                                      style: TS.s14w600(colorMain900),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gaps.v10,
                  ],
                ),
              ),
              Spacer(),
              BasicButton(title: '예약하러 가기', onTap: () {}),
              Gaps.v20,
            ],
          ),
        ),
      ),
    );
  }
}
