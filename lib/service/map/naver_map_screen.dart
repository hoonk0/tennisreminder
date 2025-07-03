import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NaverMapScreen extends StatelessWidget {
  final double lat;
  final double lng;

  const NaverMapScreen({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(lat, lng),
            zoom: 16,
          ),
       //   zoomControlEnable: false,
          locationButtonEnable: false,
        ),
        onMapReady: (controller) {
          controller.addOverlay(
            NMarker(
              id: 'selected_location',
              position: NLatLng(lat, lng),
              caption: const NOverlayCaption(text: '코트 위치'),
            ),
          );
        },
      ),
    );
  }
}
