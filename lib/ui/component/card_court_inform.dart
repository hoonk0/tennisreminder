import 'package:flutter/material.dart';

import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

class CardCourtInform extends StatelessWidget {
  final ModelCourt court;
  final VoidCallback? onTap;

  const CardCourtInform({
    super.key,
    required this.court,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft:Radius.circular(8) ),
                  child: Image(
                    image: court.imageUrls != null && court.imageUrls!.isNotEmpty
                        ? NetworkImage(court.imageUrls!.first)
                        : const AssetImage('assets/images/mainicon.png') as ImageProvider,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Gaps.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        court.courtName,
                          style: TS.s12w500(colorGray700),
                      ),
                      Gaps.v4,
                      Text(
                        court.courtAddress,
                        style: TS.s12w500(colorGray500),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}