import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../const/static/global.dart';
import '../../service/utils/utils.dart';
import '../route/route_splash.dart';
import '../ui/dialog/dialog_logout.dart';

class TabProfile extends StatelessWidget {
  final VoidCallback? onTapBookmark;

  const TabProfile({super.key, this.onTapBookmark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Gaps.v16,

          ///선호코트 수
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colorBlack),
                ),
                child: Text('선호코트 수'),
              ),
            ],
          ),
          Gaps.v16,
          /// 내 정보 변경 항목들
          MenuTitle(
            label: '내 정보 변경',
            icon: Icons.person_outline,
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
