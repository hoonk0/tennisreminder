// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennisreminder_app/ui/component/basic_button.dart';
import 'package:tennisreminder_app/ui/dialog/dialog_logout.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../const/static/global.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dialog/dialog_YN.dart';

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

    if (userUid == null || userUid.isEmpty) {
      debugPrint('❌ Global.uid 없음');
      Global.vnCourtAlarms.value = [];
      return;
    }
    debugPrint('🔍 Global.uid 기반 사용자: $userUid');

    // 🔄 초기화 제거: 기존 데이터 유지하여 깜빡임 방지

    final snapshot =
        await FirebaseFirestore.instance
            .collection(keyCourtAlarms)
            .where(keyUid, isEqualTo: userUid)
            .orderBy(keyAlarmDateTime)
            .get();

    print('📥 Raw snapshot: ${snapshot.docs.map((d) => d.data())}');

    final alarms =
        snapshot.docs.map((e) => ModelCourtAlarm.fromJson(e.data())).toList();

    Global.vnCourtAlarms.value = alarms;

    print('✅ [${userUid}] 알람 개수: ${alarms.length}');
  }

  ///

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
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: colorGray600,
                     borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) => DialogYN(
                            desc: '지난 일정의 알람을 삭제할까요?',
                            title: '지난 알람 삭제',
                            buttonLabelLeft: '네',
                            onTapYes: () async {
                              final userUid = Global.uid;
                              if (userUid == null || userUid.isEmpty) return;

                              final now = DateTime.now();
                              final todayStart = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );

                              final snapshot =
                              await FirebaseFirestore.instance
                                  .collection(keyCourtAlarms)
                                  .where(keyUid, isEqualTo: userUid)
                                  .where(
                                keyAlarmDateTime,
                                isLessThan: Timestamp.fromDate(todayStart),
                              )
                                  .get();

                              for (final doc in snapshot.docs) {
                                await doc.reference.delete();
                              }

                              Global.vnCourtAlarms.value =
                                  Global.vnCourtAlarms.value
                                      .where(
                                        (e) =>
                                    e.alarmDateTime == null ||
                                        e.alarmDateTime!.toDate().isAfter(
                                          todayStart,
                                        ),
                                  )
                                      .toList();
                            },
                            buttonLabelRight: '다음에',
                          ),
                        );
                      },
                      child: Image.asset(
                       'assets/icons/past_delete.png',
                        width: 40,
                        height: 40,
                        color: colorWhite,
                      ),
                    ),
                  ),

                  Gaps.h5,

                  Container(
                    width: 40,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: colorRed,
                      borderRadius: BorderRadius.circular(8.0),

                    ),
                    child: GestureDetector(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) => DialogYN(
                            desc: '전체 일정의 알람을 삭제할까요?',
                            title: '전체 알람 삭제',
                            buttonLabelLeft: '네',
                            onTapYes: () async {
                              final userUid = Global.uid;
                              if (userUid == null || userUid.isEmpty) return;

                              final snapshot = await FirebaseFirestore.instance
                                  .collection(keyCourtAlarms)
                                  .where(keyUid, isEqualTo: userUid)
                                  .get();

                              for (final doc in snapshot.docs) {
                                await doc.reference.delete();
                              }

                              Global.vnCourtAlarms.value = [];
                            },
                            buttonLabelRight: '다음에',
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/delete.png',
                        width: 30,
                        height: 30,
                        color: colorWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children:
                    grouped.entries.map((entry) {
                      final courtName =
                          alarms
                              .firstWhere((a) => a.courtUid == entry.key)
                              .courtName;
                      final courtAlarms = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(courtName, style: TS.s16w500(colorGray900)),
                          Gaps.v8,
                          ...courtAlarms.map((alarm) {
                            print(
                              '📍Switch 렌더링: alarmEnabled=${alarm.alarmEnabled}, courtUid=${alarm.courtUid}, dateCreate=${alarm.dateCreate}',
                            );
                            return Dismissible(
                              key: Key(alarm.dateCreate.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) async {
                                final userUid = Global.uid;
                                if (userUid == null || userUid.isEmpty) return;

                                final snapshot =
                                    await FirebaseFirestore.instance
                                        .collection(keyCourtAlarms)
                                        .where(keyUid, isEqualTo: userUid)
                                        .where(
                                          keyCourtUid,
                                          isEqualTo: alarm.courtUid,
                                        )
                                        .where(
                                          keyDateCreate,
                                          isEqualTo: alarm.dateCreate,
                                        )
                                        .get();

                                for (final doc in snapshot.docs) {
                                  await doc.reference.delete();
                                }

                                Global.vnCourtAlarms.value =
                                    Global.vnCourtAlarms.value
                                        .where(
                                          (e) =>
                                              !(e.dateCreate ==
                                                      alarm.dateCreate &&
                                                  e.uid == userUid &&
                                                  e.courtUid == alarm.courtUid),
                                        )
                                        .toList();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C5D43),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (alarm.alarmDateTime != null)
                                          Text(
                                            DateFormat('M월 d일', 'ko_KR').format(
                                              alarm.alarmDateTime!.toDate(),
                                            ),
                                            style: TS.s14w500(
                                              Color(0xFFF7D245),
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        if (alarm.alarmDateTime != null)
                                          Text(
                                            DateFormat(
                                              'a h시 mm분',
                                              'ko_KR',
                                            ).format(
                                              alarm.alarmDateTime!.toDate(),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Switch(
                                      value: alarm.alarmEnabled,
                                      onChanged: (bool value) async {
                                        final userUid = Global.uid;
                                        print(
                                          '🧪 스위치 변경 감지됨: value=$value, userUid=$userUid',
                                        );
                                        if (userUid == null || userUid.isEmpty)
                                          return;

                                        if (!value) {
                                          print(
                                            '🔻 삭제 프로세스 시작: courtUid=${alarm.courtUid}, dateCreate=${alarm.dateCreate}, userUid=$userUid',
                                          );
                                          print(
                                            '🗑️ 알람 OFF 요청: courtUid=${alarm.courtUid}, dateCreate=${alarm.dateCreate}, userUid=$userUid',
                                          );

                                          final snapshot =
                                              await FirebaseFirestore.instance
                                                  .collection(keyCourtAlarms)
                                                  .where(
                                                    keyUid,
                                                    isEqualTo: userUid,
                                                  )
                                                  .where(
                                                    keyCourtUid,
                                                    isEqualTo: alarm.courtUid,
                                                  )
                                                  .where(
                                                    keyDateCreate,
                                                    isEqualTo: alarm.dateCreate,
                                                  )
                                                  .get();

                                          print(
                                            '📦 삭제 대상 문서 개수: ${snapshot.docs.length}',
                                          );
                                          for (final doc in snapshot.docs) {
                                            await doc.reference.delete();
                                            print('🧨 삭제된 문서 ID: ${doc.id}');
                                          }

                                          Global.vnCourtAlarms.value =
                                              Global.vnCourtAlarms.value.map((
                                                e,
                                              ) {
                                                if (e.dateCreate ==
                                                        alarm.dateCreate &&
                                                    e.uid == userUid &&
                                                    e.courtUid ==
                                                        alarm.courtUid) {
                                                  return e.copyWith(
                                                    alarmEnabled: false,
                                                  );
                                                }
                                                return e;
                                              }).toList();

                                          print(
                                            '🧼 UI 상태 업데이트 완료 (alarmEnabled: false)',
                                          );
                                        } else {
                                          print(
                                            '🆕 알람 추가 시도: courtUid=${alarm.courtUid}, dateCreate=${alarm.dateCreate}, userUid=$userUid',
                                          );
                                          final data = {
                                            keyUid: userUid,
                                            keyCourtUid: alarm.courtUid,
                                            keyCourtName: alarm.courtName,
                                            keyAlarmDateTime:
                                                alarm.alarmDateTime,
                                            keyDateCreate: alarm.dateCreate,
                                            keyAlarmEnabled: true,
                                            keyFcmToken: Global.fcmToken,
                                          };

                                          await FirebaseFirestore.instance
                                              .collection(keyCourtAlarms)
                                              .add(data);

                                          Global.vnCourtAlarms.value =
                                              Global.vnCourtAlarms.value.map((
                                                e,
                                              ) {
                                                if (e.dateCreate ==
                                                        alarm.dateCreate &&
                                                    e.courtUid ==
                                                        alarm.courtUid) {
                                                  return e.copyWith(
                                                    alarmEnabled: true,
                                                  );
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
                              ),
                            );
                          }),
                          Gaps.v5,
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
