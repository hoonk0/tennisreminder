import 'package:flutter/foundation.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tennisreminder_core/const/value/colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

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
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('게시글이 없습니다.');
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data[keyTransferCourtName] ?? '코트 이름 없음'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('날짜: ${data[keyTransferDate] ?? ''}'),
                            Text('시간: ${data[keyTransferStartTime]} ~ ${data[keyTransferEndTime]}'),
                            Text('연락처: ${data[keyContact] ?? ''}'),
                            Text('교환 여부: ${data[keyIsExchange] == true ? '교환' : '양도'}'),
                            if ((data[keyTransferExtraInfo] ?? '').isNotEmpty)
                              Text('추가정보: ${data[keyTransferExtraInfo]}'),
                          ],
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
