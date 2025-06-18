import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tennisreminder_app/service/weather/weather_alarm.dart';
import 'package:tennisreminder_app/ui/bottom_sheet/bottom_sheet_notification.dart';
import 'package:tennisreminder_app/ui/component/basic_button.dart';
import 'package:tennisreminder_app/ui/component/custom_divider.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../../const/static/global.dart';
import '../../../service/utils/utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100), // reserve space for button
                      child: ListView(
                        children: [
                  /// 코트 사진 - full width with rounded bottom corners
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: widget.court.imageUrls != null && widget.court.imageUrls!.isNotEmpty
                                  ? NetworkImage(widget.court.imageUrls!.first)
                                  : const AssetImage('assets/images/mainicon.png') as ImageProvider,
                              fit: widget.court.imageUrls != null && widget.court.imageUrls!.isNotEmpty
                                  ? BoxFit.cover
                                  : BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                            color: colorWhite,
                          ),
                        ),
                      ),
                      // Left-aligned back button
                      Positioned(
                        top: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back, color: Colors.black,)),
                        ),
                      ),
                      // Favorite (heart) icon at top right
                      Positioned(
                        top: 20,
                        right: 20,
                        child: ValueListenableBuilder(
                          valueListenable: Global.vnFavoriteCourts,
                          builder: (context, favoriteCourts, child) {
                            final isFavorite = favoriteCourts.any((e) => e.uid == widget.court.uid);
                            return GestureDetector(
                              onTap: () async {
                                final userUid = FirebaseAuth.instance.currentUser?.uid;
                                if (userUid == null) return;

                                final courtRef = FirebaseFirestore.instance
                                    .collection(keyCourt)
                                    .doc(widget.court.uid);

                                if (isFavorite) {
                                  Global.vnFavoriteCourts.value =
                                      favoriteCourts.where((e) => e.uid != widget.court.uid).toList();
                                  await courtRef.update({
                                    keyLikedUserUids: FieldValue.arrayRemove([userUid]),
                                  });
                                } else {
                                  Global.vnFavoriteCourts.value = [
                                    ...favoriteCourts,
                                    widget.court,
                                  ];
                                  await courtRef.update({
                                    keyLikedUserUids: FieldValue.arrayUnion([userUid]),
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? colorMain900 : Colors.black,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  /// 컨테이너
                  Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: Offset(0, -6), // sharper top shadow only
                                  ),

                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.court.courtName,
                                    style: TS.s24w600(colorGray900),
                                  ),
                                  Gaps.v8,
                                  Text(
                                    widget.court.courtAddress,
                                      style: TS.s14w400(colorGray600),
                                  ),



                                  Gaps.v8,
                                  Text(
                                    widget.court.extraInfo?['xxx'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  CustomDivider(margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20), width: double.infinity,),

                                  /// 알람 설정하기 section
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '알람 설정하기',
                                        style: TS.s16w600(colorGray900),),
                                      Gaps.v6,
                                      const Text(
                                        '원하는 시간에 예약 알람을 받을 수 있어요.',
                                        style: TS.s14w400(colorGray600),
                                      ),
                                      Gaps.v12,
                                      BasicButton(
                                        title: '알람 설정하기',
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return BottomSheetNotification(court: widget.court, vnAlarmSet: vnAlarmSet);
                                            },
                                          );
                                        },
                                      ),
                                      Gaps.v4,
                                      ValueListenableBuilder(
                                        valueListenable: Global.vnCourtAlarms,
                                        builder: (context, courtAlarms, _) {
                                          final hasAlarm = courtAlarms.any((e) => e.courtUid == widget.court.uid);
                                          return BasicButton(
                                            title: '모든 알람 삭제하기',
                                            colorBg: hasAlarm ? colorMain900 : colorGray400,
                                            onTap: () async {
                                              Utils.toast(desc: '해당 코트 알람이 삭제되었습니다.');

                                              if (!hasAlarm) return;

                                              vnAlarmSet.value = false;

                                              final userUid = FirebaseAuth.instance.currentUser?.uid;
                                              final courtUid = widget.court.uid;

                                              if (userUid != null) {
                                                final snapshot = await FirebaseFirestore.instance
                                                    .collection(keyCourtAlarms)
                                                    .where(keyUserUid, isEqualTo: userUid)
                                                    .where(keyCourtUid, isEqualTo: courtUid)
                                                    .get();

                                                for (final doc in snapshot.docs) {
                                                  await doc.reference.delete();
                                                }

                                                Global.vnCourtAlarms.value = courtAlarms
                                                    .where((e) => e.courtUid != courtUid)
                                                    .toList();
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  CustomDivider(margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20), width: double.infinity,),

                                  ///코트위치 표시
                                  Column(
                                    children: [
                                      Text("코트 위치 표시",style: TS.s16w600(colorGray900),),
                                    ],
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),



 /*                 /// Test Notification Button - styled as chip/outlined button aligned left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        flutterLocalNotificationsPlugin.show(
                          0,
                          '🔔 테스트 알림',
                          '이 알림이 보이면 앱 알림 설정은 정상입니다.',
                          NotificationDetails(
                            android: AndroidNotificationDetails(
                              'alarm_channel',
                              '알림 채널',
                              importance: Importance.high,
                              priority: Priority.high,
                              icon: '@mipmap/ic_launcher',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('기능 테스트용'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorMain900),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        foregroundColor: colorMain900,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  Gaps.v20,*/
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final url = widget.court.reservationUrl;
                      if (url.isNotEmpty) {
                        final uri = Uri.tryParse(url);
                        if (uri != null) {
                          final canLaunch = await canLaunchUrl(uri);
                          if (canLaunch) {
                            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                          }
                        } else {
                        }
                      } else {
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '예약사이트로 이동하기',
                          style: TS.s16w600(colorMain900),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            /// Bottom buttons: "모든 알람 삭제하기" and "예약하러 가기"
            /*Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: colorGray300)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Gaps.v12,
                  BasicButton(title: '예약하러 가기', onTap: () {}),
                ],
              ),
            ),*/
              Gaps.v20,
            ],
          ),
        ),
      ),);
  }
}
