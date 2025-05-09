
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';

class BasicButton extends StatelessWidget {
  final String title;
  final Color colorBg;
  final Color titleColorBg;
  final double titleFontSize;
  final double width;
  final void Function()? onTap;
  final Color borderColor;

  const BasicButton({
    required this.title,
    this.colorBg = colorMain900,
    this.width = double.infinity,
    this.titleColorBg = colorWhite,
    this.titleFontSize = 18,
    this.borderColor = Colors.transparent,
    required this.onTap,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1), // ✅ 추가: 테두리 적용
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: colorBg,
        ),
        child: Center(
          child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: titleFontSize,
                  color: titleColorBg
              )

          ),
        ),
      ),
    );
  }
}
