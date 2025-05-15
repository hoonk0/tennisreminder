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


class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {

  final TextEditingController _tecSearch = TextEditingController();
  List<ModelCourt> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tecSearch.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tecSearch.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final text = _tecSearch.text.trim();
    if (text.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection(keyCourt)
        .get();

    final courts = snapshot.docs
        .map((doc) => ModelCourt.fromJson(doc.data()))
        .where((court) => court.courtName.toLowerCase().contains(text.toLowerCase()))
        .toList();

    setState(() => _searchResults = courts);
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
          Gaps.v20,


          ///2. 날씨알람
          Text('이번주 서울 날씨', style: Theme.of(context).textTheme.titleMedium),
          Gaps.v5,
          WeatherAlarm(),

          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('검색 결과', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Column(
              children: _searchResults.map((court) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorGray300),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(
                        image: court.imageUrls != null && court.imageUrls!.isNotEmpty
                            ? NetworkImage(court.imageUrls!.first)
                            : const AssetImage('assets/images/mainicon.png') as ImageProvider,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(court.courtName),
                    subtitle: Text(court.courtAddress),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RouteCourtInformation(court: court),
                      ));
                    },
                  ),
                );
              }).toList(),
            ),
          ],

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

          Gaps.v20,

          /// 3. 내 주변 10km 코트
          Text('내 주변 코트', style: Theme.of(context).textTheme.titleMedium),
          Gaps.v5,
          Column(
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorGray300),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset('assets/images/mainicon.png', width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  title: Text('코트 이름 $index'),
                  subtitle: Text('10km 이내 위치'),
                ),
              );
            }),
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