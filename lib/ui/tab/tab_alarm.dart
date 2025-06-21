import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/service/notification/court_notification_setting_upgrade.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../const/static/global.dart';

import 'package:flutter/foundation.dart';


class TabAlarm extends StatelessWidget {
  const TabAlarm({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ModelCourtAlarm>>(
      valueListenable: Global.vnCourtAlarms,
      builder: (context, alarms, _) {
        if (alarms.isEmpty) {
          return const Center(child: Text('등록된 알람이 없습니다.'));
        }

        final grouped = <String, List<ModelCourtAlarm>>{};
        for (final alarm in alarms) {
          grouped.putIfAbsent(alarm.courtUid, () => []).add(alarm);
        }
/*

        for (final entry in grouped.entries) {
          entry.value.sort((a, b) {
            final aMinutes = a.alarmHour * 60 + a.alarmMinute;
            final bMinutes = b.alarmHour * 60 + b.alarmMinute;
            return aMinutes.compareTo(bMinutes);
          });
        }
*/

        final sortedEntries = grouped.entries.toList()
          ..sort((a, b) => a.value.first.courtName.compareTo(b.value.first.courtName));

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: sortedEntries.map((entry) {
            final courtName = entry.value.first.courtName;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courtName,
                  style: TS.s16w500(colorGray900),
                ),
                const SizedBox(height: 8),
                ...entry.value.map((alarm) {
                  final timeStr = '${alarm.alarmHour.toString().padLeft(2, '0')}:${alarm.alarmMinute.toString().padLeft(2, '0')}';
                  final weekdayMap = {
                    1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일'
                  };
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
                            Text(
                              '${weekdayMap[alarm.alarmWeekday]}요일',
                              style: TS.s14w500(Color(0xFFF7D245)),
                            ),
                            Gaps.v4,
                            Text(
                              timeStr,
                              style: TS.s20w500(colorWhite)
                            ),
                          ],
                        ),

                        Switch(
                          value: alarm.alarmEnabled,
                          onChanged: (bool value) async {
                            final userUid = FirebaseAuth.instance.currentUser?.uid;
                            if (userUid == null) return;

                            if (!value) {
                              // 꺼질 때: UI 유지, 글로벌/파베 삭제
                              final snapshot = await FirebaseFirestore.instance
                                  .collection(keyCourtAlarms)
                                  .where(keyUserUid, isEqualTo: userUid)
                                  .where(keyCourtUid, isEqualTo: alarm.courtUid)
                                  .where(keyDateCreate, isEqualTo: alarm.dateCreate)
                                  .get();

                              for (final doc in snapshot.docs) {
                                await doc.reference.delete();
                              }

                              Global.vnCourtAlarms.value = Global.vnCourtAlarms.value.map((e) {
                                if (e.dateCreate == alarm.dateCreate &&
                                    e.userUid == userUid &&
                                    e.courtUid == alarm.courtUid) {
                                  return e.copyWith(alarmEnabled: false); // UI 상태만 꺼짐으로 유지
                                }
                                return e;
                              }).toList();
                            } else {
                              // 켜질 때: 글로벌/파베 재등록
                              final newAlarm = alarm.copyWith(alarmEnabled: true, dateCreate: Timestamp.now());

                              await FirebaseFirestore.instance
                                  .collection(keyCourtAlarms)
                                  .add(newAlarm.toJson());

                              Global.vnCourtAlarms.value = [
                                ...Global.vnCourtAlarms.value.where((e) =>
                                  !(e.dateCreate == alarm.dateCreate &&
                                    e.userUid == userUid &&
                                    e.courtUid == alarm.courtUid)),
                                newAlarm,
                              ];
                            }
                          },
                          activeColor: const Color(0xFFF7D245), // 노란색
                          inactiveThumbColor: Colors.white, // 꺼졌을 때 흰색
                          inactiveTrackColor: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  );
                }),
                Gaps.v20,
              ],
            );
          }).toList(),
        );
      },
    );
  }
}