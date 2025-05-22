
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../route/home/route_court_information.dart';

class CardCourtSummary extends StatelessWidget {
  final ModelCourt court;

  const CardCourtSummary({required this.court, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RouteCourtInformation(court: court),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: court.imageUrls?.isNotEmpty == true
                ? Image.network(
              court.imageUrls!.first,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/images/mainicon.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Gaps.v8,
          Text(
            '한국 ${court.courtAddress ?? "위치 정보 없음"}',
            style: TS.s12w500(colorGray700),
          ),
          Gaps.v4,
          Text(
            '${court.courtDistrict ?? "위치 미지정"} · ${court.courtInfo.isNotEmpty ? court.courtInfo : "정보 없음"}',
            style: TS.s12w500(colorGray500),
          ),
          Gaps.v4,
          Text(
            '게스트 한마디 “${court.extraInfo?["guest_comment"] ?? "후기 정보 없음"}”',
            style: TS.s12w500(colorGray500),
          ),
          Gaps.v4,
        ],
      ),
    );
  }
}