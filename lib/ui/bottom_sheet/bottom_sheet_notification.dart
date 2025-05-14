import 'package:flutter/material.dart';
import 'package:tennisreminder_app/service/notification/court_notification_setting.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

class BottomSheetNotification extends StatelessWidget {
  final ModelCourt court;
  final ValueNotifier<bool> vnAlarmSet;

  const BottomSheetNotification({
    super.key,
    required this.court,
    required this.vnAlarmSet,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gaps.v10,

            ///회색선
            Container(
              width: 40,
              height: 4,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: colorGray300,
              ),
            ),
            Gaps.v20,

            ///코트 사진
            Container(
              width: 90,
              height: 90,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: colorWhite,
              ),
              child: Center(
                child: (court.imageUrls?.isNotEmpty == true)
                    ? Image.network(
                        court.imageUrls!.first,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/mainicon.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Gaps.v20,

            ///코트정보
            Text(
              court.courtName,
              style: const TS.s18w600(colorGray900),
            ),
            Gaps.v8,
            Text(
              court.courtAddress,
              style: const TextStyle(color: Colors.grey),
            ),
            Gaps.v20,

            ///코트알람
            CourtNotificationSettings(vnAlarmSet: vnAlarmSet, court: court),
            Gaps.v20,
          ],
        ),
      ),
    );
  }
}