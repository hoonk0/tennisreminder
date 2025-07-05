import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class RouteSetting extends StatelessWidget {
  const RouteSetting({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> alarmEnabled = ValueNotifier<bool>(false);

    return Scaffold(
      appBar: AppBar(title: const Text("알람 설정")),
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: alarmEnabled,
          builder: (context, value, _) {
            return SwitchListTile(
              title: const Text("알람 사용"),
              value: value,
              onChanged: (newValue) async {
                alarmEnabled.value = newValue;

                final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
                final androidGranted = await flutterLocalNotificationsPlugin
                    .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin>()
                    ?.areNotificationsEnabled();

                if (newValue) {
                  if (androidGranted == true) {
                    print("✅ 알람 켜짐: 시스템 알림 권한 있음");
                    // 여기에 알람 등록 로직 추가
                  } else {
                    print("❌ 알람 켜기 실패: 시스템 알림 권한 없음");
                  }
                } else {
                  print("🔕 알람 꺼짐");
                  // 여기에 알람 해제 로직 추가
                }
              },
            );
          },
        ),
      ),
    );
  }
}
