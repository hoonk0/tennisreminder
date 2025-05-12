import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

class CourtAlarmSettings extends StatefulWidget {
  const CourtAlarmSettings({super.key});

  @override
  State<CourtAlarmSettings> createState() => _CourtAlarmSettingsState();
}

class _CourtAlarmSettingsState extends State<CourtAlarmSettings> {
  int selectedWeekday = DateTime.monday;
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
        keyAlarmWeekday: selectedWeekday,
        keyAlarmHour: selectedTime.hour,
        keyAlarmMinute: selectedTime.minute,
        keyDateCreate: Timestamp.now(),
        keyAlarmEnabled: true,
        keyFcmToken: fcmToken,
      };
      print('📲 FCM Token Retrieved in init: $fcmToken');
      print('📝 저장될 알람 정보: $data'); // 추가된 로그

      await _firestore.collection(keyCourtAlarms).add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림이 설정되었습니다.')),
      );
    } catch (e) {
      print('❌ 알림 설정 실패: $e'); // 에러 로그 추가
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          value: selectedWeekday,
          items: weekdays.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => selectedWeekday = value);
          },
          decoration: const InputDecoration(labelText: '요일 선택'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (time != null) {
              setState(() {
                selectedTime = time;
              });
            }
          },
          child: Text(
            '시간 선택: ${selectedTime.format(context)}',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: saveAlarmToFirestore,
          child: const Text('알림 신청하기'),
        ),
      ],
    );
  }
}