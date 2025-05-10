import 'package:flutter/material.dart';
import 'package:tennisreminder_app/service/notification/notification_helper.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';

import '../../service/notification/notification_helper.dart';

class RouteCourtInformation extends StatefulWidget {
  final ModelCourt court;

  const RouteCourtInformation({required this.court, Key? key}) : super(key: key);

  @override
  State<RouteCourtInformation> createState() => _RouteCourtInformationState();
}

class _RouteCourtInformationState extends State<RouteCourtInformation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.court.courtName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.court.courtAddress,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.court.courtInfo,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  if (widget.court.reservationUrl.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        // implement launch URL
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('예약하러 가기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                  ElevatedButton(
                    onPressed: () {
                      NotificationHelper.scheduleNotification('5초후 알람', '알람', 5);
                    },
                    child: const Text('alarm on'),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      NotificationHelper().cancelAllNotifications();
                    },
                    child: const Text('alarm off'),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      NotificationHelper.showInstantNotification();
                    },
                    child: const Text('알람 테스트'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
