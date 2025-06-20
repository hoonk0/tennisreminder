import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class KakaoMapScreen extends StatelessWidget {
  final double lat;
  final double lng;

  const KakaoMapScreen({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: KakaoMap(
        center: LatLng(lat, lng),
        markers: [
          Marker(
            markerId: UniqueKey().toString(),
            latLng: LatLng(lat, lng),
          ),
        ],
      ),
    );}
}