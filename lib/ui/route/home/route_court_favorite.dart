import 'package:flutter/material.dart';
import 'package:tennisreminder_app/ui/route/home/route_court_information.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';

import '../../../const/static/global.dart';
import '../../component/card_court_inform.dart';

class RouteCourtFavorite extends StatelessWidget {
  const RouteCourtFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('선호코트'),),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Gaps.v16,

            ValueListenableBuilder(
              valueListenable: Global.vnFavoriteCourts,
              builder: (context, List<ModelCourt> courts, _) {
                if (courts.isEmpty) {
                  return const Text('좋아요한 코트가 없습니다.');
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      final court = courts[index];
                      return Column(
                        children: [
                          CardCourtInform(
                            court: court,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RouteCourtInformation(court: court)));
                            },
                          ),

                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
