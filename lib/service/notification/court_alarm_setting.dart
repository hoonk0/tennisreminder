import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tennisreminder_app/service/notification/dialog_confirm.dart';
import 'package:tennisreminder_app/ui/component/basic_button.dart';
import 'package:tennisreminder_app/ui/dialog/dialog_notification_confirm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

class CourtAlarmSettings extends StatefulWidget {
  final ValueNotifier<bool> vnAlarmSet;

  const CourtAlarmSettings({super.key, required this.vnAlarmSet});

  @override
  State<CourtAlarmSettings> createState() => _CourtAlarmSettingsState();
}

class _CourtAlarmSettingsState extends State<CourtAlarmSettings> {
  final selectedWeekday = ValueNotifier<int>(DateTime.monday);

  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);
  final weekdays = {
    DateTime.monday: '월요일',
    DateTime.tuesday: '화요일',
    DateTime.wednesday: '수요일',
    DateTime.thursday: '목요일',
    DateTime.friday: '금요일',
    DateTime.saturday: '토요일',
    DateTime.sunday: '일요일',
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print('🟢 initState 실행됨');
    _getFcmToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 포그라운드 수신됨: ${message.notification?.title}');
      if (message.notification != null) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(message.notification!.title ?? '알림'),
                content: Text(message.notification!.body ?? '내용 없음'),
              ),
        );
      }
    });
  }

  Future<String?> _getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('📲 FCM Token Retrieved in init: $token');
      } else {
        print('⚠️ FCM Token is null');
      }
      return token;
    } catch (e) {
      print('❌ Failed to get FCM Token: $e');
      return null;
    }
  }

  Future<void> saveAlarmToFirestore() async {
    try {
      final fcmToken = await _getFcmToken();
      if (fcmToken == null) throw Exception('FCM 토큰을 가져올 수 없습니다.');
      print('📲 FCM Token Retrieved in init: $fcmToken');
      final data = {
        keyCourtUid: 'court_uid_123', // 실제 courtUid로 변경
        keyUserUid: 'user_uid_123', // 실제 userUid로 변경
        keyAlarmWeekday: selectedWeekday.value,
        keyAlarmHour: selectedTime.hour,
        keyAlarmMinute: selectedTime.minute,
        keyDateCreate: Timestamp.now(),
        keyAlarmEnabled: true,
        keyFcmToken: fcmToken,
      };
      print('📲 FCM Token Retrieved in init: $fcmToken');
      print('📝 저장될 알람 정보: $data'); // 추가된 로그

      await _firestore.collection(keyCourtAlarms).add(data);

      showDialog(
        context: context,
        builder: (_) => DialogNotificationConfirm(
          weekday: weekdays[selectedWeekday.value] ?? '',
          hour: selectedTime.hour,
          minute: selectedTime.minute,
        ),
      );

      // Update ValueNotifier state
      widget.vnAlarmSet.value = true;


/*
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('알림이 설정되었습니다.')));*/
    } catch (e) {
      print('❌ 알림 설정 실패: $e'); // 에러 로그 추가
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('알림 설정 중 오류가 발생했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: selectedWeekday,
          builder: (context, value, _) {
            return SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weekdays.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final key = weekdays.keys.elementAt(index);
                  final label = weekdays[key]!;
                  final isSelected = value == key;

                  return GestureDetector(
                    onTap: () {
                      selectedWeekday.value = key;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? colorMain900 : colorWhite,
                        border: Border.all(
                          color: isSelected ? colorBlue500 : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        Gaps.v10,

        GestureDetector(
          onTap: () async {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: colorWhite,
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedTime.hour,
                        ),
                        onSelectedItemChanged: (value) {
                          setState(() {
                            selectedTime = TimeOfDay(
                              hour: value,
                              minute: selectedTime.minute,
                            );
                          });
                        },
                        children: List.generate(
                          24,
                          (index) => Text('$index 시'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: colorWhite,
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedTime.minute,
                        ),
                        onSelectedItemChanged: (value) {
                          setState(() {
                            selectedTime = TimeOfDay(
                              hour: selectedTime.hour,
                              minute: value,
                            );
                          });
                        },
                        children: List.generate(
                          60,
                          (index) => Text('$index 분'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
              height: 48,

          decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
             color: colorMain900
            )
          ),
          child: Center(child: Text('시간 선택: ${selectedTime.format(context)}',style: TS.s16w400(colorMain900),)),),
        ),

        Gaps.v20,

        BasicButton(title: '알림 신청하기', onTap: saveAlarmToFirestore),
      ],
    );
  }
}
