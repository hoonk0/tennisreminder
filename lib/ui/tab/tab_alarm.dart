// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

import '../../const/static/global.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TabAlarm extends StatefulWidget {
  const TabAlarm({super.key});

  @override
  State<TabAlarm> createState() => _TabAlarmState();
}

class _TabAlarmState extends State<TabAlarm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUserAlarms();
    });
  }

  Future<void> loadUserAlarms() async {
    final userUid = Global.uid;

    debugPrint('🔍 Global.uid 기반 사용자: ${userUid!.isNotEmpty ? userUid : '❌ 없음'}');

    if (userUid.isEmpty) {
      Global.vnCourtAlarms.value = [];
      return;
    }

    // 🔄 캐시 초기화
    Global.vnCourtAlarms.value = [];

    final snapshot = await FirebaseFirestore.instance
        .collection(keyCourtAlarms)
        .where(keyUid, isEqualTo: userUid)
        .orderBy(keyAlarmDateTime)
        .get();

    print('📥 Raw snapshot: ${snapshot.docs.map((d) => d.data())}');

    final alarms = snapshot.docs.map((e) => ModelCourtAlarm.fromJson(e.data())).toList();

    Global.vnCourtAlarms.value = alarms;

    print('✅ [${userUid}] 알람 개수: ${alarms.length}');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ModelCourtAlarm>>(
      valueListenable: Global.vnCourtAlarms,
      builder: (context, alarms, _) {
        if (alarms.isEmpty) {
          return const Center(child: Text('등록된 알림이 없습니다.'));
        }
        final grouped = <String, List<ModelCourtAlarm>>{};
        for (final alarm in alarms) {
          grouped.putIfAbsent(alarm.courtUid, () => []).add(alarm);
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: grouped.entries.map((entry) {
            final courtName = alarms.firstWhere((a) => a.courtUid == entry.key).courtName;
            final courtAlarms = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courtName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...courtAlarms.map((alarm) {
                  final dateTime = alarm.alarmDateTime?.toDate();
                  final timeStr = dateTime != null
                      ? '${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute.toString().padLeft(2, '0')}분'
                      : '시간 정보 없음';

                  return ListTile(
                    title: Text(timeStr),
                    trailing: GestureDetector(
                      onTap: () async {
                        final querySnapshot = await FirebaseFirestore.instance
                            .collection(keyCourtAlarms)
                            .where(keyUid, isEqualTo: Global.uid)
                            .where(keyCourtUid, isEqualTo: alarm.courtUid)
                            .where(keyAlarmDateTime, isEqualTo: alarm.alarmDateTime)
                            .limit(1)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          // 알림이 존재하면 Firestore에서 삭제하고 UI에서 alarmEnabled만 false로 업데이트
                          await querySnapshot.docs.first.reference.delete();
                          Global.vnCourtAlarms.value = Global.vnCourtAlarms.value.map((a) {
                            return (a.courtUid == alarm.courtUid &&
                                    a.alarmDateTime?.toDate().toIso8601String() ==
                                        alarm.alarmDateTime?.toDate().toIso8601String())
                                ? a.copyWith(alarmEnabled: false)
                                : a;
                          }).toList();
                        } else {
                          // 알림이 없으면 Firestore에 추가하고 UI에서 alarmEnabled true로 업데이트
                          final newAlarm = alarm.copyWith(alarmEnabled: true);
                          await FirebaseFirestore.instance.collection(keyCourtAlarms).add({
                            ...newAlarm.toJson(),
                            keyUid: Global.uid ?? '',
                          });
                          Global.vnCourtAlarms.value = Global.vnCourtAlarms.value.map((a) {
                            return (a.courtUid == alarm.courtUid &&
                                    a.alarmDateTime?.toDate().toIso8601String() ==
                                        alarm.alarmDateTime?.toDate().toIso8601String())
                                ? newAlarm
                                : a;
                          }).toList();
                        }
                      },
                      child: Icon(
                        alarm.alarmEnabled ? Icons.notifications_active : Icons.notifications_off,
                        color: alarm.alarmEnabled ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                }),
                const Divider(thickness: 1),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}