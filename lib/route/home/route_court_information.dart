import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/service/notification/court_alarm_setting.dart';
import 'package:tennisreminder_app/service/notification/notification_helper.dart';
import 'package:tennisreminder_app/ui/component/basic_button.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';

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
        title: const Text('코트 정보'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    image: widget.court.imageUrls != null && widget.court.imageUrls!.isNotEmpty
                        ? NetworkImage(widget.court.imageUrls!.first) as ImageProvider
                        : const AssetImage('assets/images/mainicon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Gaps.v16,
              Text(
                widget.court.courtName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v4,
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
              Gaps.v8,
              Gaps.v16,
              const Text(
                'Field Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Gaps.v8,
              Text(
                widget.court.courtInfo,
                style: const TextStyle(color: Colors.black87),
              ),
              Spacer(),
              BasicButton(
                title: '알림신청',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => const Padding(
                      padding: EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        top: 12,
                      ),
                      child: CourtAlarmSettings(),
                    ),
                  );
                },
              ),
              Gaps.v8,
              BasicButton(title: '예약하러 가기', onTap: (){}),
              Gaps.v20
            ],
          ),
        ),
      ),
    );
  }
}
