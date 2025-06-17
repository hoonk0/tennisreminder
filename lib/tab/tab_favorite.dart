import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_app/route/home/route_court_information.dart';
import 'package:tennisreminder_app/ui/component/custom_divider.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import '../../const/static/global.dart';
import '../ui/component/card_court_inform.dart';


class TabFavorite extends StatelessWidget {
  const TabFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}