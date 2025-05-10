import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tennisreminder_app/state_management/model_base/model_base_court.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/model/moderl_filter_all_courts.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/utils_enum/utils_enum.dart';
import '../../const/static/global.dart';
import '../../service/utils/utils.dart';
import '../providers/providers.dart';

class FutureFetch {
  static Future<void> fetchCourtAll({
    required ModelCourtFilter filter,
    int fetchCount = 15,
    bool isForce = false,
  }) async {
    final pState = Global.refSplash!.read(providerCourtAll(filter));
    debugPrint('[PAGINATION] fetchCourtAll called (initial: ${pState is CourtLoading}, fetchMore: ${pState is CourtNormal})');

    Query courtQuery = FirebaseFirestore.instance.collection(keyCourt);
    if (filter.selectedDistricts.isNotEmpty) {
      final districts = filter.selectedDistricts
          .map((e) => UtilsEnum.getNameFromSeoulDistrict(e))
          .toList();
      courtQuery = courtQuery.where(keyCourtDistrict, whereIn: districts);
    }

    ///데이터 로딩중이면 그냥 return
    if (pState is CourtFetchMore) {
      return;
    }

    ///데이터 처음 받음
    if (pState is CourtLoading || isForce) {
      final courtQs =
          await courtQuery
              .orderBy(keyDateCreate, descending: true)
              .limit(fetchCount)
              .get();

      final listCourt =
          courtQs.docs.map((e) => ModelCourt.fromJson(e.data() as Map<String, dynamic>)).toList();
      debugPrint('[PAGINATION] Initial fetch complete: ${listCourt.length} courts');
      Global.refSplash!
          .read(
            providerCourtAll(filter).notifier,
          )
          .state = CourtNormal(
        listCourt: listCourt,
        lastDocumentSnapshot: courtQs.docs.isNotEmpty
            ? courtQs.docs.last as DocumentSnapshot<Map<String, dynamic>>
            : null,
        isEndOfData: courtQs.docs.length < fetchCount,
      );
      return;
    }

    ///데이터 추가로 받음(기본 + 추가)
    if(pState is CourtNormal){
      ///추가데이터 없으면 리턴
      if(pState.isEndOfData || pState.lastDocumentSnapshot == null) return;

      debugPrint('[PAGINATION] Fetching more courts...');
      Global.refSplash!.read(providerCourtAll(filter).notifier).state =
          CourtFetchMore(
            listCourt: List.from(pState.listCourt),
            lastDocumentSnapshot: pState.lastDocumentSnapshot,
          );

      ///다음 페이지 불러오기
      final courtQs = await courtQuery
          .orderBy(keyDateCreate, descending: true)
          .startAfterDocument(pState.lastDocumentSnapshot!)
          .limit(fetchCount)
          .get();

      if (courtQs.docs.isEmpty) {
        debugPrint('[PAGINATION] No more courts to load');
        Global.refSplash!.read(providerCourtAll(filter).notifier).state =
            CourtNormal(
              listCourt: pState.listCourt,
              lastDocumentSnapshot: pState.lastDocumentSnapshot,
              isEndOfData: true,
            );
        await Future.delayed(Duration(milliseconds: 100)); // ensure UI catches up
        debugPrint('[PAGINATION] Toast about to show: 마지막 데이터 입니다');
        Utils.toast(desc: '마지막 데이터 입니다');
        return;
      }
      final addedCourts = courtQs.docs.map((e) => ModelCourt.fromJson(e.data() as Map<String, dynamic>)).toList();

      final newList = [...pState.listCourt, ...addedCourts];
      debugPrint('[PAGINATION] Fetched ${addedCourts.length} more courts (total: ${newList.length})');
      final isEndOfData = courtQs.docs.length < fetchCount;
      Global.refSplash!.read(providerCourtAll(filter).notifier).state =
          CourtNormal(
            listCourt: newList,
            lastDocumentSnapshot: courtQs.docs.last as DocumentSnapshot<Map<String, dynamic>>,
            isEndOfData: isEndOfData,
          );
      if (isEndOfData) {
        debugPrint('[PAGINATION] Toast about to show: 마지막 데이터 입니다');
        await Future.delayed(Duration(milliseconds: 100)); // ensure UI is ready
        Utils.toast(desc: '마지막 데이터 입니다');
      }
    }

  }
}
