import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../component/custom_divider.dart';

class DialogLogout extends StatelessWidget {
  final String title;
  final String desc;
  final String buttonLabel;
  final VoidCallback onTapLogOut;
  final String imagePath;

  const DialogLogout({
    required this.desc,
    required this.onTapLogOut,
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gaps.v30,
/*          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: colorMain900,
            ),
            child: Center(
              child: SvgPicture.asset(
                imagePath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Gaps.v20,*/
          Text(
            title,
            style: const TS.s16w600(colorMain900),
            textAlign: TextAlign.center,
          ),
          Gaps.v4,
          Text(
            desc,
            style: const TS.s14w400(colorGray600),
            textAlign: TextAlign.center,
          ),
          Gaps.v20,
          const CustomDivider(
            color: colorGray300,
            height: 1,
            width: double.infinity,
          ),
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  label: buttonLabel,
                  textColor: colorGray500,
                  onTap: onTapLogOut, // 로그아웃 동작
                ),
              ),
              const CustomDivider(
                width: 1,
                height: 48,
                color: colorGray200,
              ),
              Expanded(
                child: _DialogButton(
                  label: '다음에',
                  textColor: colorMain900,
                  onTap: () {
                    Navigator.of(context).pop(); // 다이얼로그만 닫음
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 직접 onTap 호출, pop() 분리
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TS.s18w500(textColor),
        ),
      ),
    );
  }
}