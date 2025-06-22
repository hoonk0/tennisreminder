import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../service/notification/court_notification_setting_upgrade.dart';
import '../component/basic_button.dart';

void BottomSheetCalendar(
    BuildContext context, {
      required ValueNotifier<DateTime?> vnSelectedDate,
      DateTime? firstSelectableDate, ///시작날짜
      required String reservationHour, // ✅ 추가
      required ModelCourt court,
    }) {
  showModalBottomSheet(
    backgroundColor: colorWhite,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => CalendarBottomSheet(
      vnSelectedDate: vnSelectedDate,
      firstSelectableDate: firstSelectableDate,
      reservationHour: reservationHour,
      court: court,
    ),
  );
}

class CalendarBottomSheet extends StatefulWidget {
  final ValueNotifier<DateTime?> vnSelectedDate;
  final DateTime? firstSelectableDate; //시작날짜
  final String reservationHour;
  final ModelCourt court;

  const CalendarBottomSheet({
    required this.vnSelectedDate,
    this.firstSelectableDate,
    required this.reservationHour,
    required this.court,
  });

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late final ValueNotifier<DateTime> vnFocusedDay;
  late final ValueNotifier<DateTime?> vnSelectedDay;
  late final ValueNotifier<bool> vnMonthDropdownOpen;

  @override
  void initState() {
    super.initState();
    vnFocusedDay = ValueNotifier(DateTime.now());
    vnSelectedDay = ValueNotifier(widget.vnSelectedDate.value);
    vnMonthDropdownOpen = ValueNotifier(false);
  }

  @override
  void dispose() {
    vnFocusedDay.dispose();
    vnSelectedDay.dispose();
    vnMonthDropdownOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: ValueListenableBuilder<DateTime>(
                  valueListenable: vnFocusedDay,
                  builder: (context, focusedDay, _) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 36),
                          // offset for dropdown button
                          child: TableCalendar(
                            locale: 'ko_KR',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2100, 12, 31),
                            focusedDay: focusedDay,
                            selectedDayPredicate:
                                (day) => isSameDay(vnSelectedDay.value, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              vnSelectedDay.value = selectedDay;
                              vnFocusedDay.value = focusedDay;
                            },
                            sixWeekMonthsEnforced: true,
                            calendarFormat: _calendarFormat,
                            availableCalendarFormats: const {
                              CalendarFormat.month: '월',
                            },
                            onFormatChanged: (format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            },
                            headerVisible: false,
                            enabledDayPredicate: (day) {
                              ///시작일이 설정되었다면, 시작일 이전인지 확인
                              if (widget.firstSelectableDate != null) {
                                return !day.isBefore(widget.firstSelectableDate!);
                              }

                              ///시작일 정해지지 않으면 모든날짜 선택가능
                              return true;
                            },
                            calendarStyle: CalendarStyle(
                              isTodayHighlighted: false,
                              selectedDecoration: BoxDecoration(
                                color: colorMain900,
                                shape: BoxShape.circle,
                              ),
                              selectedTextStyle: TextStyle(color: Colors.white),
                              defaultTextStyle: TS.s14w600(colorGray900), //이후날짜
                              outsideTextStyle: TS.s14w600(colorGray600),
                              disabledTextStyle: TS.s14w500(colorGray300),//이전날짜
                              markersAlignment: Alignment.bottomCenter,
                              markersMaxCount: 1,
                              markerDecoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),

                        ///월 선택 드롭다운버튼
                        ValueListenableBuilder<bool>(
                          valueListenable: vnMonthDropdownOpen,
                          builder: (context, isOpen, _) {
                            final year = vnFocusedDay.value.year;
                            final month = vnFocusedDay.value.month;
                            return Positioned(
                              top: 0,
                              left: 30.w,
                              right: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap:
                                        () =>
                                    vnMonthDropdownOpen.value =
                                    !vnMonthDropdownOpen.value,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$year년 $month월',
                                          style: TS.s20w600(colorBlack),
                                        ),
                                        Icon(
                                          isOpen
                                              ? Icons.keyboard_arrow_down
                                              : Icons.keyboard_arrow_up,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isOpen)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      constraints: const BoxConstraints(
                                        maxHeight: 200,
                                        maxWidth: 130,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12 ,
                                        ),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x23000000),
                                            // #00000014 in ARGB is 14% opacity = 0x23
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: 12,
                                        itemBuilder: (context, index) {
                                          final m = index + 1;
                                          return GestureDetector(
                                            onTap: () {
                                              final newDate = DateTime(
                                                year,
                                                m,
                                                1,
                                              );
                                              vnFocusedDay.value = newDate;
                                              vnMonthDropdownOpen.value = false;
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '$m월',
                                                    style: TS.s14w600(
                                                      m == month
                                                          ? colorMain900
                                                          : colorGray100,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 16,
                                                    color: m == month ? colorMain900 : Colors.transparent,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            ///날짜저장버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<DateTime?>(
                valueListenable: vnSelectedDay,
                builder: (context, date, _) {
                  return BasicButton(
                    title: date != null ? '${date.month}월 ${date.day}일 저장' : '날짜 선택',
                    onTap: () async {
                      if (date != null && widget.reservationHour.trim().isNotEmpty) {
                        try {
                          final parts = widget.reservationHour.trim().split(':');
                          final hour = int.tryParse(parts[0]);
                          final minute = parts.length > 1 ? int.tryParse(parts[1]) : 0;

                          if (hour != null && minute != null) {
                            final selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              hour,
                              minute,
                            ).subtract(const Duration(minutes: 10));
                            print('🕓 저장된 예약 시간: $selectedDateTime');
                            widget.vnSelectedDate.value = selectedDateTime;

                            // 알림 저장 호출
                            await CourtNotificationDaysBeforePlay.saveAlarmToFirestoreExternal(
                              court: widget.court,
                              selectedDateTime: selectedDateTime,
                            );
                          } else {
                            print("⚠️ 유효하지 않은 예약 시간 형식: ${widget.reservationHour}");
                          }
                        } catch (e) {
                          print("⚠️ 시간 파싱 중 오류: $e");
                        }
                      }
                      Navigator.pop(context);
                    },
                    colorBg: colorMain900,
                    titleColorBg: colorWhite,
                  );
                },
              ),
            ),
            Gaps.v20,
        ]
        ),
      ),
    );
  }
}
