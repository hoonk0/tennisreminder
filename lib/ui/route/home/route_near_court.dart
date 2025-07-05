import 'package:flutter/material.dart';
import 'package:tennisreminder_app/ui/component/loading_bar.dart';
import 'package:tennisreminder_app/ui/route/home/route_court_information.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../../const/static/global.dart';
import '../../../service/map/location_service.dart';
import '../../component/card_court_inform.dart';



class RouteNearCourt extends StatefulWidget {
  const RouteNearCourt({super.key});

  @override
  State<RouteNearCourt> createState() => _RouteNearCourtState();
}

class _RouteNearCourtState extends State<RouteNearCourt> with WidgetsBindingObserver {
  late final ValueNotifier<List<ModelCourt>> vnNearbyCourts = Global.vnNearbyCourts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocationService.loadNearbyCourts(
      onSuccess: (courts) {
        vnNearbyCourts.value = courts;
        _isLoading = false;
      },
      onError: (e) {
        debugPrint('❌ 위치 접근 오류: $e');
        _isLoading = false;
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 포그라운드로 돌아왔을 때 위치 갱신
      _isLoading = true;
      LocationService.loadNearbyCourts(
        onSuccess: (courts) {
          vnNearbyCourts.value = courts;
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          debugPrint('❌ 위치 접근 오류 (포그라운드 복귀): $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('위치 정보를 다시 가져오지 못했습니다.')),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('근처 코트 찾기'),),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<ModelCourt>>(
                  valueListenable: vnNearbyCourts,
                  builder: (context, nearbyCourts, _) {
                    if (nearbyCourts.isEmpty) {
                      return Center(
                        child: _isLoading
                            ? const LoadingBar()
                            : const Text('주변 5km 이내의 코트를 찾을 수 없습니다.'),
                      );
                    }
                    return ListView(
                      children: nearbyCourts.take(5).map((court) {
                        return CardNearCourtInform(
                          court: court,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RouteCourtInformation(court: court),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Gaps.v20,
            ],
          ),
        ),
      ),
    );
  }
}


class CardNearCourtInform extends StatelessWidget {
  final ModelCourt court;
  final VoidCallback? onTap;

  const CardNearCourtInform({
    super.key,
    required this.court,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft:Radius.circular(8) ),
                  child: Image(
                    image: court.imageUrls != null && court.imageUrls!.isNotEmpty
                        ? NetworkImage(court.imageUrls!.first)
                        : const AssetImage('assets/images/mainicon.png') as ImageProvider,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Gaps.h4,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        court.courtName,
                        style: TS.s12w500(colorGray700),
                      ),
                      Gaps.h4,
                      Text(
                        court.courtAddress.split(' ').take(5).join(' '),
                        style: TS.s12w500(colorGray500),
                      ),
                    ],
                  ),
                ),
                Gaps.h4,
                Text(
                  '${LocationService.courtDistances[court.uid]?.toStringAsFixed(1) ?? '?'} km',
                  style: TS.s12w500(colorGray500),
                ),
                Gaps.h10,
              ],
            ),

          ],
        ),
      ),
    );
  }
}