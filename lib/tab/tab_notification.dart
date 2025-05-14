import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import '../../const/static/global.dart';


class TabNotification extends StatefulWidget {
  const TabNotification({super.key});

  @override
  State<TabNotification> createState() => _TabNotificationState();
}

class _TabNotificationState extends State<TabNotification> {

  Future<void> _addDummyCourts() async {
    final batch = FirebaseFirestore.instance.batch();
    final courtsCollection = FirebaseFirestore.instance.collection('court');

    for (int i = 0; i < 10; i++) {
      final docRef = courtsCollection.doc();
      final address = '서울시 강남구 xx동';
      final district = address.split(' ').length > 1 ? address.split(' ')[1] : '';
      final court = ModelCourt(
        uid: docRef.id,
        dateCreate: Timestamp.now(),
        latitude: 37.5 + i * 0.01,
        longitude: 127.0 + i * 0.01,
        courtName: '샘플 코트 $i',
        courtAddress: address,
        courtInfo: '이곳은 샘플 코트입니다 $i',
        reservationUrl: 'https://reservation.example.com/$i',
        likedUserUids: [],
        imageUrls: [],
        extraInfo: {'parking': i % 2 == 0, 'light': i % 3 == 0},
        courtDistrict: district,
      );
      batch.set(docRef, court.toJson());
    }

    await batch.commit();
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Gaps.v16,

          ElevatedButton(
            onPressed: _addDummyCourts,
            child: const Text('샘플 코트 10개 추가'),
          ),

        ],
      ),
    );
  }
}