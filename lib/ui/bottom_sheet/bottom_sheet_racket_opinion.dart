import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tennisreminder_app/ui/component/custom_divider.dart';
import 'package:tennisreminder_app/ui/component/textfield_border.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_core/utils_enum/utils_enum.dart';

import '../../const/static/global.dart';
import '../../service/utils/utils.dart';
import '../component/basic_button.dart';
import '../component/custom_dropdown.dart';


class BottomSheetRacketOpinion extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const BottomSheetRacketOpinion({Key? key, this.initialData}) : super(key: key);

  @override
  _BottomSheetRacketOpinionState createState() => _BottomSheetRacketOpinionState();
}

class _BottomSheetRacketOpinionState extends State<BottomSheetRacketOpinion> {
  late final TextEditingController tecRacketNameController;
  late final TextEditingController tecRacketOpinionController;

  late FocusNode focusRacketName;
  late FocusNode focusRacketOpinion;

  late ValueNotifier<RacketBrand?> vnRacketBrandNotifier;
  late final TextEditingController tecRacketWeightController;
  late final TextEditingController tecRacketHeadSizeController;

  @override
  void initState() {
    super.initState();
    tecRacketNameController = TextEditingController(
        text: widget.initialData?[keyRacketName] ?? '');
    tecRacketOpinionController = TextEditingController(
        text: widget.initialData?[keyRacketOpinion] ?? '');

    focusRacketName = FocusNode();
    focusRacketOpinion = FocusNode();

    vnRacketBrandNotifier = ValueNotifier<RacketBrand?>(
      widget.initialData?[keyRacketBrand] != null
          ? RacketBrand.values.firstWhere(
              (e) => e.name == widget.initialData![keyRacketBrand],
              orElse: () => RacketBrand.values.first)
          : null,
    );
    tecRacketWeightController = TextEditingController(text: widget.initialData?[keyRacketWeight] ?? '');
    tecRacketHeadSizeController = TextEditingController(text: widget.initialData?[keyRacketHeadSize] ?? '');
  }

  @override
  void dispose() {
    tecRacketNameController.dispose();
    tecRacketOpinionController.dispose();
    vnRacketBrandNotifier.dispose();
    tecRacketWeightController.dispose();
    tecRacketHeadSizeController.dispose();
    focusRacketName.dispose();
    focusRacketOpinion.dispose();
    super.dispose();
  }

  // 모든 날짜/시간/교환양도 관련 메서드 제거됨

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colorGray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Gaps.v10,
            Text('라켓 후기 글 작성', style: TS.s18w600(colorMain900)),
            Gaps.v20,
            /// 라켓 브랜드 선택
            Row(
              children: [
                Expanded(flex: 1, child: Text('브랜드')),
                Expanded(
                  flex: 4,
                  child: ValueListenableBuilder<RacketBrand?>(
                    valueListenable: vnRacketBrandNotifier,
                    builder: (context, selectBrand, _) {
                      return CustomDropdown<RacketBrand>(
                      value: selectBrand,
                      hint: Text(selectBrand == null ? '전체' : UtilsEnum.getNameFromRacketBrand(selectBrand)),
                      items: RacketBrand.values
                          .map(
                      (brand) => DropdownMenuItem(
                      value: brand,
                      child: Text(UtilsEnum.getNameFromRacketBrand(brand)),
                      ),
                      ).toList(),
                      onChanged: (state) {
                        vnRacketBrandNotifier.value = state;
                      },
                      );
                    },
                  ),
                ),
              ],
            ),
            Gaps.v10,
            /// 라켓 이름 입력
            Row(
              children: [
                Expanded(flex: 1, child: Text('라켓 이름')),
                Expanded(
                  flex: 4,
                  child: TextFieldBorder(
                    controller: tecRacketNameController,
                    focusNode: focusRacketName,
                    hintText: '라켓 이름을 입력하세요',
                  ),
                ),
              ],
            ),
            Gaps.v10,
            /// 라켓 무게 입력
            Row(
              children: [
                Expanded(flex: 1, child: Text('무게')),
                Expanded(
                  flex: 4,
                  child: TextFieldBorder(
                    controller: tecRacketWeightController,
                    hintText: '예: 300g',
                  ),
                ),
              ],
            ),
            Gaps.v10,
            /// 라켓 헤드 사이즈 입력
            Row(
              children: [
                Expanded(flex: 1, child: Text('헤드 사이즈')),
                Expanded(
                  flex: 4,
                  child: TextFieldBorder(
                    controller: tecRacketHeadSizeController,
                    hintText: '예: 100sq.in',
                  ),
                ),
              ],
            ),
            Gaps.v10,
            /// 후기 내용 입력
            Row(
              children: [
                Expanded(flex: 1, child: Text('후기')),
                Expanded(
                  flex: 4,
                  child: TextFieldBorder(
                    maxLines: 5,
                    controller: tecRacketOpinionController,
                    focusNode: focusRacketOpinion,
                    hintText: '라켓 사용 후기를 입력하세요',
                  ),
                ),
              ],
            ),
            Gaps.v10,
            BasicButton(
              title: '등록',
              onTap: () async {
                final brand = vnRacketBrandNotifier.value;
                final weight = tecRacketWeightController.text.trim();
                final headSize = tecRacketHeadSizeController.text.trim();
                final racketName = tecRacketNameController.text.trim();
                final opinion = tecRacketOpinionController.text.trim();
                if (brand == null ||
                    weight.isEmpty ||
                    headSize.isEmpty ||
                    racketName.isEmpty ||
                    opinion.isEmpty) {
                  Utils.toast(desc: '모든 정보를 입력하세요');
                  return;
                }

                final now = Timestamp.now();
                if (widget.initialData != null) {
                  // 기존 문서 업데이트
                  final docRef = FirebaseFirestore.instance
                      .collection(keyRacketOpinionBoard)
                      .doc(widget.initialData![keyRacketPostId]);
                  await docRef.update({
                    keyRacketBrand: brand.name,
                    keyRacketWeight: weight,
                    keyRacketHeadSize: headSize,
                    keyRacketName: racketName,
                    keyRacketOpinion: opinion,
                  });
                  Navigator.pop(context);
                } else {
                  // 새로 생성해 저장
                  final postId = FirebaseFirestore.instance.collection(keyRacketOpinionBoard).doc().id;
                  final data = {
                    keyRacketPostId: postId,
                    keyWriterUid: Global.userNotifier.value?.uid,
                    keyCreatedAt: now,
                    keyRacketBrand: brand.name,
                    keyRacketWeight: weight,
                    keyRacketHeadSize: headSize,
                    keyRacketName: racketName,
                    keyRacketOpinion: opinion,
                  };
                  await FirebaseFirestore.instance
                      .collection(keyRacketOpinionBoard)
                      .doc(postId)
                      .set(data);
                }
                Navigator.pop(context);
              },
            ),
            Gaps.v20,
          ],
        ),
      ),
    );
  }
}

// PhoneNumberFormatter 제거됨
