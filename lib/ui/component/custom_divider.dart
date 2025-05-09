import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tennisreminder_core/const/value/colors.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final double width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;

  const CustomDivider({
    this.height = 1,
    this.width = 1,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.color = colorGray300,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      color: color,
    );
  }
}
