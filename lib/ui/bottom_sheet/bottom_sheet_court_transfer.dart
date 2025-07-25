import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tennisreminder_app/ui/component/custom_divider.dart';
import 'package:tennisreminder_app/ui/component/textfield_border.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../const/static/global.dart';
import '../../service/utils/utils.dart';
import '../component/basic_button.dart';


class BottomSheetCourtTransfer extends StatefulWidget {
  @override
  _BottomSheetCourtTransferState createState() => _BottomSheetCourtTransferState();
}

class _BottomSheetCourtTransferState extends State<BottomSheetCourtTransfer> {
  bool isExchange = false;
  bool isTransfer = false;
  late final TextEditingController tecCourtNameController;
  late final TextEditingController tecContactController;
  late final TextEditingController tecExtraInfoController;
  late final ValueNotifier<DateTime?> selectedDateNotifier;
  late final ValueNotifier<TimeOfDay?> startTimeNotifier;
  late final ValueNotifier<TimeOfDay?> endTimeNotifier;

  late final ValueNotifier<bool> vnExchangeTransferOption;

  @override
  void initState() {
    super.initState();
    tecCourtNameController = TextEditingController();
    tecContactController = TextEditingController();
    tecExtraInfoController = TextEditingController();
    selectedDateNotifier = ValueNotifier<DateTime?>(null);
    startTimeNotifier = ValueNotifier<TimeOfDay?>(null);
    endTimeNotifier = ValueNotifier<TimeOfDay?>(null);
    vnExchangeTransferOption = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    tecCourtNameController.dispose();
    tecContactController.dispose();
    tecExtraInfoController.dispose();
    selectedDateNotifier.dispose();
    startTimeNotifier.dispose();
    endTimeNotifier.dispose();
    vnExchangeTransferOption.dispose();
    super.dispose();
  }

  void pickDate() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인", style: TextStyle(color: colorMain900)),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<DateTime?>(
                valueListenable: selectedDateNotifier,
                builder: (context, selectedDate, _) {
                  return CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate ?? DateTime.now(),
                    onDateTimeChanged: (dateTime) {
                      selectedDateNotifier.value = dateTime;
                      print('📅 선택한 날짜: $dateTime');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pickStartTime() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인", style: TS.s16w500(colorMain900)),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<TimeOfDay?>(
                valueListenable: startTimeNotifier,
                builder: (context, startTime, _) {
                  return CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      2024,
                      1,
                      1,
                      startTime?.hour ?? 9,
                      startTime?.minute ?? 0,
                    ),
                    use24hFormat: true,
                    onDateTimeChanged: (dateTime) {
                      startTimeNotifier.value = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
                      print('⏰ 시작 시간: ${startTimeNotifier.value?.format(context)}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pickEndTime() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인", style: TS.s16w500(colorMain900)),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<TimeOfDay?>(
                valueListenable: endTimeNotifier,
                builder: (context, endTime, _) {
                  return CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      2024,
                      1,
                      1,
                      endTime?.hour ?? 10,
                      endTime?.minute ?? 0,
                    ),
                    use24hFormat: true,
                    onDateTimeChanged: (dateTime) {
                      endTimeNotifier.value = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
                      print('⏰ 종료 시간: ${endTimeNotifier.value?.format(context)}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submit() {
    final selectedDate = selectedDateNotifier.value;
    final startTime = startTimeNotifier.value;
    final endTime = endTimeNotifier.value;
    if (tecCourtNameController.text.isEmpty ||
        selectedDate == null ||
        startTime == null ||
        endTime == null ||
        tecContactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("모든 항목을 입력해주세요")));
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

          Text('교환/양도 글 작성',style: TS.s18w600(colorMain900),),
          Gaps.v20,

          ///코트이름
          Row(children: [
            Expanded(
                flex:1,child: Text('코트 이름')),
            Expanded(flex: 4,child: TextFieldBorder(controller: tecCourtNameController)),
          ],),

          Gaps.v10,
          ///교환 양도 선택
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('교환/양도'),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        vnExchangeTransferOption.value = true;
                        isExchange = false;
                      },
                      child: ValueListenableBuilder(
                        valueListenable: vnExchangeTransferOption,
                        builder: (_, value, __) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: value ? colorMain900 : colorGray300),
                              borderRadius: BorderRadius.circular(8),
                              color: value ? colorMain900 : colorWhite,
                            ),
                            child: const Text('교환 중'),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        vnExchangeTransferOption.value = false;
                        isTransfer = false;
                      },
                      child: ValueListenableBuilder(
                        valueListenable: vnExchangeTransferOption,
                        builder: (_, value, __) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: !value ? colorMain900 : colorGray300),
                              borderRadius: BorderRadius.circular(8),
                              color: !value ? colorMain900 : colorWhite,
                            ),
                            child: const Text('양도 중'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Gaps.v10,

          ///코트 예약날짜
          Row(
            children: [
              Expanded(flex:1, child: Text('예약 날짜')),
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorGray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today),
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: selectedDateNotifier,
                          builder: (context, date, _) {
                            return Text(
                              date != null
                                  ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                                  : '날짜 선택',
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                        ),
                        const SizedBox.shrink(), // For layout alignment
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gaps.v10,

          ///코트 예약 시간
          Row(
            children: [
              Expanded(flex: 1, child: Text('예약 시간')),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: pickStartTime,
                        child: ValueListenableBuilder<TimeOfDay?>(
                          valueListenable: startTimeNotifier,
                          builder: (context, time, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorGray200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.access_time),
                                  Text(
                                    time != null ? time.format(context) : '시작시간',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text('')
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Gaps.h5,
                    Text('-'),
                    Gaps.h5,
                    Expanded(
                      child: GestureDetector(
                        onTap: pickEndTime,
                        child: ValueListenableBuilder<TimeOfDay?>(
                          valueListenable: endTimeNotifier,
                          builder: (context, time, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorGray200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.access_time),
                                  Text(
                                    time != null ? time.format(context) : '종료시간',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text("")
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
          Gaps.v10,

          ///연락처
          Row(
            children: [
              Expanded(flex: 1, child: Text('연락처')),
              Expanded(
                flex: 4,
                child: TextFieldBorder(
                  hintText: '핸드폰, 오픈카톡 등 연락처를 입력하세요',
                  controller: tecContactController,
                  /*      keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    PhoneNumberFormatter(),
                  ],*/
                ),
              ),
            ],
          ),
          Gaps.v10,

          ///추가정보
          Row(
            children: [
              Expanded(flex: 1, child: Text('추가 정보')),
              Expanded(
                flex: 4,
            child: TextFieldBorder(
              maxLines: 3,
              hintText: '교환방법, 유료 여부 등',
              controller: tecExtraInfoController,
            ),
              ),
            ],
          ),
          Gaps.v10,
          BasicButton(
            title: '등록',
            onTap: () async {
              final selectedDate = selectedDateNotifier.value;
              final startTime = startTimeNotifier.value;
              final endTime = endTimeNotifier.value;

              if (tecCourtNameController.text.isEmpty ||
                  selectedDate == null ||
                  startTime == null ||
                  endTime == null ||
                  tecContactController.text.isEmpty) {
                Utils.toast(desc: '모든 정보를 입력하세요');
                return;
              }

              final postId = FirebaseFirestore.instance.collection('court_transfers').doc().id;
              final now = Timestamp.now();

              final data = {
                keyPostId: postId,
                keyTransferBoardWriter: Global.userNotifier.value?.toJson(),
                keyCreatedAt: now,
                keyIsExchange: isExchange,
                keyIsTransfer: isTransfer,
                keyTransferCourtName: tecCourtNameController.text,
                keyTransferDate: selectedDate.toIso8601String(),
                keyTransferStartTime: '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                keyTransferEndTime: '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
                keyContact: tecContactController.text,
                keyTransferExtraInfo: tecExtraInfoController.text,
              };

              await FirebaseFirestore.instance
                  .collection(keyCourtTransferBoard)
                  .doc(postId)
                  .set(data);

              Navigator.pop(context);
            },
          ),
          Gaps.v20,
        ],
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length && i < 11; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digitsOnly[i]);
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
