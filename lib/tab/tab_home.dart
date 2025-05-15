import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart' as MasonryGridView;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tennisreminder_app/route/home/route_court_information.dart';
import 'package:tennisreminder_app/route/route_all_courts.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import '../../const/static/global.dart';
import '../route/home/route_court_search.dart';
import '../service/weather/weather_alarm.dart';
import '../ui/component/textfield_border.dart';
import '../ui/component/card_court_preview.dart';
import 'package:geolocator/geolocator.dart';
import '../../ui/component/card_court_inform.dart';


class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  List<ModelCourt> _nearbyCourts = [];
  bool _isNearbyLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyCourts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNearbyCourts() async {
    try {
      await _ensureLocationPermission();
      final courts = await _getNearbyCourts();
      setState(() {
        _nearbyCourts = courts;
        _isNearbyLoading = false;
      });
    } catch (e) {
      debugPrint('❌ 위치 접근 오류: $e');
      setState(() => _isNearbyLoading = false);
      // 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 정보를 가져올 수 없습니다. 권한을 확인해주세요.')),
        );
      }
    }
  }

  Future<List<ModelCourt>> _getNearbyCourts() async {
    try {
      final allCourtsSnapshot = await FirebaseFirestore.instance.collection(keyCourt).get();
      final allCourts = allCourtsSnapshot.docs.map((e) => ModelCourt.fromJson(e.data())).toList();

      final currentPosition = await Geolocator.getCurrentPosition();
      debugPrint('📍 현재 위치: ${currentPosition.latitude}, ${currentPosition.longitude}');

      final nearbyCourts = <ModelCourt>[];
      for (final court in allCourts) {
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          court.latitude,
          court.longitude,
        );
        if (distance < 1) {
          nearbyCourts.add(court);
        }
      }

      return nearbyCourts;
    } catch (e) {
      debugPrint('❌ _getNearbyCourts 예외: $e');
      return [];
    }
  }

  Future<void> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("위치 권한이 거부되었습니다.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("위치 권한이 영구적으로 거부되었습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 1. 검색창
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RouteCourtSearch()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorGray300),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: colorGray300),
                  SizedBox(width: 8),
                  Text('테니스 코트를 검색해보세요', style: TS.s14w600(colorGray600),),
                ],
              ),
            ),
          ),
          Gaps.v10,

          ///2. 날씨알람
/*          Text('이번주 서울 날씨', style: Theme.of(context).textTheme.titleMedium),*/
          Gaps.v5,
          WeatherAlarm(),

          Gaps.v10,


 /*         /// 2. 최근 본 코트
          Text('최근 본 코트', style: Theme.of(context).textTheme.titleMedium),
          Gaps.v4,
          Container(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => Gaps.h4,
              itemBuilder: (context, index) {
                return CardCourtPreview(
                  imagePath: 'assets/images/mainicon.png',
                  courtName: '최근 본 코트 $index',
                );
              },
            ),
          ),*/



          /// 3. 내 주변 10km 코트
          Text('내 주변 코트', style: Theme.of(context).textTheme.titleMedium),
          Gaps.v5,
          if (_isNearbyLoading)
            const Center(child: CircularProgressIndicator())
          else if (_nearbyCourts.isEmpty)
            const Text('주변 10km 이내의 코트를 찾을 수 없습니다.')
          else
            Column(
              children: _nearbyCourts.map((court) {
                return CardCourtInform(
                  court: court,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RouteCourtInformation(court: court)),
                    );
                  },
                );
              }).toList(),
            ),

          Gaps.v20,

          /// 4. 서울시 추천 코트
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RouteAllCourts()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('서울시 추천 코트', style: Theme.of(context).textTheme.titleMedium),
                  Icon(Icons.keyboard_arrow_right, color: colorGray900,)
                ],
              ),
            ),
            Gaps.v5,
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(keyCourt)
                  .orderBy(keyDateCreate, descending: true)
                  .limit(4)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courts = snapshot.data!.docs
                    .map((doc) => ModelCourt.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                return MasonryGridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: courts.length,
                  itemBuilder: (context, index) {
                    final court = courts[index];
                    return GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RouteCourtInformation(court: court,)));
                      },
                      child: CardCourtPreview(
                        imagePath: court.imageUrls?.isNotEmpty == true
                            ? court.imageUrls!.first
                            : 'assets/images/mainicon.png',
                        courtName: court.courtName,
                        width: double.infinity,
                      ),
                    );
                  },
                );
              },
            ),

          ],),

          Gaps.v20,
/*
          /// 5. 좋아요 많은 코트
          Text('인기 코트 TOP 5', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Placeholder(fallbackHeight: 100), */// PopularCourtListWidget 자리
        ],
      ),
    );
  }
}
