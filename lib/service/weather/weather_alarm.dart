import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherAlarm extends StatefulWidget {
  const WeatherAlarm({super.key});

  @override
  State<WeatherAlarm> createState() => _WeatherAlarmState();
}

class _WeatherAlarmState extends State<WeatherAlarm> {
  double? temperature;
  String? iconCode;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const lat = 37.5665;
    const lon = 126.9780;
    const apiKey = '71b8e24b54fdeb1ecc823f5c0673c91d'; // Replace with your OpenWeatherMap API key
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'];
        iconCode = data['weather'][0]['icon'];
      });
    } else {
      debugPrint('날씨 정보 요청 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: temperature != null && iconCode != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/$iconCode@2x.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 8),
                Text('${temperature!.toStringAsFixed(1)}℃'),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
