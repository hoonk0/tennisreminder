import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../../const/static/global.dart';


class RouteCourtTransferDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final ValueNotifier<bool> vnSelectTransferOption = ValueNotifier(false);

  RouteCourtTransferDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교환/양도 글'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (Global.userNotifier.value?.uid == data[keyTransferBoardWriter]?[keyUid])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorGray500,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '편집',
                      style: TS.s14w600(colorWhite),
                    ),
                  ),
                Gaps.h5,
                // 교환/양도/완료 버튼
                if (Global.userNotifier.value?.uid == data[keyTransferBoardWriter]?[keyUid])
                  Container(

                  )
              ],
            ),
            Gaps.v20,
            Text(
              data[keyTransferCourtName] ?? '코트 이름 없음',
              style: TS.s20w700(colorGray900),
            ),
            Gaps.v16,
            Text('날짜', style: TS.s16w600(colorGray900)),
            Gaps.v4,
            Text('${data[keyTransferDate]?.toString().split('T').first ?? ''}', style: TS.s16w400(colorGray800)),
            Gaps.v12,
            Text('시간', style: TS.s16w600(colorGray900)),
            Gaps.v4,
            Text('${data[keyTransferStartTime]} ~ ${data[keyTransferEndTime]}', style: TS.s16w400(colorGray800)),
            Gaps.v12,
            Text('연락처', style: TS.s16w600(colorGray900)),
            Gaps.v4,
            Text(data[keyContact] ?? '-', style: TS.s16w400(colorGray800)),
            if ((data[keyTransferExtraInfo] ?? '').isNotEmpty) ...[
              Gaps.v12,
              Text('추가정보', style: TS.s16w600(colorGray900)),
              Gaps.v4,
              Text(data[keyTransferExtraInfo], style: TS.s16w400(colorGray800)),
            ],
          ],
        ),
      ),
    );
  }
}
