

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennisreminder_app/state_management/model_base/model_base_court.dart';
import 'package:tennisreminder_core/const/model/moderl_filter_all_courts.dart';

final StateProviderFamily<CourtBase, ModelCourtFilter?> providerCourtAll
    = StateProviderFamily<CourtBase, ModelCourtFilter>((ref, modelCourtFilter) {
return CourtLoading();
});