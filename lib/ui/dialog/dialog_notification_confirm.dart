import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../component/custom_divider.dart';

class DialogNotificationConfirm extends StatelessWidget {
  final String weekday;
  final int hour;
  final int minute;
  final EdgeInsets insetPadding;

  const DialogNotificationConfirm({
    required this.weekday,
    required this.hour,
    required this.minute,
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
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_outlined, color: colorMain900, size: 40),
            Gaps.v16,
            Text(
              '$weekday ${hour.toString().padLeft(2, '0')}시 ${minute.toString().padLeft(2, '0')}분에 테니스 코트 예약 알림을 보내드릴게요.',
              style: const TS.s16w500(colorGray900),
              textAlign: TextAlign.center,
            ),
            Gaps.v24,
            const CustomDivider(
              color: colorGray300,
              height: 1,
            ),
            Gaps.v8,
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorMain900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '확인',
            style: TS.s18w600(colorWhite),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
