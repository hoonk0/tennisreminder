import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod/src/framework.dart';
import 'package:tennisreminder_app/state_management/model_base/model_base_court.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/moderl_filter_all_courts.dart';
import 'package:tennisreminder_core/const/value/keys.dart';

import '../../const/static/global.dart';
import '../providers/providers.dart';

class FutureFetch {
  static Future<void> fetchCourtAll({
    int fetchCount = 20,
    bool isForce = false,
  }) async {
    final pState = Global.refSplash!.read(
      providerCourtAll(ModelCourtFilter(selectedDistricts: [])),
    );

    ///데이터 로딩중이면 그냥 return
    if (pState is CourtFetchMore) {
      debugPrint('이미 데이터 받아오는 중이라 종료');
      return;
    }

    ///데이터 처음 받음
    if (pState is CourtLoading || isForce) {
      final courtQs =
          await FirebaseFirestore.instance
              .collection(keyCourt)
              .orderBy(keyDateCreate, descending: true)
              .limit(fetchCount)
              .get();

      final listCourt =
          courtQs.docs.map((e) => ModelCourt.fromJson(e.data())).toList();
      Global.refSplash!
          .read(
            providerCourtAll(ModelCourtFilter(selectedDistricts: [])).notifier,
          )
          .state = CourtNormal(
        listCourt: listCourt,
        lastDocumentSnapshot: courtQs.docs.last,
        isEndOfData: courtQs.docs.length < fetchCount,
      );
      return;
    }

    ///데이터 추가로 받음(기본 + 추가)
    if(pState is CourtNormal){
      ///추가데이터 없으면 리턴
      if(pState.isEndOfData || pState.lastDocumentSnapshot == null) return;

      Global.refSplash!.read(providerCourtAll(ModelCourtFilter(selectedDistricts: [])).notifier).state =
          CourtFetchMore(
            listCourt: List.from(pState.listCourt),
            lastDocumentSnapshot: pState.lastDocumentSnapshot,
          );

      ///다음 페이지 불러오기
      final courtQs = await FirebaseFirestore.instance
          .collection(keyCourt)
          .orderBy(keyDateCreate, descending: true)
          .startAfterDocument(pState.lastDocumentSnapshot!)
          .limit(fetchCount)
          .get();

      final addedCourts = courtQs.docs.map((e) => ModelCourt.fromJson(e.data())).toList();

      final newList = [...pState.listCourt, ...addedCourts];

      Global.refSplash!.read(providerCourtAll(ModelCourtFilter(selectedDistricts: [])).notifier).state =
          CourtNormal(
            listCourt: newList,
            lastDocumentSnapshot: courtQs.docs.last,
            isEndOfData: courtQs.docs.length < fetchCount,
          );
    }

  }
}
