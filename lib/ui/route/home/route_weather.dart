import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tennisreminder_app/ui/component/loading_bar.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'dart:convert';

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
    fetchWeather();
  }

  ///날씨불러오기
  Future<void> fetchWeather() async {
    ///좌표 일단 서울날씨로 고정
    const lat = 37.5665;
    const lon = 126.9780;
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&daily=temperature_2m_min,temperature_2m_max,weathercode,precipitation_probability_mean'
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
      final dailyPops = List<num>.from(data['daily']['precipitation_probability_mean']);

      ///추출한 데이터 합체
      vnForecastNotifier.value = List.generate(times.length, (index) {
        return {
          'dt': DateTime.parse(times[index]).millisecondsSinceEpoch ~/ 1000,
          'min': minTemps[index],
          'max': maxTemps[index],
          'icon': weatherCodes[index],
          'pop': dailyPops[index],
        };
      });
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
        if (time.isAfter(now) && time.isBefore(now.add(const Duration(hours: 24)))) {
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


  ///맵코드 -> 날씨이미지 경로로 변경
  String mapWeatherCodeToAsset(int code) {
    if (code == 0) return 'assets/images/sunny.png';
    if (code <= 3) return 'assets/images/sunnycloudy.png';
    if (code <= 48) return 'assets/images/cloudy.png';
    if (code <= 57) return 'assets/images/rainy.png';
    if (code <= 67) return 'assets/images/rainy.png';
    if (code <= 77) return 'assets/images/snowy.png';
    if (code <= 82) return 'assets/images/snowy.png';
    if (code <= 99) return 'assets/images/thunder.png';
    return '❓';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('날씨'),
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: fetchWeather(),
          builder: (context, snapshot) {
            return snapshot.connectionState != ConnectionState.done
                ? const Center(child: LoadingBar())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /// 맨 위 현재 날씨 온도
                        Column(
                          children: [
                            vnHourlyNotifier.value.isNotEmpty
                                ? Image.asset(mapWeatherCodeToAsset(vnHourlyNotifier.value.first['icon']), width: 100, height: 100)
                                : const Icon(Icons.error, size: 64),
                            Text(
                              '${vnHourlyNotifier.value.isNotEmpty ? vnHourlyNotifier.value.first['temp'].round() : '--'}°c',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            ///나중에 현재위치로 변경 (동)
                            const Text(
                              '서울특별시',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        Gaps.v20,

                        /// 시간별 날씨
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '시간별 날씨',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Gaps.v10,
                            Container(

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey.shade100,
                              ),
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: vnHourlyNotifier.value.length,
                                itemBuilder: (context, index) {
                                  final h = vnHourlyNotifier.value[index];
                                  return Container(
                                    width: 64,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    color: Colors.grey.shade100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${h['hour']}시', style: const TextStyle(color: Colors.black)),
                                        Image.asset(mapWeatherCodeToAsset(h['icon']), width: 32, height: 32),
                                        Text('${h['temp'].round()}°', style: const TextStyle(color: Colors.black)),
                                        Text('${h['pop']}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Gaps.v20,

                        /// 주간 날씨
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '주간 날씨',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Gaps.v10,
                              ...vnForecastNotifier.value.map((item) {
                                final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_weekdayKorKor(date.weekday), style: const TextStyle(color: Colors.black)),
                                      Row(
                                        children: [
                                          Image.asset(mapWeatherCodeToAsset(item['icon']), width: 32, height: 32),
                              /*            Text(
                                            ' ${item['pop']}%'
                                          )*/
                                        ],
                                      ),
                                      Text(
                                        '${item['max'].round()}° / ${item['min'].round()}°',
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  String _weekdayKorKor(int weekday) {
    const weekdaysKor = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdaysKor[(weekday - 1) % 7];
  }
}
