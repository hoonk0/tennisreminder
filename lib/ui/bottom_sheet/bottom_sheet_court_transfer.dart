import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tennisreminder_app/ui/component/custom_divider.dart';
import 'package:tennisreminder_app/ui/component/textfield_border.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../component/basic_button.dart';


class BottomSheetCourtTransfer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final courtNameController = TextEditingController();
    final contactController = TextEditingController();
    final selectedDateNotifier = ValueNotifier<DateTime?>(null);
    final startTimeNotifier = ValueNotifier<TimeOfDay?>(null);
    final endTimeNotifier = ValueNotifier<TimeOfDay?>(null);
    final ValueNotifier<bool> vnTransferOption = ValueNotifier<bool>(false);

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
                  onPressed: () => Navigator.of(context).pop(),
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
                child:
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                child:
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
      if (courtNameController.text.isEmpty ||
          selectedDate == null ||
          startTime == null ||
          endTime == null ||
          contactController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("모든 항목을 입력해주세요")));
        return;
      }
      Navigator.pop(context);
    }

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
            Expanded(flex: 4,child: TextFieldBorder()),
          ],),

          Gaps.v10,
          ///교환 양도 선택
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('교환/양도'
                ),
              ),
              Expanded(
                flex: 4,
                child: ValueListenableBuilder<bool>(
                  valueListenable: vnTransferOption,
                  builder: (context, isExchange, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vnTransferOption.value = true,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isExchange ? colorMain900 : colorGray200,
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '교환',
                                style: TextStyle(
                                  color: isExchange ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => vnTransferOption.value = false,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isExchange ? colorMain900 : colorGray200,
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '양도',
                                style: TextStyle(
                                  color: !isExchange ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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


          ///연락처
          Row(
            children: [
              Expanded(flex: 1, child: Text('연락처')),
              Expanded(
                flex: 4,
                child: TextFieldBorder(
                  hintText: '전화번호/오픈카톡 등 입력',
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
            ),
              ),
            ],
          ),
          Gaps.v10,
          BasicButton(title: '등록', onTap: (){}),
          Gaps.v20,
        ],
      ),
    );
  }
}
