import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../../service/utils/utils.dart';
import '../../ui/component/basic_button.dart';
import '../route_main.dart';

class RouteAuthSnsSignUp extends StatefulWidget {
  final String uid;
  final String? email;
  final LoginType loginType;

  const RouteAuthSnsSignUp({
    super.key,
    required this.uid,
    this.email,
    required this.loginType,
  });

  @override
  State<RouteAuthSnsSignUp> createState() => _RouteAuthSnsSignUpState();
}

class _RouteAuthSnsSignUpState extends State<RouteAuthSnsSignUp> {
  final ValueNotifier<bool> vnIsComplete = ValueNotifier(true); // 즉시 활성화

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
  /*            SvgPicture.asset(
                'assets/images/greencheck.svg',
                width: 115,
                height: 111,
              ),*/
              Gaps.v20,
              const Text('가입 완료', style: TS.s16w500(colorGray600)),
              Gaps.v6,
              const Text(
                '환영합니다!',
                style: TS.s24w600(colorGray900),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ValueListenableBuilder(
                  valueListenable: vnIsComplete,
                  builder: (context, isComplete, child) {
                    return BasicButton(
                      title: '시작하기',
                      titleColorBg: isComplete ? colorWhite : colorGray500,
                      colorBg: isComplete ? colorMain900 : colorGray100,
                      onTap: isComplete
                          ? () async {
                        debugPrint('시작하기 버튼 클릭');
                        final modelUser = ModelUser(
                          uid: widget.uid,
                          email: widget.email ?? 'kakaoLogin',
                          loginType: widget.loginType,
                          dateCreate: Timestamp.now(),
                        );
                        try {
                          debugPrint('Firestore 저장 시작: uid=${widget.uid}');
                          await FirebaseFirestore.instance
                              .collection(keyUser)
                              .doc(modelUser.uid)
                              .set(modelUser.toJson());
                          debugPrint('Firestore 저장 성공');

                          final pref = await SharedPreferences.getInstance();
                          await pref.setString(keyUid, widget.uid);
                          debugPrint('SharedPreferences 저장 성공');

                          if (context.mounted) {
                            debugPrint('Navigator.push 호출');
                            await Future.microtask(() {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const RouteMain()),
                              );
                            });
                            debugPrint('Navigator.push 완료');
                          } else {
                            debugPrint('context 유효하지 않음');
                            Utils.toast(desc: '화면 전환 실패');
                          }
                        } catch (e, s) {
                          debugPrint('에러 발생: $e\n$s');
                          Utils.toast(desc: '회원가입 실패: $e');
                        }
                      }
                          : null,
                    );
                  },
                ),
              ),
              Gaps.v16,
            ],
          ),
        ),
      ),
    );
  }
}