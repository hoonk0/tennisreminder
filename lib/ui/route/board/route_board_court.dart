import 'package:flutter/foundation.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tennisreminder_core/const/value/colors.dart';

import '../../bottom_sheet/bottom_sheet_court_transfer.dart';
import '../../component/basic_button.dart';

class RouteBoardCourt extends StatelessWidget {
  const RouteBoardCourt({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Center(
                child: Text("코트 양도 게시판 탭 내용 여기에"),
              ),
            ),
          ],
        ),

        ///양도 글 버튼
        Positioned(
          bottom: 16,
          right: 5,
          child: GestureDetector(
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
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(8.0),
                  color: colorMain900
                ),
                child: Icon(Icons.add,color: colorWhite,))),
        ),
      ],
    );
  }
}
