import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:cloud_firestore/cloud_firestore.dart' as MasonryGridView;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tennisreminder_app/route/home/route_court_information.dart';
import 'package:tennisreminder_app/route/home/route_weather.dart';
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
import '../ui/component/card_court_summary.dart';
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.search, color: colorGray900),
                    Gaps.h8,
                    Text('테니스 코트를 검색하세요', style: TS.s16w500(colorGray900)),
                  ],
                ),
              ),
            ),
          ),
          Gaps.v5,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              HomeIcon(
                assetPath: 'assets/icons/tenniscourtall.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RouteAllCourts()),
                  );
                }, label: '전체코트',
              ),
              HomeIcon(
                assetPath: 'assets/icons/weather.png',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RouteWeatherAlarm()));
                }, label: '날씨',
              ),
              HomeIcon(
                assetPath: 'assets/icons/nearcourt.png',
                onTap: () {
                  // TODO: Add nearby court tap functionality
                }, label: '근처코트',
              ),
              HomeIcon(
                assetPath: 'assets/icons/seoulcourt.png',
                onTap: () {
                  // TODO: Add Seoul court tap functionality
                }, label: 'xx구 보기',
              ),

            ],
          ),
          Gaps.v10,

          ///2. 날씨알람
          /*          Text('이번주 서울 날씨', style: Theme.of(context).textTheme.titleMedium),*/
     /*     Gaps.v5,
          WeatherAlarm(),
*/
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
/*              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RouteAllCourts()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '서울시 추천 코트',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),*/
              Gaps.v5,
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection(keyCourt)
                        .orderBy(keyDateCreate, descending: true)
                        .limit(3)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final courts =
                      snapshot.data!.docs
                          .map(
                            (doc) => ModelCourt.fromJson(
                              doc.data() as Map<String, dynamic>,
                            ),
                          )
                          .toList();

                  return Column(
                    children: courts.map((court) => CardCourtSummary(court: court)).toList(),
                  );
                },
              ),
            ],
          ),

          Gaps.v20,

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

          /*
          /// 5. 좋아요 많은 코트
          Text('인기 코트 TOP 5', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          Placeholder(fallbackHeight: 100), */
          // PopularCourtListWidget 자리
        ],
      ),
    );
  }
}

class HomeIcon extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const HomeIcon({
    required this.assetPath,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 40,
            height: 40,
          ),
          Text(
            label,
            style: TS.s11w500(colorGray900),
          ),
/*          Gaps.v4,
          Container(
            height: 2,
            width: 20,
            color:  colorGray400 ,
          ),*/
        ],
      ),
    );
  }
}
