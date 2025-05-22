/*
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/route/home/route_court_information.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';

import '../../ui/component/card_court_inform.dart';

class RouteNearCourt extends StatefulWidget {
  const RouteNearCourt({super.key});

  @override
  State<RouteNearCourt> createState() => _RouteNearCourtState();
}

class _RouteNearCourtState extends State<RouteNearCourt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        /// 3. 내 주변 10km 코트
        Text('내 주변 코트', style: Theme.of(context).textTheme.titleMedium),
        Gaps.v5,
        ValueListenableBuilder<List<ModelCourt>>(
          valueListenable: vnNearbyCourts,
          builder: (context, nearbyCourts, _) {
            if (nearbyCourts.isEmpty) {
              return const Text('주변 10km 이내의 코트를 찾을 수 없습니다.');
            }
            return Column(
              children:
              nearbyCourts.take(5).map((court) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CardCourtInform(
                    court: court,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => RouteCourtInformation(court: court),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),

        Gaps.v20,

      ],),
    );
  }
}
*/
