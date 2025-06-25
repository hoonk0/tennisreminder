import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';


class LoadingBar extends StatelessWidget {
  const LoadingBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 120,
        height: 8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorMain900),
            backgroundColor: colorMain900.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}