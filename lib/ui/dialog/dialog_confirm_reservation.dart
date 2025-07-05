import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../ui/component/custom_divider.dart';

class DialogConfirmReservation extends StatelessWidget {
  final String desc;
  final EdgeInsets insetPadding;

  const DialogConfirmReservation({
    required this.desc,
    this.insetPadding = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: insetPadding,
      backgroundColor: colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: colorWhite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gaps.v42,
            Text(
              desc,
              style: const TS.s16w500(colorGray900),
              textAlign: TextAlign.center,
            ),
            Gaps.v42,
            const CustomDivider(
              color: colorGray300,
              height: 1,
            ),
            _Button(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final void Function()? onTap;

  const _Button({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: const Center(
          child: Text(
            '확인',
            style: TS.s18w600(colorMain900),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
