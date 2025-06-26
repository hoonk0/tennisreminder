import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/ui/route/auth/route_auth_pw_change.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../../service/utils/utils.dart';
import '../../component/basic_button.dart';
import '../../component/textfield_border.dart';
import '../../dialog/dialog_confirm.dart';

class RouteAuthFindPw extends StatefulWidget {
  const RouteAuthFindPw({super.key});

  @override
  State<RouteAuthFindPw> createState() => _RouteAuthFindPwState();
}

class _RouteAuthFindPwState extends State<RouteAuthFindPw> {
  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecEmailConfirm = TextEditingController();
  final ValueNotifier<bool> vnSignUpButtonEnabled = ValueNotifier(false);
  final RegExp regExpEmail = RegExp(r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$");
  final FocusNode fnEmail = FocusNode();
  final FocusNode fnCode = FocusNode();
  final ValueNotifier<int> vnTimer = ValueNotifier(180);
  final ValueNotifier<bool> vnTimerVisible = ValueNotifier(false);
  Timer? countdownTimer;

  ModelUser? targetModelUser;
  String authNumber = '';
  final ValueNotifier<bool> vnIsAuthNumberMatch = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    tecEmail.addListener(_updateSignUpButtonState);
    tecEmailConfirm.addListener(_updateSignUpButtonState);
  }

  @override
  void dispose() {
    tecEmail.dispose();
    tecEmailConfirm.dispose();
    super.dispose();
  }

  void _updateSignUpButtonState() {
    vnSignUpButtonEnabled.value =
        tecEmail.text.isNotEmpty &&
            regExpEmail.hasMatch(tecEmail.text) &&
            tecEmailConfirm.text.isNotEmpty &&
            vnIsAuthNumberMatch.value &&
            targetModelUser != null &&
            vnTimer.value > 0;
  }


  Future<void> _sendVerificationCode() async {
    fnEmail.unfocus();

    final userQs = await FirebaseFirestore.instance
        .collection(keyUser)
        .where(keyEmail, isEqualTo: tecEmail.text)
        .get();

    if (userQs.docs.isEmpty) {
      Utils.toast(desc: '유저가 존재하지 않습니다.');
      return;
    }

    targetModelUser = ModelUser.fromJson(userQs.docs.first.data());

    final random = Random();
    authNumber = random.nextInt(10000).toString().padLeft(4, '0');

    ///인증메일 보내기
    final result = await Utils.sendEmail(
      tecEmail.text,
      '비밀번호 찾기 인증번호',
      '인증번호: $authNumber',
    );

    Utils.toast(desc: result ? '인증번호를 확인해주세요.' : '인증번호 발송 실패');
    if (result) {

      ///전송되면 인증번호로 포커스 이동, 시간초 카운트 시작
      vnTimer.value = 180;
      vnTimerVisible.value = true;
      fnCode.requestFocus();

      countdownTimer?.cancel();
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (vnTimer.value > 0) {
          vnTimer.value--;
        } else {
          countdownTimer?.cancel();
        }
      });
    }
  }

  void _verifyCode() {
    if (vnTimer.value == 0) {
      Utils.toast(desc: '인증번호 유효 시간이 만료되었습니다.');
      return;
    }
    fnCode.unfocus();
    vnIsAuthNumberMatch.value = authNumber == tecEmailConfirm.text;

    if (!vnIsAuthNumberMatch.value) {
      targetModelUser = null;
      Utils.toast(desc: '인증번호가 일치하지 않습니다.');
    } else {
      Utils.toast(desc: '인증번호 확인이 완료되었습니다.');}

    _updateSignUpButtonState();
  }

  void _findPw() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (targetModelUser == null) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(desc: '유저가 존재하지 않습니다.'),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RouteAuthPwChange(modelUser: targetModelUser!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 찾기')),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                        const Text('보내드린 인증번호를 입력해주세요.',style: TS.s20w600(colorGray900),),
                        Gaps.v48,
                        const Text('아이디', style: TS.s14w500(colorGray900)),
                        Gaps.v10,
                        ///아이디 입력
                        ValueListenableBuilder(
                          valueListenable: tecEmail,
                          builder: (context, value, child) {
                            final isEmailValid = regExpEmail.hasMatch(tecEmail.text);
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: TextFieldBorder(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: tecEmail,
                                    hintText: '아이디 입력',
                                    errorText: (tecEmail.text.isEmpty || isEmailValid) ? null : '유효하지 않은 이메일 형식입니다.',
                                    onChanged: (_) {
                                      vnIsAuthNumberMatch.value = false;
                                      targetModelUser = null;
                                      _updateSignUpButtonState();
                                    },
                                    focusNode: fnEmail,
                                  ),
                                ),
                                Gaps.h8,
                                Expanded(
                                  flex:2,
                                  child: BasicButton(
                                    width: 100,
                                    title: '전송',
                                    colorBg: isEmailValid ? colorMain900 : colorGray100,
                                    onTap: isEmailValid ? _sendVerificationCode : null,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Gaps.v10,

                        ///인증번호 입력
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: ValueListenableBuilder<int>(
                                valueListenable: vnTimer,
                                builder: (context, secondsLeft, _) {
                                  final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
                                  final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

                                  return ValueListenableBuilder<bool>(
                                    valueListenable: vnTimerVisible,
                                    builder: (context, isVisible, _) {
                                      return TextFieldBorder(
                                        controller: tecEmailConfirm,
                                        focusNode: fnCode,
                                        hintText: '인증번호 입력',
                                        onChanged: (_) {
                                          vnIsAuthNumberMatch.value = false;
                                          _updateSignUpButtonState();
                                        },
                                        suffix: isVisible
                                            ? Text(
                                          '$minutes:$seconds',
                                          style: const TextStyle(fontSize: 12, color: colorMain900),
                                        )
                                            : null,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Gaps.h8,
                            ValueListenableBuilder(
                              valueListenable: tecEmailConfirm,
                              builder: (BuildContext context, value, Widget? child) {
                                return ValueListenableBuilder(
                                  valueListenable: vnIsAuthNumberMatch,
                                  builder: (context, isMatch, _) {
                                    return Expanded(
                                      flex: 2,
                                      child: BasicButton(
                                        title: isMatch ? '확인완료' : '인증확인',
                                        colorBg: tecEmailConfirm.text.isNotEmpty ? colorMain900 : colorGray100,
                                        onTap: _verifyCode,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        Gaps.v20,
                      ],
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: vnSignUpButtonEnabled,
                  builder: (context, enabled, _) {
                    return BasicButton(
                      title: '비밀번호 변경',
                      titleColorBg: enabled ? colorWhite : colorGray500,
                      colorBg: enabled ? colorMain900 : colorGray100,
                      onTap: enabled ? _findPw : null,
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

/*  Future<void> _sendSimpleTestEmail(BuildContext context) async {
    final result = await Utils.sendEmail(
      'karlhkim1@gmail.com',
      '테스트 이메일',
      '테스트이메일 전달'
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => DialogConfirm(desc: result ? '테스트이메일 전달' : 'Test Email Failed'),
    );
  }*/
}