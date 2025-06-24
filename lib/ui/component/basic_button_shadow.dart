import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

class BasicButtonShadow extends StatelessWidget {
  final String title;
  final Color colorBg;
  final Color titleColorBg;
  final double titleFontSize;
  final double width;
  final void Function()? onTap;
  final Color borderColor;
  final bool showIcon;

  const BasicButtonShadow({
    required this.title,
    this.colorBg = colorMain900,
    this.width = double.infinity,
    this.titleColorBg = colorGray900,
    this.titleFontSize = 18,
    this.borderColor = Colors.transparent,
    this.showIcon = true,
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
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Image.asset(
                'assets/images/mainicon.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
              Gaps.h5,
            ],
            Text(
                title,
                style: TS.s16w600(colorMain900),

            ),
          ],
        ),
      ),
    );
  }
}
