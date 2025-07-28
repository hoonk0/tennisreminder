import 'package:flutter/foundation.dart';
import 'package:tennisreminder_app/ui/component/custom_dropdown.dart';
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
  final ValueNotifier<TradeState?> vnTradeStateSelect = ValueNotifier<TradeState?>(null);
   RouteBoardCourt({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ///게시글 필터
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: ValueListenableBuilder<TradeState?>(
                valueListenable: vnTradeStateSelect,
                builder: (context, selectedState, _) {
                  return CustomDropdown<TradeState>(
                    value: selectedState,
                    hint: Text(selectedState == null ? '전체' : UtilsEnum.getNameFromTradeState(selectedState)),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('전체')),
                      DropdownMenuItem(value: TradeState.exchangeOngoing, child: Text('교환')),
                      DropdownMenuItem(value: TradeState.transferOngoing, child: Text('양도')),
                      DropdownMenuItem(value: TradeState.done, child: Text('완료')),
                    ],
                    onChanged: (state) {
                      vnTradeStateSelect.value = state;
                    },
                  );
                },
              ),
            ),

            ///게시글 리스트
            Expanded(
              child: ValueListenableBuilder<TradeState?>(
                valueListenable: vnTradeStateSelect,
                builder: (context, selectedState, _) {
                  return StreamBuilder<QuerySnapshot>(
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

                      final allDocs = snapshot.data!.docs;
                      print('🔍 선택된 상태: $selectedState');
                      for (final doc in allDocs) {
                        print('📄 게시글 상태: ${doc[keyTradeState]}');
                      }

                      final filteredDocs = selectedState == null
                          ? allDocs
                          : allDocs.where((doc) {
                              final stateRaw = doc[keyTradeState];
                              return stateRaw == selectedState.name;
                            }).toList();
                      print('✅ 필터링된 게시글 수: ${filteredDocs.length}');

                      return ListView.separated(
                        itemCount: filteredDocs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
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
                                        style: TS.s14w400(colorWhite),
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
                  );
                },
              ),
            ),
          ],
        ),

        ///게시글 쓰기 버튼
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
