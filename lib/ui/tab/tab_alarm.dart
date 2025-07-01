// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

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
                  style: TS.s16w500(colorGray900),
                ),
                Gaps.v8,
                ...courtAlarms.map((alarm) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C5D43),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (alarm.alarmDateTime != null)
                              Text(
                                DateFormat('M월 d일', 'ko_KR').format(alarm.alarmDateTime!.toDate()),
                                style: TS.s14w500(Color(0xFFF7D245)),
                              ),
                            const SizedBox(height: 4),
                            if (alarm.alarmDateTime != null)
                              Text(
                                DateFormat('a h시 mm분', 'ko_KR').format(alarm.alarmDateTime!.toDate()),
                                style: const TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                        Switch(
                          value: alarm.alarmEnabled,
                          onChanged: (bool value) async {
                            final userUid = FirebaseAuth.instance.currentUser?.uid;
                            if (userUid == null) return;

                            if (!value) {
                              final snapshot = await FirebaseFirestore.instance
                                  .collection(keyCourtAlarms)
                                  .where(keyUid, isEqualTo: userUid)
                                  .where(keyCourtUid, isEqualTo: alarm.courtUid)
                                  .where(keyDateCreate, isEqualTo: alarm.dateCreate)
                                  .get();

                              for (final doc in snapshot.docs) {
                                await doc.reference.delete();
                              }

                              Global.vnCourtAlarms.value = Global.vnCourtAlarms.value.map((e) {
                                if (e.dateCreate == alarm.dateCreate &&
                                    e.uid == userUid &&
                                    e.courtUid == alarm.courtUid) {
                                  return e.copyWith(alarmEnabled: false);
                                }
                                return e;
                              }).toList();
                            } else {
                              final data = {
                                keyUid: userUid,
                                keyCourtUid: alarm.courtUid,
                                keyCourtName: alarm.courtName,
                                keyAlarmDateTime: alarm.alarmDateTime,
                                keyDateCreate: alarm.dateCreate,
                                'alarmEnabled': true,
                              };

                              await FirebaseFirestore.instance.collection(keyCourtAlarms).add(data);

                              Global.vnCourtAlarms.value = Global.vnCourtAlarms.value.map((e) {
                                if (e.dateCreate == alarm.dateCreate &&
                                    e.uid == userUid &&
                                    e.courtUid == alarm.courtUid) {
                                  return e.copyWith(alarmEnabled: true);
                                }
                                return e;
                              }).toList();
                            }
                          },
                          activeColor: const Color(0xFFF7D245),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  );
                }),
                Gaps.v5,
              ],
            );
          }).toList(),
        );
      },
    );
  }
}