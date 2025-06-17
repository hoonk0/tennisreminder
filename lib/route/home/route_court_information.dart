import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tennisreminder_app/service/weather/weather_alarm.dart';
import 'package:tennisreminder_app/ui/bottom_sheet/bottom_sheet_notification.dart';
import 'package:tennisreminder_app/ui/component/basic_button.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../const/static/global.dart';

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
      appBar: AppBar(title: const Text('코트 정보')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ///코트사진
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

                  ///상단 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///코트이름
                          Text(
                            widget.court.courtName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gaps.v5,

                          ///주소 길면 짤라서 보이게하기
                          Text(
                            widget.court.courtAddress
                                    .split(' ')
                                    .take(5)
                                    .join(' ') +
                                (widget.court.courtAddress.split(' ').length > 5
                                    ? ''
                                    : ''),
                            style: const TextStyle(color: Colors.grey),
                            softWrap: true,
                          ),
                        ],
                      ),

                      ValueListenableBuilder(
                        valueListenable: Global.vnFavoriteCourts,
                        builder: (context, favoriteCourts, child) {
                          final isFavorite = favoriteCourts.any(
                            (e) => e.uid == widget.court.uid,
                          );

                          return GestureDetector(
                            onTap: () async {
                              final currentCourt = widget.court;

                              final userUid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (userUid == null) return;

                              final courtRef = FirebaseFirestore.instance
                                  .collection(keyCourt)
                                  .doc(currentCourt.uid);

                              if (isFavorite) {
                                Global.vnFavoriteCourts.value =
                                    favoriteCourts
                                        .where((e) => e.uid != currentCourt.uid)
                                        .toList();
                                await courtRef.update({
                                  ///파베에서 삭제
                                  keyLikedUserUids: FieldValue.arrayRemove([
                                    userUid,
                                  ]),
                                });
                              } else {
                                Global.vnFavoriteCourts.value = [
                                  ...favoriteCourts,
                                  currentCourt,
                                ];
                                await courtRef.update({
                                  ///파베에서 추가
                                  keyLikedUserUids: FieldValue.arrayUnion([
                                    userUid,
                                  ]),
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colorMain900),
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: colorMain900,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  Gaps.v10,

                  /*               ///날씨알람
                  WeatherAlarm(),*/

                  ///알람설정
                  GestureDetector(
                    onTap: () async {
                      if (vnAlarmSet.value) {
                        // 알람 설정 해제
                        vnAlarmSet.value = false;

                        final userUid = FirebaseAuth.instance.currentUser?.uid;
                        final courtUid = widget.court.uid;

                        if (userUid != null) {
                          final snapshot =
                              await FirebaseFirestore.instance
                                  .collection(keyCourtAlarms)
                                  .where(keyUserUid, isEqualTo: userUid)
                                  .where(keyCourtUid, isEqualTo: courtUid)
                                  .get();

                          for (final doc in snapshot.docs) {
                            await doc.reference.delete();
                          }
                        }
                      } else {
                        // 알람 설정
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
                              vnAlarmSet: vnAlarmSet,
                            );
                          },
                        ).then((_) async {
                          final userUid =
                              FirebaseAuth.instance.currentUser?.uid;
                          if (userUid != null) {
                            final snapshot =
                                await FirebaseFirestore.instance
                                    .collection(keyCourtAlarms)
                                    .where(keyUserUid, isEqualTo: userUid)
                                    .orderBy(keyDateCreate, descending: true)
                                    .get();

                            final list =
                                snapshot.docs
                                    .map(
                                      (doc) =>
                                          ModelCourtAlarm.fromJson(doc.data()),
                                    )
                                    .toList();

                            debugPrint('📥 알람 불러오기 완료: ${list.length}개');
                            for (var alarm in list) {
                              debugPrint(
                                '🔔 ${alarm.courtName}, ${alarm.alarmWeekday}요일 ${alarm.alarmHour}:${alarm.alarmMinute}, enabled: ${alarm.alarmEnabled}',
                              );
                            }

                            Global.vnCourtAlarms.value = list;
                          }
                        });
                      }
                    },
                    child: Container(
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
                                  child: const Text(
                                    '알림 설정하기 >',
                                    style: TS.s14w600(colorMain900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gaps.v10,

                  const Text(
                    'Field Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Gaps.v10,
                  Text(
                    widget.court.courtInfo,
                    style: const TextStyle(color: Colors.black87),
                  ),

                  Gaps.v20,
                ],
              ),
            ),
            // 🔔 테스트용 알림 버튼
            ElevatedButton(
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
              child: const Text('🔔 알림 테스트'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: BasicButton(title: '예약하러 가기', onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
