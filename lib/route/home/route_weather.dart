import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tennisreminder_core/const/value/text_style.dart';

class RouteWeatherAlarm extends StatefulWidget {
  const RouteWeatherAlarm({super.key});

  @override
  State<RouteWeatherAlarm> createState() => _RouteWeatherAlarmState();
}

class _RouteWeatherAlarmState extends State<RouteWeatherAlarm> {
  final ValueNotifier<List<Map<String, dynamic>>> vnForecastNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> vnHourlyNotifier = ValueNotifier([]);

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
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&daily=temperature_2m_min,temperature_2m_max,weathercode'
      '&hourly=temperature_2m,weathercode,precipitation_probability'
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

      // ---- Extract today's hourly weather ----
      final now = DateTime.now();
      final hourlyTimes = List<String>.from(data['hourly']['time']);
      final hourlyTemps = List<double>.from(data['hourly']['temperature_2m']);
      final hourlyCodes = List<int>.from(data['hourly']['weathercode']);
      final hourlyPops = List<num>.from(data['hourly']['precipitation_probability']);

      vnHourlyNotifier.value = [];
      for (int i = 0; i < hourlyTimes.length; i++) {
        final time = DateTime.parse(hourlyTimes[i]).toLocal();
        if (time.day == now.day && time.month == now.month && time.year == now.year) {
          vnHourlyNotifier.value.add({
            'hour': time.hour,
            'temp': hourlyTemps[i],
            'icon': hourlyCodes[i],
            'pop': hourlyPops[i],
          });
        }
      }
      // ---- end hourly ----
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
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      appBar: AppBar(
        title: const Text('이번 주 날씨'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: vnForecastNotifier,
                  builder: (context, forecast, _) {
                    return forecast.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: forecast.map((item) {
                              final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _weekdayKorKor(date.weekday),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      mapWeatherCodeToEmoji(item['icon']),
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    Text(
                                      '${item['max'].round()}° / ${item['min'].round()}°',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                  },
                ),
                Gaps.v20,
                const Text(
                  '오늘의 시간별 날씨',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Gaps.v10,
                SizedBox(
                  height: 100,
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: vnHourlyNotifier,
                    builder: (context, hourly, _) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hourly.length,
                        itemBuilder: (context, index) {
                          final h = hourly[index];
                          return Container(
                            width: 72,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${h['hour']}시', style: const TextStyle(color: Colors.white)),
                                Text(mapWeatherCodeToEmoji(h['icon']), style: const TextStyle(fontSize: 22)),
                                Text('${h['temp'].round()}°', style: const TextStyle(color: Colors.white)),
                                Text('💧${h['pop']}%', style: const TextStyle(fontSize: 12, color: Colors.white)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _weekdayKorKor(int weekday) {
    const weekdaysKor = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdaysKor[(weekday - 1) % 7];
  }
}
