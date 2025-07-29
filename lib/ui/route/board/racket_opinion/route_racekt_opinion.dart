import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';
import 'package:tennisreminder_app/ui/component/custom_dropdown.dart';
import 'package:tennisreminder_app/ui/component/loading_bar.dart';
import 'package:tennisreminder_app/ui/route/board/court_transfer_exchange/route_board_court_transfer_detail.dart';
import 'package:tennisreminder_core/const/model/model_racket_opinion.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tennisreminder_core/const/value/colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:tennisreminder_core/utils_enum/utils_enum.dart';

import '../../../bottom_sheet/bottom_sheet_court_transfer.dart';
import '../../../component/basic_button.dart';
import '../../../component/basic_button_shadow.dart';

class RouteRacketOpinion extends StatelessWidget {
  final ValueNotifier<TradeState?> vnTradeStateSelect = ValueNotifier<TradeState?>(null);
   RouteRacketOpinion({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ///게시글 필터
           /* Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: ValueListenableBuilder<TradeState?>(
                  valueListenable: vnTradeStateSelect,
                  builder: (context, selectedState, _) {
                    return SizedBox(
                      width: 25.w,
                      child: CustomDropdown<TradeState>(
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
                      ),
                    );
                  },
                ),
              ),
            ),*/

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
                      final allOpinions = allDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ModelRacketOpinion.fromJson(data);
                      }).toList();

                      final filteredOpinions = selectedState == null
                          ? allOpinions
                          : allOpinions.where((opinion) {
                              return selectedState == TradeState.transferOngoing; // Placeholder: Update this if filtering is implemented for this model.
                            }).toList();

                      return ListView.separated(
                        itemCount: filteredOpinions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final opinion = filteredOpinions[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0,2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Gaps.v8,
                                Text(
                                  '${opinion.racketBrand} ${opinion.racketName}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Gaps.v8,
                                Text('무게: ${opinion.racketWeight} / 헤드사이즈: ${opinion.racketHeadSize}'),
                                if (opinion.racketOpinion != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('의견: ${opinion.racketOpinion}'),
                                  ),
                              ],
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
