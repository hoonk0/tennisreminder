import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/ui/route/auth/route_auth_login.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../../const/static/global.dart';
import '../../../service/utils/utils.dart';
import '../../component/basic_button.dart';
import '../../component/textfield_border.dart';
import '../../dialog/dialog_confirm.dart';

class RouteAuthPwChange extends StatefulWidget {
  final ModelUser modelUser;

  const RouteAuthPwChange({super.key, required this.modelUser});

  @override
  State<RouteAuthPwChange> createState() => _RouteAuthPwChangeState();
}

class _RouteAuthPwChangeState extends State<RouteAuthPwChange> {
  final TextEditingController tecNewPw = TextEditingController();
  final TextEditingController tecNewPwConfirm = TextEditingController();
  final ValueNotifier<bool> vnButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    tecNewPw.addListener(_updateButtonState);
    tecNewPwConfirm.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    tecNewPw.dispose();
    tecNewPwConfirm.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final passwordValid = _isPasswordValid(tecNewPw.text);
    vnButtonEnabled.value =
        tecNewPw.text.isNotEmpty &&
        tecNewPwConfirm.text.isNotEmpty &&
        tecNewPw.text == tecNewPwConfirm.text &&
        passwordValid;
    vnButtonEnabled.notifyListeners();
  }

  bool _isPasswordValid(String password) {
    final hasMinLength = password.length >= 8;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasMinLength && hasLetter && hasNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 변경')),
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
                        Text('변경할 비밀번호를 입력해주세요.',style: TS.s20w600(colorGray900),),
                        Gaps.v6,
                        Text('영문, 숫자 포함 8자리 이상 입력해주세요.',style: TS.s13w500(colorGray600),),
                        Gaps.v26,
                        const Text('비밀번호', style: TS.s14w500(colorGray900)),
                        Gaps.v10,
                        ValueListenableBuilder(
                          valueListenable: tecNewPw,
                          builder: (context, value, child) {
                            return TextFieldBorder(
                              controller: tecNewPw,
                              hintText: '비밀번호 입력',
                              obscureText: true,
                              errorText: tecNewPw.text.isEmpty || _isPasswordValid(tecNewPw.text)
                                  ? null
                                  : '8자리 이상, 영문/숫자 포함해야 합니다.',
                            );
                          },
                        ),
                        Gaps.v10,
                        TextFieldBorder(
                          controller: tecNewPwConfirm,
                          hintText: '비밀번호 재입력',
                          obscureText: true,
                        ),
                        ValueListenableBuilder(
                          valueListenable: tecNewPwConfirm,
                          builder: (context, value, child) {
                            final isMatch = tecNewPw.text.isNotEmpty && tecNewPw.text == tecNewPwConfirm.text;
                            return isMatch
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '비밀번호가 일치합니다.',
                                      style: TS.s13w500(colorMain900),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                        Gaps.v20,
                      ],
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: vnButtonEnabled,
                  builder: (context, enabled, _) {
                    return BasicButton(
                      title: '변경 완료',
                      titleColorBg: enabled ? colorWhite : colorGray500,
                      colorBg: enabled ? colorMain900 : colorGray100,
                      onTap: enabled ? _completeChangePassword : null,
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

  void _completeChangePassword() async {
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final userDoc = FirebaseFirestore.instance.collection(keyUser).doc(widget.modelUser.uid);
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        Utils.toast(desc: '유저 정보가 존재하지 않습니다.');
        return;
      }

      await userDoc.update({keyPassword: tecNewPw.text});

      Utils.toast(desc: '비밀번호가 변경되었습니다. 재로그인 해주시기 바랍니다.');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RouteAuthLogin()),
        (route) => false,
      );
    } catch (e) {
      Utils.toast(desc: '비밀번호 변경 실패: ${e.toString()}');
    }
  }
}
