

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';

class CourtBase {
  const CourtBase();
}

class CourtLoading extends CourtBase {}

class CourtError extends CourtBase {
  final String message;

  const CourtError({required this.message});
}

class CourtNormal extends CourtBase {
  final List<ModelCourt> listCourt;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocumentSnapshot;
  final bool isEndOfData;

  const CourtNormal({
    required this.listCourt,
    this.lastDocumentSnapshot,
    this.isEndOfData = false,
  });
}

class CourtFetchMore extends CourtNormal {
  const CourtFetchMore({
    required super.listCourt,
    super.lastDocumentSnapshot,
    super.isEndOfData,
  });
}