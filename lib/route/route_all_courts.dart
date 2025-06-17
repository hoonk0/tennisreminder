import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as MasonryGridView;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/moderl_filter_all_courts.dart';

import '../state_management/future/future_fetch.dart';
import '../state_management/pagination/pagination_court.dart';
import '../state_management/providers/providers.dart';
import '../ui/component/card_court_preview.dart';
import '../ui/component/court_district_filter.dart';
import 'package:tennisreminder_core/const/value/enum.dart';



class RouteAllCourts extends ConsumerStatefulWidget {
  const RouteAllCourts({super.key});

  @override
  ConsumerState<RouteAllCourts> createState() => _RouteAllCourtsState();
}
class _RouteAllCourtsState extends ConsumerState<RouteAllCourts> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(providerCourtFilter);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (filter.selectedDistricts.isEmpty) {
        await FutureFetch.fetchCourtAll(
            filter: const ModelCourtFilter(selectedDistricts: []));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('전체 코트 보기')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CourtDistrictFilter(
              selected: filter.selectedDistricts.isNotEmpty ? filter.selectedDistricts.first : null,
              onChanged: (district) async {
                if (district != null) {
                  final newFilter = ModelCourtFilter(selectedDistricts: [district]);
                  ref.read(providerCourtFilter.notifier).state = newFilter;

                  /// 필터 바뀐 후 새로 패치
                  await FutureFetch.fetchCourtAll(filter: newFilter);
                }
              },
            ),
          ),
          Expanded(
            child: PaginationCourt(
              filter: filter,
            ),
          ),
        ],
      ),
    );
  }
}