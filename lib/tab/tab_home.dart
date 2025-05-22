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
import '../service/location_service.dart';
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
  final ValueNotifier<List<ModelCourt>> vnNearbyCourts = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    LocationService.loadNearbyCourts(
      onSuccess: (courts) {
        vnNearbyCourts.value = courts;
      },
      onError: (e) {
        debugPrint('❌ 위치 접근 오류: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 정보를 가져올 수 없습니다. 권한을 확인해주세요.')),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    vnNearbyCourts.dispose();
    super.dispose();
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
                children: nearbyCourts.take(5).map((court) {
                  return CardCourtInform(
                    court: court,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RouteCourtInformation(court: court)),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          Gaps.v20,*/

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
