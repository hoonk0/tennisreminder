import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tennisreminder_core/const/value/text_style.dart';

class WeatherAlarm extends StatefulWidget {
  const WeatherAlarm({super.key});

  @override
  State<WeatherAlarm> createState() => _WeatherAlarmState();
}

class _WeatherAlarmState extends State<WeatherAlarm> {
  final ValueNotifier<List<Map<String, dynamic>>> vnForecastNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();

    ///캐시된 데이터 보여주던가
    loadForecastFromCache().then((cached) async {
      if (cached != null) {
        vnForecastNotifier.value = cached;
      }
      ///6시간 지나면 새로 불러오기
      if (await shouldFetchWeather()) {
        fetchWeather();
      }
    });
  }

  ///날씨불러오기
  Future<void> fetchWeather() async {
    ///좌표 일단 서울날씨로 고정
    const lat = 37.5665;
    const lon = 126.9780;
    final url = Uri.parse(
      ///요청데이터
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&daily=temperature_2m_min,temperature_2m_max,weathercode'
      '&timezone=Asia%2FSeoul',
    );

    debugPrint('🟡 Open-Meteo API 호출 시작: $url');

    ///api호출
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final times = List<String>.from(data['daily']['time']);
      final maxTemps = List<double>.from(data['daily']['temperature_2m_max']);
      final minTemps = List<double>.from(data['daily']['temperature_2m_min']);
      final weatherCodes = List<int>.from(data['daily']['weathercode']);

      ///추출한 데이터 합체
      vnForecastNotifier.value = List.generate(times.length, (index) {
        return {
          'dt': DateTime.parse(times[index]).millisecondsSinceEpoch ~/ 1000,
          'min': minTemps[index],
          'max': maxTemps[index],
          'icon': weatherCodes[index],
        };
      });
      await saveForecastToCache(vnForecastNotifier.value);
      debugPrint('✅ Open-Meteo 예보 수신 성공: ${vnForecastNotifier.value.length}일치');
    } else {
      debugPrint('❌ Open-Meteo 요청 실패: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');
    }
  }

  ///6시간 지났는지 비교하여 업데이트
  Future<bool> shouldFetchWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdatedMillis = prefs.getInt('weather_last_updated');
    if (lastUpdatedMillis == null) return true;
    final lastUpdated = DateTime.fromMillisecondsSinceEpoch(lastUpdatedMillis);
    return DateTime.now().difference(lastUpdated) > const Duration(hours: 6);
  }

  ///날씨예보 저장
  Future<void> saveForecastToCache(List<Map<String, dynamic>> forecast) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_forecast', jsonEncode(forecast));
    await prefs.setInt('weather_last_updated', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Map<String, dynamic>>?> loadForecastFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_forecast');
    if (jsonString == null) return null;
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  ///맵코드 -> 날씨이미지로 변경
  String mapWeatherCodeToEmoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '🌤';
    if (code <= 48) return '☁️';
    if (code <= 57) return '🌦';
    if (code <= 67) return '🌧';
    if (code <= 77) return '🌨';
    if (code <= 82) return '🌦';
    if (code <= 99) return '⛈';
    return '❓';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [colorMain900, Color(0xFFB3F1D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: vnForecastNotifier,
        builder: (context, forecast, _) {
          return forecast.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: forecast.map((item) {
                      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _weekdayKor(date.weekday).toUpperCase(),
                              style: const TS.s10w600(colorWhite),
                            ),
                            Gaps.v5,
                            Text(
                              mapWeatherCodeToEmoji(item['icon']),
                              style: const TextStyle(fontSize: 26),
                            ),
                            Gaps.v5,
                            Text(
                              '${item['min'].round()}°/${item['max'].round()}°',
                              style: const TS.s12w400(colorWhite),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
        },
      ),
    );
  }

  String _weekdayKor(int weekday) {
    const weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return weekdays[(weekday - 1) % 7];
  }
}
