import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/service/notification/court_alarm_setting.dart';
import 'package:tennisreminder_app/service/notification/notification_helper.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

import '../../service/notification/notification_helper.dart';

class RouteCourtInformation extends StatefulWidget {
  final ModelCourt court;

  const RouteCourtInformation({required this.court, Key? key}) : super(key: key);

  @override
  State<RouteCourtInformation> createState() => _RouteCourtInformationState();
}

class _RouteCourtInformationState extends State<RouteCourtInformation> {
  TimeOfDay selectedTime = const TimeOfDay(hour: 22, minute: 0); // mutable for UI input
  int selectedWeekday = DateTime.sunday; // mutable for UI input

  Future<String?> getFcmToken() async {
    // TODO: Replace with your actual FCM token fetch logic
    return await FirebaseMessaging.instance.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),

                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.court.courtName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.court.courtAddress,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.court.courtInfo,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    if (widget.court.reservationUrl.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () {
                          // implement launch URL
                        },
                        icon: const Icon(Icons.link),
                        label: const Text('예약하러 가기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),



                    ///알람
                    const SizedBox(height: 24),
                    Text(
                      '알림 설정',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('매일 22:00에 알림을 받을 수 있습니다.'),
                      ],
                    ),
                    const SizedBox(height: 12),
    /*                /// 요일 선택
                    DropdownButtonFormField<int>(
                      value: selectedWeekday,
                      items: const [
                        DropdownMenuItem(value: DateTime.monday, child: Text('월요일')),
                        DropdownMenuItem(value: DateTime.tuesday, child: Text('화요일')),
                        DropdownMenuItem(value: DateTime.wednesday, child: Text('수요일')),
                        DropdownMenuItem(value: DateTime.thursday, child: Text('목요일')),
                        DropdownMenuItem(value: DateTime.friday, child: Text('금요일')),
                        DropdownMenuItem(value: DateTime.saturday, child: Text('토요일')),
                        DropdownMenuItem(value: DateTime.sunday, child: Text('일요일')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedWeekday = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: '알림 요일 선택'),
                    ),
                    const SizedBox(height: 12),

                    /// 시간 선택
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                      child: Text(
                        '알림 시간 선택: ${selectedTime.format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        final fcmToken = await getFcmToken();

                        if (user == null || fcmToken == null) return;

                        final alarm = ModelCourtAlarm(
                          courtUid: widget.court.uid,
                          userUid: user.uid,
                          fcmToken: fcmToken,
                          courtName: widget.court.courtName,
                          alarmWeekday: selectedWeekday,
                          alarmHour: selectedTime.hour,
                          alarmMinute: selectedTime.minute,
                          alarmEnabled: true,
                          dateCreate: Timestamp.now(),
                        );

                        await FirebaseFirestore.instance
                            .collection(keyCourtAlarms)
                            .add(alarm.toJson());

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('알림 설정이 저장되었습니다.')),
                        );
                      },
                      child: const Text('알림 신청하기'),
                    ),
*/
                    CourtAlarmSettings(),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
