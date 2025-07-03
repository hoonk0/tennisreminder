import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';

class NaverMapScreen extends StatelessWidget {
  final ModelCourt court;

  const NaverMapScreen({
    super.key,
    required this.court,
  });

  void _openNaverMapApp() async {
    final name = court.courtAddress ?? '코트 위치';
    final appUrl = Uri.parse('nmap://place?lat=${court.latitude}&lng=${court.longitude}&name=$name');
    // Web fallback: open Naver Map search for the name (address-based search)
    final url = Uri.encodeFull('https://map.naver.com/v5/search/$name');

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ 네이버 지도 앱 및 웹 모두 실행할 수 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(court.latitude, court.longitude),
            zoom: 16,
          ),
          locationButtonEnable: false,
          zoomGesturesEnable: true,
        ),
        onMapReady: (controller) {
          controller.addOverlay(
            NMarker(
              id: 'selected_location',
              position: NLatLng(court.latitude, court.longitude),
              caption: const NOverlayCaption(text: '코트 위치'),
            ),
          );
        },
/*        onMapTapped: (point, coord) {
          _openNaverMapApp();
        },*/
      ),
    );
  }
}
