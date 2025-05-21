import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tennisreminder_app/ui/component/basic_button.dart';
import 'package:tennisreminder_app/ui/dialog/dialog_notification_confirm.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

class CourtNotificationSettings extends StatefulWidget {
  final ValueNotifier<bool> vnAlarmSet;
  final ModelCourt court;

  const CourtNotificationSettings({
    super.key,
    required this.vnAlarmSet,
    required this.court,
  });

  @override
  State<CourtNotificationSettings> createState() => _CourtNotificationSettingsState();
}

class _CourtNotificationSettingsState extends State<CourtNotificationSettings> {
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
    _getFcmToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 포그라운드 수신됨: ${message.notification?.title}');
      if (!mounted) return; // ✅ 위젯이 활성 상태인지 확인
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAlarmToFirestore() async {
    try {
      debugPrint('🟡 saveAlarmToFirestore 호출됨');
      final fcmToken = await _getFcmToken();
      debugPrint('🔑 FCM Token: $fcmToken');
      if (fcmToken == null) throw Exception('FCM 토큰을 가져올 수 없습니다.');
      final data = {
        keyCourtUid: widget.court.uid,
        keyUserUid: FirebaseAuth.instance.currentUser?.uid,
        keyCourtName: widget.court.courtName,
        keyAlarmWeekday: selectedWeekday.value,
        keyAlarmHour: selectedTime.hour,
        keyAlarmMinute: selectedTime.minute,
        keyDateCreate: Timestamp.now(),
        keyAlarmEnabled: true,
        keyFcmToken: fcmToken,
      };
      debugPrint('📤 Firestore 저장 데이터: $data');

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

    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
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
