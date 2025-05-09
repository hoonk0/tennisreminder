import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';

class CardCourtPreview extends StatelessWidget {
  final String imagePath;
  final String courtName;
  final double width;
  final double? height;

  const CardCourtPreview({
    super.key,
    required this.imagePath,
    required this.courtName,
    this.width = 120,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
         color: colorGray300
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: width,
              height: height ?? 120, // 고정 높이로 안정적
              fit: BoxFit.cover,
            ),
          ),
          Gaps.v4,
          Text(
            courtName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}