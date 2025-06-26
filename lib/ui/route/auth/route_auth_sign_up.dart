import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 추가
import 'package:tennisreminder_core/const/model/model_user.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:uuid/uuid.dart';
import '../../../service/utils/utils.dart';
import '../../component/basic_button.dart';
import '../../component/textfield_border.dart';
import 'detail/route_auth_sign_up_detail.dart';

class RouteAuthSignUp extends StatefulWidget {
  const RouteAuthSignUp({super.key});

  @override
  State<RouteAuthSignUp> createState() => _RouteAuthSignUpState();
}

class _RouteAuthSignUpState extends State<RouteAuthSignUp> {
  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecPw = TextEditingController();
  final TextEditingController tecPwConfirm = TextEditingController();

  final ValueNotifier<bool> vnSignUpButtonEnabled = ValueNotifier(false);
  final ValueNotifier<bool> vnObscurePwNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> vnObscurePwConfirmNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> vnIsAuthNumberMatch = ValueNotifier(false);

  final ValueNotifier<String> vnIdCheck = ValueNotifier<String>('중복확인');

  final regExpEmail = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]{2,}$");
  final regPw = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  void initState() {
    super.initState();
    tecEmail.addListener(_updateSignUpButtonState);
    tecPw.addListener(_updateSignUpButtonState);
    tecPwConfirm.addListener(_updateSignUpButtonState);
  }

  @override
  void dispose() {
    tecEmail.dispose();
    tecPw.dispose();
    tecPwConfirm.dispose();
    vnSignUpButtonEnabled.dispose();
    vnObscurePwNotifier.dispose();
    vnObscurePwConfirmNotifier.dispose();
    vnIsAuthNumberMatch.dispose();
    vnIdCheck.dispose();
    super.dispose();
  }

  void _updateSignUpButtonState() {
    final isEmailValid = regExpEmail.hasMatch(tecEmail.text);
    final isPasswordValid = regPw.hasMatch(tecPw.text);
    final isPasswordConfirmed = tecPw.text == tecPwConfirm.text;

    vnSignUpButtonEnabled.value =
        tecEmail.text.isNotEmpty &&
            tecPw.text.isNotEmpty &&
            tecPwConfirm.text.isNotEmpty &&
            isEmailValid &&
            isPasswordValid &&
            isPasswordConfirmed &&
            vnIsAuthNumberMatch.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('회원가입')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gaps.v16,
                        const Text('회원가입을 위해 필요한\n정보를 입력해주세요.', style: TS.s20w600(colorGray900)),
                        Gaps.v48,

                        /// 이메일
                        const Text('아이디', style: TS.s12w500(colorGray600)),
                        Gaps.v10,
                        ValueListenableBuilder(
                          valueListenable: tecEmail,
                          builder: (context, value, child) {
                            final isEmailMatch = regExpEmail.hasMatch(tecEmail.text);
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: TextFieldBorder(
                                    controller: tecEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    hintText: '아이디(이메일) 입력',
                                    errorText: (tecEmail.text.isEmpty || isEmailMatch)
                                        ? null
                                        : '유효하지 않은 이메일 형식 입니다.',
                                    onChanged: (value) {
                                      vnIsAuthNumberMatch.value = false;
                                      vnIdCheck.value = '중복확인';
                                    },
                                  ),
                                ),
                                Gaps.h8,
                                Expanded(
                                  flex:2,
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: vnIdCheck,
                                    builder: (context, idCheckText, _) {
                                      return BasicButton(
                                        title: idCheckText,
                                        colorBg: idCheckText == '확인됨' ? colorGray100 : colorMain900,
                                        titleColorBg: idCheckText == '확인됨' ? colorGray500 : colorWhite,
                                        onTap: isEmailMatch
                                            ? () async {
                                          final userDs = await FirebaseFirestore.instance
                                              .collection(keyUser)
                                              .where(keyEmail, isEqualTo: tecEmail.text)
                                              .get();
                                          if (userDs.docs.isNotEmpty) {
                                            Utils.toast(
                                              desc: '이미 등록된 이메일입니다.',
                                            );
                                            vnIsAuthNumberMatch.value = false;
                                            vnIdCheck.value = '중복확인';
                                            return;
                                          }
                                          Utils.toast(
                                            desc: '사용 가능한 이메일입니다.',
                                          );
                                          vnIsAuthNumberMatch.value = true;
                                          vnIdCheck.value = '확인됨';
                                          _updateSignUpButtonState();
                                        }
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Gaps.v20,

                        /// 비밀번호
                        const Text('비밀번호', style: TS.s14w500(colorGray900)),
                        Gaps.v10,
                        ValueListenableBuilder(
                          valueListenable: tecPw,
                          builder: (context, isCheck, child) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: vnObscurePwNotifier,
                              builder: (context, obscurePw, child) {
                                return TextFieldBorder(
                                  errorText: tecPw.text.isEmpty || regPw.hasMatch(tecPw.text)
                                      ? null
                                      : '영문, 숫자 포함 8자리 이상 입력해주세요.',
                                  controller: tecPw,
                                  hintText: '비밀번호 입력',
                                  obscureText: obscurePw,
                                  onChanged: (value) => _updateSignUpButtonState(),
                                );
                              },
                            );
                          },
                        ),
                        Gaps.v10,

                        /// 비밀번호 확인
                        ValueListenableBuilder(
                          valueListenable: tecPwConfirm,
                          builder: (context, isCheck, child) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: vnObscurePwConfirmNotifier,
                              builder: (context, obscureConfirm, child) {
                                return TextFieldBorder(
                                  controller: tecPwConfirm,
                                  errorTextStyle: TextStyle(color:
                                  colorMain900),
                                  obscureText: obscureConfirm,
                                  hintText: '비밀번호 재입력',
                                  errorText: tecPwConfirm.text.isEmpty
                                      ? null
                                      : (tecPw.text == tecPwConfirm.text
                                          ? '비밀번호가 일치합니다.'
                                          : null),
                                  onChanged: (value) => _updateSignUpButtonState(),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                /// 가입 완료 버튼
                ValueListenableBuilder<bool>(
                  valueListenable: vnSignUpButtonEnabled,
                  builder: (context, isButtonEnabled, child) {
                    return BasicButton(
                      title: '가입 완료',
                      titleColorBg: isButtonEnabled ? colorWhite : colorGray500,
                      colorBg: isButtonEnabled ? colorMain900 : colorGray100,
                      onTap: isButtonEnabled ? _signUp : null,
                    );
                  },
                ),
                Gaps.v10,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 회원가입 Firebase 저장
  Future<void> _signUp() async {
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final uid = const Uuid().v4();
      final modelUser = ModelUser(
        uid: uid,
        dateCreate: Timestamp.now(),
        email: tecEmail.text,
        pw: tecPw.text,
        loginType: LoginType.email,
      );

      // Firestore에 사용자 저장
      await FirebaseFirestore.instance.collection(keyUser).doc(uid).set(modelUser.toJson());

      // SharedPreferences에 uid 저장
      final pref = await SharedPreferences.getInstance();
      await pref.setString('uid', uid);

      Utils.toast(
        desc: '회원가입 성공!',
      );

      // 다음 화면으로 이동
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RouteAuthSignUpDetail()),
      );
    } catch (e) {
      Utils.toast(
        desc: '회원가입 실패: $e',
      );
    }
  }
}