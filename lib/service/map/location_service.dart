import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';

class LocationService {
  static final Map<String, double> courtDistances = {};

  static Future<void> ensureLocationPermission() async {
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

  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<List<ModelCourt>> getNearbyCourts({double radiusMeters = 10000}) async {
    try {
      final allCourtsSnapshot = await FirebaseFirestore.instance.collection(keyCourt).get();
      final allCourts = allCourtsSnapshot.docs.map((e) => ModelCourt.fromJson(e.data())).toList();

      final currentPosition = await getCurrentLocation();
      final nearbyCourts = <ModelCourt>[];

      for (final court in allCourts) {
        ///거리계산
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          court.latitude,
          court.longitude,
        );
        if (distance < radiusMeters) {
          LocationService.courtDistances[court.uid] = distance / 1000;
          nearbyCourts.add(court);
        }
      }

      nearbyCourts.sort((a, b) {
        final distA = LocationService.courtDistances[a.uid] ?? double.infinity;
        final distB = LocationService.courtDistances[b.uid] ?? double.infinity;
        return distA.compareTo(distB);
      });

      return nearbyCourts;
    } catch (e) {
      rethrow;
    }
  }

  static Future<double> calculateDistanceToCourt(ModelCourt court) async {
    final currentPosition = await getCurrentLocation();
    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      court.latitude,
      court.longitude,
    );
  }

  static Future<void> loadNearbyCourts({
    required Function(List<ModelCourt>) onSuccess,
    required Function(Exception) onError,
  }) async {
    try {
      await ensureLocationPermission();
      final courts = await getNearbyCourts();
      onSuccess(courts);
    } catch (e) {
      if (e is Exception) {
        onError(e);
      } else {
        onError(Exception('알 수 없는 오류 발생'));
      }
    }
  }
}