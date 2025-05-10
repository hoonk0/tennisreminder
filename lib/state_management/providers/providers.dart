import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennisreminder_app/state_management/model_base/model_base_court.dart';
import 'package:tennisreminder_core/const/model/moderl_filter_all_courts.dart';
import 'package:tennisreminder_core/const/value/enum.dart';


final StateProviderFamily<CourtBase, ModelCourtFilter?> providerCourtAll =
    StateProviderFamily<CourtBase, ModelCourtFilter?>((ref, modelFilter) {
  return CourtLoading();
});

final providerCourtFilter = StateProvider<ModelCourtFilter>((ref) {
  return const ModelCourtFilter(selectedDistricts: []);
});

