import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import '../../const/static/global.dart';

import 'package:flutter/foundation.dart';


class TabAlarm extends StatelessWidget {
  const TabAlarm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [

          Gaps.v16,
          Expanded(
            child: ValueListenableBuilder<List<ModelCourtAlarm>>(
              valueListenable: Global.vnCourtAlarms,
              builder: (context, alarms, _) {
                if (alarms.isEmpty) {
                  return const Center(child: Text('등록된 알람이 없습니다.'));
                }

                final weekdayMap = {
                  1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일'
                };

                return ListView.builder(
                  itemCount: alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = alarms[index];
                    final timeStr = '${alarm.alarmHour.toString().padLeft(2, '0')}:${alarm.alarmMinute.toString().padLeft(2, '0')}';
                    return ListTile(
                      leading: const Icon(Icons.alarm),
                      title: Text('${alarm.courtName}'),
                      subtitle: Text('${weekdayMap[alarm.alarmWeekday]}요일 $timeStr 알림'),
                      trailing: alarm.alarmEnabled
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.grey),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}