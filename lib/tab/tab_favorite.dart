import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
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
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colorMain900.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorMain900, width: 1),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorMain900.withOpacity(0.15),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: colorMain900, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          court.courtName,
                          style: TextStyle(color: colorMain900, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          court.courtAddress,
                          style: TextStyle(color: colorMain900.withOpacity(0.8)),
                        ),
                        trailing: Icon(Icons.chevron_right, color: colorMain900),
                        onTap: () {
                          // Navigate to detail page or perform desired action
                        },
                      ),
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