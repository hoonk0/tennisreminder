import 'package:flutter/material.dart';

import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';

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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: court.imageUrls != null && court.imageUrls!.isNotEmpty
                      ? NetworkImage(court.imageUrls!.first)
                      : const AssetImage('assets/images/mainlogo.png') as ImageProvider,
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
                      style: TextStyle(
                        color: colorMain900,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Gaps.v4,
                    Text(
                      court.courtAddress,
                      style: TextStyle(
                        color: colorMain900.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}