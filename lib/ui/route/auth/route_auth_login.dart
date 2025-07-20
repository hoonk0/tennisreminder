import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tennisreminder_app/ui/route/auth/route_auth_find_pw.dart';
import 'package:tennisreminder_app/ui/route/auth/route_auth_sign_up.dart';
import 'package:tennisreminder_app/ui/route/auth/route_auth_sns_sign_up.dart';
import 'package:tennisreminder_app/ui/route/route_main.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../../const/static/global.dart';
import '../../../service/utils/utils.dart';
import '../../component/basic_button.dart';
import '../../component/textfield_border.dart';
import '../../dialog/dialog_confirm.dart';
import '../route_splash.dart';

class RouteAuthLogin extends StatefulWidget {
  const RouteAuthLogin({super.key});

  @override
  State<RouteAuthLogin> createState() => _RouteLoginState();
}

class _RouteLoginState extends State<RouteAuthLogin> {
  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecPw = TextEditingController();
  final ValueNotifier<bool> vnObscureTextNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    tecEmail.dispose();
    tecPw.dispose();
    vnObscureTextNotifier.dispose();
    super.dispose();
  }

  Future<void> loginCheck(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (tecEmail.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: '이메일을 입력해주세요',
        ),
      );
      return;
    }

    if (tecPw.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: '비밀번호를 입력해주세요',
        ),
      );
      return;
    }

    final targetUserDs = await FirebaseFirestore.instance.collection(keyUser).where(keyEmail, isEqualTo: tecEmail.text).get();
    if (targetUserDs.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: '존재하지 않는 사용자입니다',
        ),
      );
      return;
    }
    final targetUser = ModelUser.fromJson(targetUserDs.docs.first.data());

    if (targetUser.pw != tecPw.text) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: '비밀번호가 일치하지 않습니다',
        ),
      );
      return;
    }

    Global.userNotifier.value = targetUser;

    final pref = await SharedPreferences.getInstance();
    pref.setString(keyUid, targetUser.uid);
    debugPrint('로그인 uid ${targetUser.uid}');

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center ,
                        children: [

                          ///로고
                          Column(
                            children: [
                              ///로고 부분
                              Image.asset(
                                'assets/images/mainlogo.png',
                                width: 200,
                              ),
                              Gaps.v20,

                              const Text(
                                '공공기관 테니스코트\n예약 알리미',
                                style: TS.s24w700(colorMain900),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Gaps.v20,

                          /// 아이디 텍스트필드
                          TextFieldBorder(
                            controller: tecEmail,
                            keyboardType: TextInputType.emailAddress,
                            hintText: '아이디(이메일) 입력',
                          ),
                          Gaps.v10,

                          /// 비밀번호 텍스트필드
                          ValueListenableBuilder<bool>(
                            valueListenable: vnObscureTextNotifier,
                            builder: (context, obscureText, child) {
                              return TextFieldBorder(
                                controller: tecPw,
                                obscureText: obscureText,
                                hintText: '비밀번호 입력',
                              );
                            },
                          ),

                          Gaps.v16,
                          ///회원가입, 아이디, 비밀번호 찾기
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              /// 비밀번호 찾기
                              _WidgetText(
                                title: '비밀번호 찾기',
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RouteAuthFindPw(),
                                    ),
                                  );
                                },
                              ),

                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                width: 1,
                                height: 12,
                                color: colorGray400,
                              ),

                              ///회원가입
                              _WidgetText(
                                title: '회원가입',
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RouteAuthSignUp(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Gaps.v16,

                          /// 로그인
                          BasicButton(
                            title: '로그인',
                            onTap: () {
                              loginCheck(context);
                            },
                          ),
                          Gaps.v16,

                          /// SNS 로그인
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// 네이버 로그인 (공통)
                              GestureDetector(
                                onTap: () async {
                                  _loginForNaver();
                                },
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: SvgPicture.asset(
                                    'assets/images/naver.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              Gaps.h20,

                              /// 카카오 로그인 (공통)
                              GestureDetector(
                                onTap: () async {
                                  final String? uid = await Utils.onKakaoTap();
                                  if (uid != null) {
                                    final userDs = await FirebaseFirestore.instance.collection(keyUser).where(keyUid, isEqualTo: uid).get();
                                    if (userDs.docs.isEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RouteAuthSnsSignUp(
                                            uid: uid,
                                            email: null,
                                            loginType: LoginType.kakao,
                                          ),
                                        ),
                                      );
                                    } else {
                                      final pref = await SharedPreferences.getInstance();
                                      pref.setString(keyUid, uid);
                                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
                                    }
                                  }
                                },
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: SvgPicture.asset(
                                    'assets/images/kakao.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              Gaps.h20,

                              /// 플랫폼별 로그인
                              if (Theme.of(context).platform == TargetPlatform.android)
                                GestureDetector(
                                  onTap: () => _googleLogin(context),
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: SvgPicture.asset(
                                      'assets/images/google.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                              if (Theme.of(context).platform == TargetPlatform.iOS)
                                GestureDetector(
                                  onTap: () async {
                                    _loginForApple();
                                  },
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: SvgPicture.asset(
                                      'assets/images/apple.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Gaps.v16,
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RouteMain()));
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colorGray900,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: const Text(
                    '로그인 없이 둘러보기',
                    style: TS.s13w500(colorGray900),
                  ),
                ),
              ),
                          Gaps.v40,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 네이버 로그인
  void _loginForNaver() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Utils.toast(desc: '네이버 로그인을 시도중입니다.');
    print('▶ 네이버 로그인 버튼 클릭됨');

    /// 네이버 로그인 인증
    NaverLoginSDK.authenticate(
      callback: OAuthLoginCallback(
        /// 인증 성공시
        onSuccess: () {
          print('✅ 인증 성공 - onSuccess 진입');
          Utils.log.i('✅ 네이버 인증 성공');

          print('▶ 프로필 요청 직전');
          /// 인증 성공시, 네이버 프로필 가져오기
          NaverLoginSDK.profile(
            callback: ProfileCallback(
              /// 프로필 가져오는거 성공시
              onSuccess: (resultCode, message, response) async {
                print('✅ 프로필 요청 성공');
                print('📦 resultCode: $resultCode');
                print('📦 message: $message');
                print('📦 response: $response');
                Utils.log.i("[DEBUG-네이버 로그인] resultCode: $resultCode");
                Utils.log.i("[DEBUG-네이버 로그인] message: $message");
                Utils.log.i("[DEBUG-네이버 로그인] raw response: $response");

                final profile = NaverLoginProfile.fromJson(response: response);
                Utils.log.i("profile:$profile");

                if (profile.id == null) {
                  print('⚠️ profile.id가 null');
                  Utils.toast(desc: '네이버 로그인에 실패하였습니다.');
                  return;
                }

                final userDs = await FirebaseFirestore.instance.collection(keyUser).where(keyUid, isEqualTo: profile.id).get();

                if (userDs.docs.isEmpty) {
                  print('➡ 신규회원: 회원가입 페이지 이동');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RouteAuthSnsSignUp(
                        uid: profile.id!,
                        email: profile.email,
                        loginType: LoginType.naver,
                      ),
                    ),
                  );
                } else {
                  print('➡ 기존회원: Splash로 이동');
                  final pref = await SharedPreferences.getInstance();
                  pref.setString(keyUid, profile.id!);
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
                }
              },

              /// 프로필 가져오는거 실패시
              onFailure: (httpStatus, message) {
                print('❌ 프로필 요청 실패 - $httpStatus: $message');
                Utils.toast(desc: message);
              },

              /// 프로필 가져오는거 에러시
              onError: (errorCode, message) {
                print('🚨 프로필 요청 에러 - $errorCode: $message');
                Utils.toast(desc: message);
              },
            ),
          );
          print('▶ 프로필 요청 호출 완료');
        },

        /// 인증 실패시
        onFailure: (httpStatus, message) {
          print('❌ 인증 실패 - $httpStatus: $message');
          Utils.toast(desc: message);
        },

        /// 인증 에러시
        onError: (errorCode, message) {
          print('🚨 인증 에러 - $errorCode: $message');
          Utils.toast(desc: message);
        },
      ),
    );
  }

  ///애플로그인
  void _loginForApple() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Utils.toast(desc: '애플 로그인을 시도중입니다.');
    print('▶ 애플 로그인 버튼 클릭됨');

    try {
      print('▶ Apple 인증 요청 시작');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print('✅ Apple credential 받음');
      print('📧 email: ${credential.email}');
      print('🆔 userIdentifier: ${credential.userIdentifier}');

      final String uid = credential.userIdentifier ?? '';
      if (uid.isEmpty) {
        Utils.toast(desc: '애플 로그인 실패: userIdentifier 없음');
        return;
      }

      final userDs = await FirebaseFirestore.instance.collection(keyUser).where(keyUid, isEqualTo: uid).get();
      if (userDs.docs.isEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RouteAuthSnsSignUp(
              uid: uid,
              email: credential.email,
              loginType: LoginType.apple,
            ),
          ),
        );
      } else {
        final pref = await SharedPreferences.getInstance();
        pref.setString(keyUid, uid);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
      }
    } catch (e, stack) {
      print('❌ 예외 발생: $e');
      print('📍 Stack trace: $stack');
      Utils.toast(desc: '애플 로그인 실패: ${e.toString()}');
    }
  }
}

/// 구글 로그인
Future<void> _googleLogin(BuildContext context) async {
  final UserCredential? userCredential = await Utils.onGoogleTap(context);
  if (userCredential != null) {
    final uid = userCredential.user!.uid;

    final userDs = await FirebaseFirestore.instance.collection(keyUser).where(keyUid, isEqualTo: uid).get();
    // 회원가입이 안됨
    if (userDs.docs.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RouteAuthSnsSignUp(
            loginType: LoginType.google,
            uid: uid,
          ),
        ),
      );
    }

    /// 회원가입이 되어있음
    else {
      Global.pref ??= await SharedPreferences.getInstance();
      Global.pref!.setString(keyUid, uid);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
    }
  }
}


class _WidgetText extends StatelessWidget {
  final String title;
  final void Function()? onTap;

  const _WidgetText({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Text(
          title,
          style: const TS.s13w500(colorGray500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

