import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisreminder_app/ui/component/custom_divider.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../const/static/global.dart';
import '../../service/utils/utils.dart';
import '../dialog/dialog_logout.dart';
import '../route/route_splash.dart';

class TabProfile extends StatelessWidget {

  Future<void> _showDeleteDialog(BuildContext context) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => DialogLogout(
        title: '회원탈퇴',
        desc: '정말로 회원탈퇴를 진행하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
        buttonLabel: '회원탈퇴',
        imagePath: 'assets/icons/delete.svg',
        // 적절한 SVG 경로로 변경
        onTapLogOut: () async {
          Navigator.of(context).pop(); // 다이얼로그 닫기
          await _handleDeleteAccount(context);
        },
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final globalUser = Global.userNotifier.value;

    if (globalUser == null) {
      Utils.log.w('No global user data');
      Utils.toast(desc: '사용자 정보가 없습니다.');
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RouteSplash()),
        );
      }
      return;
    }

    final success = await Utils.deleteAccount();
    if (success && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RouteSplash()),
            (route) => false,
      );
    }
  }

  final VoidCallback? onTapBookmark;

/*

  Future<void> _addDummyCourts() async {
    final batch = FirebaseFirestore.instance.batch();
    final courtsCollection = FirebaseFirestore.instance.collection('court');

    for (int i = 0; i < 10; i++) {
      final docRef = courtsCollection.doc();
      final address = '서울시 강남구 xx동';
      final district = address.split(' ').length > 1 ? address.split(' ')[1] : '';
      final court = ModelCourt(
        uid: docRef.id,
        dateCreate: Timestamp.now(),
        latitude: 37.5 + i * 0.01,
        longitude: 127.0 + i * 0.01,
        courtName: '샘플 코트 $i',
        courtAddress: address,
        courtInfo: '이곳은 샘플 코트입니다 $i',
        reservationUrl: 'https://reservation.example.com/$i',
        likedUserUids: [],
        imageUrls: [],
    //    extraInfo: {'parking': i % 2 == 0, 'light': i % 3 == 0},
        courtDistrict: district,
      );
      batch.set(docRef, court.toJson());
    }

    await batch.commit();
  }
*/

  const TabProfile({super.key, this.onTapBookmark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Gaps.v16,

          ///선호코트 수
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알람 코트 수'),
                  ValueListenableBuilder<List<ModelCourtAlarm>>(
                    valueListenable: Global.vnCourtAlarms,
                    builder: (context, list, _) {
                      final alarmCount = list.length;
                      final courtCount = list.map((e) => e.courtUid).toSet().length;
                      return Text('$courtCount개의 코트');
                    },
                  )
                  ],
                ),
                CustomDivider(width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 20), margin: EdgeInsets.symmetric(vertical: 5),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알람 수'),
                    ValueListenableBuilder<List<ModelCourtAlarm>>(
                      valueListenable: Global.vnCourtAlarms,
                      builder: (context, list, _) {
                        final alarmCount = list.length;
                        final courtCount = list.map((e) => e.courtUid).toSet().length;
                        return Text('$alarmCount개의 알람');
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          Gaps.v16,
          /// 내 정보 변경 항목들
/*
          MenuTitle(
            label: '내 정보 변경',
            icon: Icons.person_outline,
            onTap: () {
           */
/*   Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const RouteProfileMyInformation()));*//*

            },
          ),
*/

          MenuTitle(
            label: '건의사항',
            icon: Icons.mail_outline,
            onTap: () {
              /*   Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const RouteProfileMyInformation()));*/
            },
          ),

          const Divider(height: 1, color: colorGray200),
          MenuTitle(
            label: '개인정보 처리방침 및 이용약관',
            icon: Icons.info_outline_rounded,
            onTap: () {
          /*    Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const RouteProfilePrivacyPolicy()));*/
            },
          ),
          const Divider(height: 1, color: colorGray200),

          MenuTitle(
            icon: Icons.logout,
            label: '로그아웃',
            onTap: () async {
              await showDialog(
                context: context,
                builder: (_) => DialogLogout(
                  desc: '로그아웃이 진행됩니다.',
                  onTapLogOut: () async {
                    final success = await Utils.logout();
                    if (success) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const RouteSplash()),
                        (route) => false,
                      );
                      Utils.toast(desc: '로그아웃 되었습니다. 재로그인 해주시기 바랍니다.');
                    }
                  },
                  title: '정말 로그아웃 하시겠어요?',
                  buttonLabel: '로그아웃',
                  imagePath: 'assets/icons/logout.svg',
                ),
              );
            },
          ),

          Spacer(),

        GestureDetector(
            onTap: () {
              _showDeleteDialog(context);
            },
            child: Text('회원탈퇴', style: TS.s14w400(colorGray600).copyWith(decoration: TextDecoration.underline))),
          Gaps.v20,
        ],
      ),
    );
  }
}

class MenuTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuTitle({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      leading: Icon(icon, color: colorGray700),
      title: Text(label, style: const TS.s15w500(colorGray900)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: colorGray400),
      onTap: onTap,
    );
  }
}
