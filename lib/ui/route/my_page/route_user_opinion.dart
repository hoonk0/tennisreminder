import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_app/ui/component/basic_button_shadow.dart';
import 'package:tennisreminder_core/const/model/model_opinion.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

import '../../component/textfield_border.dart';

class RouteUserOpinion extends StatelessWidget {
  const RouteUserOpinion({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController tecTitle = TextEditingController();
    final TextEditingController tecContent = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('의견 보내기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFieldBorder(
                controller: tecTitle,
                hintText: '제목을 입력하세요 (30자 이내)',
                maxLength: 30,
                maxLines: 1,
              ),
              Gaps.v12,
              Expanded(
                child: TextFieldBorder(
                  controller: tecContent,
                  hintText: '의견 내용을 입력하세요',
                  maxLines: null,
                  expands: true,
                ),
              ),
              Gaps.v16,
              BasicButtonShadow(
                title: '제출하기',
                showIcon: false,
                onTap: () async {
                  if (tecTitle.text.trim().isEmpty ||
                      tecContent.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
                    );
                    return;
                  }

                  final opinion = ModelUserOpinion(
                    opinionUid: const Uuid().v4(),
                    title: tecTitle.text.trim(),
                    uid: keyUserUid,
                    content: tecContent.text.trim(),
                    dateCreate: Timestamp.now(),
                    email: null,
                  );

                  print('[DEBUG] keyUserOpinion: $keyUserOpinion');

                  await FirebaseFirestore.instance
                      .collection(keyUserOpinion)
                      .doc(opinion.opinionUid)
                      .set(opinion.toJson());

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('의견이 성공적으로 제출되었습니다.')),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
