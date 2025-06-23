import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import '../../const/static/global.dart';
import '../../ui/route/route_splash.dart';
import '../utils/utils.dart';

class StreamMe {
  static StreamSubscription? streamSubscription;

  static Future<void> listenMe() async {
    debugPrint("listenMe ${Global.uid}");
    streamSubscription = FirebaseFirestore.instance.collection(keyUser).doc(Global.uid).snapshots().listen(
      (event) async {
        debugPrint('listenMe 업데이트 시작 ${Global.uid}');
        try {
          Global.userNotifier.value = ModelUser.fromJson(event.data()!);
        } catch (e, s) {
          Utils.toast(desc: '유저가 존재하지 않습니다.');
          final pref = await SharedPreferences.getInstance();
          pref.remove(keyUid);
          Navigator.of(Global.contextSplash!).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
        }
      },
    );
  }
}
