import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';

/// 현재 위치와 ModelCourt 간 거리 계산 (단위: 미터)
Future<double> calculateDistanceToCourt(ModelCourt court) async {
  final currentPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return Geolocator.distanceBetween(
    currentPosition.latitude,
    currentPosition.longitude,
    court.latitude,
    court.longitude,
  );
}