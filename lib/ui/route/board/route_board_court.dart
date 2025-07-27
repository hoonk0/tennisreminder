import 'package:flutter/foundation.dart';
import 'package:tennisreminder_app/ui/component/loading_bar.dart';
import 'package:tennisreminder_app/ui/route/board/route_board_court_transfer_detail.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tennisreminder_core/const/value/colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:tennisreminder_core/utils_enum/utils_enum.dart';

import '../../bottom_sheet/bottom_sheet_court_transfer.dart';
import '../../component/basic_button.dart';
import '../../component/basic_button_shadow.dart';

class RouteBoardCourt extends StatelessWidget {
  const RouteBoardCourt({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(keyCourtTransferBoard)
                    .orderBy(keyCreatedAt, descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingBar();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('게시글이 없습니다.');
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => Text(''),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                     final tradeStateRaw = (data[keyTradeState] ?? '').toString().trim();
                     final tradeState = TradeState.values.firstWhere(
                       (e) => e.name == tradeStateRaw,
                       orElse: () => TradeState.transferOngoing,
                     );

                     return GestureDetector(
                       onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => RouteCourtTransferDetail(data: data),
                           ),
                         );
                       },
                       child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Gaps.v8,
                                  Text(
                                    data[keyTransferCourtName] ?? '코트 이름 없음',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Gaps.v8,
                                  Text('날짜: ${data[keyTransferDate]?.toString().split('T').first ?? ''}'),
                                  Text('시간: ${data[keyTransferStartTime]} ~ ${data[keyTransferEndTime]}'),
                   /*               Text('연락처: ${data[keyContact] ?? ''}'),
                                    if ((data[keyTransferExtraInfo] ?? '').isNotEmpty)
                                      Text('추가정보: ${data[keyTransferExtraInfo]}'),*/
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (tradeState == TradeState.transferOngoing)
                                        ? Colors.green
                                        : (tradeState == TradeState.exchangeOngoing)
                                            ? Colors.blue
                                            : Colors.grey,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Text(
                                    UtilsEnum.getNameFromTradeState(TradeState.values.firstWhere(
                                          (e) => e.name == data[keyTradeState],
                                      orElse: () => TradeState.transferOngoing,
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                     );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: BasicButtonShadow(
            title: "교환/양도 글 쓰기",
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: colorWhite,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: BottomSheetCourtTransfer(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
