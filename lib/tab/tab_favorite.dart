import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import '../../const/static/global.dart';


class TabFavorite extends StatelessWidget {
  const TabFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    return ListTile(
                      title: Text(court.courtName),
                      subtitle: Text(court.courtAddress),
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