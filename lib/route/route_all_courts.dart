import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as MasonryGridView;
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/moderl_filter_all_courts.dart';

import '../state_management/pagination/pagination_court.dart';
import '../ui/component/card_court_preview.dart';
import '../ui/component/court_district_filter.dart';
import 'package:tennisreminder_core/const/value/enum.dart';

class RouteAllCourts extends StatefulWidget {
  const RouteAllCourts({super.key});

  @override
  State<RouteAllCourts> createState() => _RouteAllCourtsState();
}

class _RouteAllCourtsState extends State<RouteAllCourts> {
  SeoulDistrict? _selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전체 코트 보기')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CourtDistrictFilter(
              selected: _selectedDistrict,
              onChanged: (district) {
                setState(() {
                  _selectedDistrict = district;
                });
              },
            ),
          ),
          Expanded(
            child: PaginationCourt(
              filter: ModelCourtFilter(
                selectedDistricts: _selectedDistrict != null ? [_selectedDistrict!] : [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
