import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/ui/dialog/dialog_YN.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:tennisreminder_core/utils_enum/utils_enum.dart';

import '../../../../const/static/global.dart';
import '../../../bottom_sheet/bottom_sheet_court_transfer.dart';


class RouteCourtTransferDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final ValueNotifier<bool> vnSelectTransferOption = ValueNotifier(false);

  RouteCourtTransferDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currentStateRaw = data[keyTradeState];
    final currentState = UtilsEnum.getTradeStateFromRaw(currentStateRaw);

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
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return Padding(
                              padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 16,),
                            child: BottomSheetCourtTransfer(
                              initialData: data,
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
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
                  ),
                Gaps.h5,
           // 교환/양도/완료 버튼
                Builder(
                  builder: (context) {
                    final isOwner = Global.userNotifier.value?.uid == data[keyTransferBoardWriter]?[keyUid];
                    final stateName = UtilsEnum.getNameFromTradeStateRaw(data[keyTradeState]);
                    Color bgColor;
                    switch (stateName) {
                      case '교환':
                        bgColor = Colors.blue;
                        break;
                      case '양도':
                        bgColor = Colors.green;
                        break;
                      case '완료':
                        bgColor = Colors.grey;
                        break;
                      default:
                        bgColor = Colors.black;
                    }
                    final statusWidget = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stateName,
                        style: TS.s14w600(colorWhite),
                      ),
                    );

                    if (!isOwner) return statusWidget;

                    return GestureDetector(
                      onTap: () async {
                        final docRef = FirebaseFirestore.instance
                            .collection(keyCourtTransferBoard)
                            .doc(data[keyPostId]);

                        final currentStateRaw = data[keyTradeState];
                        final currentState = UtilsEnum.getTradeStateFromRaw(currentStateRaw);
                        debugPrint('🟡 현재 상태: $currentState');
                        debugPrint('🟡 완료 상태와 비교: ${currentState != TradeState.done}');

                        if (currentState != TradeState.done) {
                          final result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => DialogYN(
                              desc: '상태를 완료로 바꾸시겠어요?',
                              onTapYes: () async {
                                await docRef.update({keyTradeState: TradeState.done.name});
                                debugPrint('✅ 상태가 완료로 변경됨');
                                Navigator.of(context).pop(true);
                              },
                              title: '양도/교환 완료',
                              buttonLabelLeft: '네',
                              buttonLabelRight: '아니요',
                            ),
                          );
                          debugPrint('✅ 다이얼로그 결과: $result');
                        }
                      },
                      child: statusWidget,
                    );
                  },
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
