import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tennisreminder_app/service/map/naver_map_screen.dart';
import 'package:tennisreminder_app/ui/component/custom_divider.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../../const/static/global.dart';
import '../../../service/utils/utils.dart';
import '../../component/court_reservation_section.dart';

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

  // GoogleMapController for showing marker info window

  Future<String?> getFcmToken() async {
    // TODO: Replace with your actual FCM token fetch logic
    return await FirebaseMessaging.instance.getToken();
  }


  void _openNaverMapApp() async {
    final name = widget.court.courtAddress;
    final appUrl = Uri.parse('nmap://place?lat=${widget.court.latitude}&lng=${widget.court.longitude}&name=$name');
    // Web fallback: open Naver Map search for the name (address-based search)
    final url = Uri.encodeFull('https://map.naver.com/v5/search/$name');

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ 네이버 지도 앱 및 웹 모두 실행할 수 없습니다.');
    }
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
                                    image:
                                        widget.court.imageUrls != null &&
                                                widget
                                                    .court
                                                    .imageUrls!
                                                    .isNotEmpty
                                            ? NetworkImage(
                                              widget.court.imageUrls!.first,
                                            )
                                            : const AssetImage(
                                                  'assets/images/mainicon.png',
                                                )
                                                as ImageProvider,
                                    fit:
                                        widget.court.imageUrls != null &&
                                                widget
                                                    .court
                                                    .imageUrls!
                                                    .isNotEmpty
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
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            // Favorite (heart) icon at top right
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Row(
                                children: [

                                  ValueListenableBuilder(
                                    valueListenable: Global.vnFavoriteCourts,
                                    builder: (context, favoriteCourts, child) {
                                      final isFavorite = favoriteCourts.any(
                                        (e) => e.uid == widget.court.uid,
                                      );
                                      return GestureDetector(
                                        onTap: () async {
                                          final currentUser = Global.userNotifier.value;
                                          final userUid = currentUser?.uid;
                                          debugPrint("❤️ 좋아요 버튼 클릭됨 - 현재 유저 UID: $userUid, user_type: ${currentUser?.userType}");
                                          if (userUid == null || currentUser?.userType != UserType.user) {
                                            debugPrint("❌ user_type이 'UserType.user'가 아니거나 로그인되지 않음 - 좋아요 처리 중단");
                                            Utils.toast(desc: '로그인 후 이용해주세요');
                                            return;
                                          }

                                          final courtRef = FirebaseFirestore
                                              .instance
                                              .collection(keyCourt)
                                              .doc(widget.court.uid);

                                          if (isFavorite) {
                                            debugPrint("➖ 좋아요 제거: ${widget.court.uid}");
                                            Global.vnFavoriteCourts.value =
                                                favoriteCourts
                                                    .where(
                                                      (e) =>
                                                          e.uid !=
                                                          widget.court.uid,
                                                    )
                                                    .toList();
                                            await courtRef.update({
                                              keyLikedUserUids:
                                                  FieldValue.arrayRemove([
                                                    userUid,
                                                  ]),
                                            });
                                          } else {
                                            debugPrint("➕ 좋아요 추가: ${widget.court.uid}");
                                            Global.vnFavoriteCourts.value = [
                                              ...favoriteCourts,
                                              widget.court,
                                            ];
                                            await courtRef.update({
                                              keyLikedUserUids:
                                                  FieldValue.arrayUnion([
                                                    userUid,
                                                  ]),
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
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isFavorite
                                                    ? colorMain900
                                                    : Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
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
                                          color: Colors.black.withOpacity(
                                            0.08,
                                          ),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                          offset: Offset(
                                            0,
                                            -6,
                                          ), // sharper top shadow only
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Column(
                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.court.courtName,
                                              style: TS.s24w600(colorGray900),

                                            ),
                                            Gaps.v8,
                                            Text(
                                              widget.court.courtAddress,
                                              style: TS.s14w400(colorGray600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            Gaps.v8,
                                            if ((widget
                                                        .court
                                                        .courtInfo1
                                                        ?.isNotEmpty ??
                                                    false) ||
                                                (widget
                                                        .court
                                                        .courtInfo2
                                                        ?.isNotEmpty ??
                                                    false) ||
                                                (widget
                                                        .court
                                                        .courtInfo3
                                                        ?.isNotEmpty ??
                                                    false) ||
                                                (widget
                                                        .court
                                                        .courtInfo4
                                                        ?.isNotEmpty ??
                                                    false))
                                              Text(
                                                [
                                                  if (widget
                                                          .court
                                                          .courtInfo1
                                                          ?.isNotEmpty ??
                                                      false)
                                                    widget.court.courtInfo1!,
                                                  if (widget
                                                          .court
                                                          .courtInfo2
                                                          ?.isNotEmpty ??
                                                      false)
                                                    widget.court.courtInfo2!,
                                                  if (widget
                                                          .court
                                                          .courtInfo3
                                                          ?.isNotEmpty ??
                                                      false)
                                                    widget.court.courtInfo3!,
                                                  if (widget
                                                          .court
                                                          .courtInfo4
                                                          ?.isNotEmpty ??
                                                      false)
                                                    widget.court.courtInfo4!,
                                                ].join(' · '),
                                                style: const TS.s14w400(
                                                  colorGray900,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),

                                          ],
                                        ),
                                        CustomDivider(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 20,
                                            horizontal: 20,
                                          ),
                                          width: double.infinity,
                                        ),

                                        GestureDetector(
                                          onTap: () async {
                                            final url = widget.court.reservationUrl;
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              Utils.toast(desc: '예약사이트를 제공하지 않는 코트입니다.');
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "예약 사이트 바로가기",
                                                style: TS.s16w600(colorGray900),
                                              ),
                                              const SizedBox(width: 8),
                                              Image.asset(
                                                'assets/icons/reservationicon.png',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                              ),
                                            ],
                                          ),
                                        ),

                                        CustomDivider(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 20,
                                            horizontal: 20,
                                          ),
                                          width: double.infinity,
                                        ),

/*                                        ///코트정보
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "코트 정보",
                                              style: TS.s16w600(colorGray900),
                                            ),
                                            Gaps.v8,
                                            // 코트 정보 표시 (실내/실외, 샤워시설 등)
                                            // 2개씩 한 줄에 배치
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CourtContainerInformation(
                                                  label: '실내/실외',
                                                  value: '실내',
                                                  imagePath: 'assets/icons/weather.png',
                                                ),
                                                CourtContainerInformation(
                                                  label: '실내/실외',
                                                  value: '실내',
                                                  imagePath: 'assets/icons/weather.png',
                                                ),
                                              ],
                                            ),
                                            Gaps.v5,
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.sports_tennis),
                                                        SizedBox(width: 8),
                                                        Text('화장실', style: TS.s14w400(colorGray900)),
                                                        Spacer(),
                                                        Text('O', style: TS.s14w400(colorGray900)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.shower_outlined),
                                                        SizedBox(width: 8),
                                                        Text('샤워시설', style: TS.s14w400(colorGray900)),
                                                        Spacer(),
                                                        Text('O', style: TS.s14w400(colorGray900)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.sports_tennis),
                                                        SizedBox(width: 8),
                                                        Text('화장실', style: TS.s14w400(colorGray900)),
                                                        Spacer(),
                                                        Text('O', style: TS.s14w400(colorGray900)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.shower_outlined),
                                                        SizedBox(width: 8),
                                                        Text('샤워시설', style: TS.s14w400(colorGray900)),
                                                        Spacer(),
                                                        Text('O', style: TS.s14w400(colorGray900)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),


                                        CustomDivider(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 20,
                                            horizontal: 20,
                                          ),
                                          width: double.infinity,
                                        ),*/

                                        ///코트위치 표시
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "코트 위치",
                                                  style: TS.s16w600(colorGray900),
                                                ),

                                                GestureDetector(
                                                  onTap: () {
                                                    _openNaverMapApp();
                                                  },
                                                  child: Image.asset(
                                                    'assets/icons/mapicon.png',
                                                    width: 24,
                                                    height: 24,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Gaps.v10,
                                           ///네이버맵
                                            NaverMapScreen(court: widget.court,),

                                           Gaps.v40,
                                           ///구글맵
                                           /* SizedBox(
                                              height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                                  0.5, // 지도 크기 늘리기
                                              child: GoogleMap(
                                                initialCameraPosition:
                                                CameraPosition(
                                                  target: LatLng(
                                                    widget.court.latitude,
                                                    widget
                                                        .court
                                                        .longitude,
                                                  ),
                                                  zoom: 16,
                                                ),
                                                markers: {
                                                  Marker(
                                                    markerId: MarkerId(
                                                      widget.court.uid,
                                                    ),
                                                    position: LatLng(
                                                      widget.court.latitude,
                                                      widget.court.longitude,
                                                    ),
                                                    infoWindow: InfoWindow(
                                                      title:
                                                      widget
                                                          .court
                                                          .courtName,
                                                    ),
                                                    onTap: () {
                                                      // Could zoom or center if needed
                                                    },
                                                  ),
                                                },
                                                myLocationEnabled: true,
                                                myLocationButtonEnabled: true,
                                                onMapCreated: _onMapCreated,
                                              ),
                                            ),*/
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
                      ],
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
                 elevation: 0,
                 child: Container(
                   color: Colors.transparent,
                   child: Builder(
                     builder: (context) {
                       final currentUser = Global.userNotifier.value;
                       final userUid = currentUser?.uid;
                       debugPrint("❤️ 예약 버튼 클릭 확인 - 현재 유저 UID: $userUid, user_type: ${currentUser?.userType}");
                       if (userUid == null || currentUser?.userType != UserType.user) {
                         debugPrint("❌ user_type이 'UserType.user'가 아니거나 로그인되지 않음 - 예약 버튼 미노출");
                         return const SizedBox.shrink();
                       }
                       return CourtReservationSection(
                         court: widget.court,
                       );
                     },
                   ),
                 ),
               ),
             ),

              /// Bottom buttons: "모든 알람 삭제하기" and "예약하러 가기"
/*              Container(
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
      ),
    );
  }
}




class CourtContainerInformation extends StatelessWidget {
  final String label;
  final String value;
  final String imagePath;

  const CourtContainerInformation({
    required this.label,
    required this.value,
    required this.imagePath,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Image.asset(imagePath, width: 18, height: 18),
            SizedBox(width: 8),
            Text(label, style: TS.s14w400(colorGray900)),
            Spacer(),
            Text(value, style: TS.s14w400(colorGray900)),
          ],
        ),
      ),
    );
  }
}



/*                       /// 알람 설정하기 section
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
                                          */