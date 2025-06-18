import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';
import 'package:sizer/sizer.dart';
import 'package:tennisreminder_app/ui/route/route_splash.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';

import 'const/static/global.dart';
import 'firebase_options.dart';

/*Future<void> _setupInteractedMessage() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  debugPrint('🔔 종료 상태에서 알림 클릭됨: ${message.notification?.title}');
  // TODO: Add navigation or processing logic here
}*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  KakaoSdk.init(
    nativeAppKey: 'de368876dad11f1f070baef6058f8d49',
    loggingEnabled: true,
  );

  /*
  NaverLoginSDK.initialize(
      urlScheme: "sportsdirector",
      clientId:"BjgiZmXeS1CuztyUF6wK",
      clientSecret: "pfZ5h6DQRU",
      clientName: "스포츠지도자"
  );
*/


  /// 좋아요 코트, 알람코트 불러오기
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await _loadFavoriteCourts();
    await syncCourtAlarms(user.uid);
  }


  runApp(const ProviderScope(child: MyApp()));
}

///최초1번 글로벌노티파이어 사용을 위해 불러옴
Future<void> _loadFavoriteCourts() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection(keyCourt)
      .where(keyLikedUserUids, arrayContains: user.uid)
      .get();

  final courts = snapshot.docs.map((e) => ModelCourt.fromJson(e.data())).toList();
  Global.vnFavoriteCourts.value = courts;
}

///최초1번 글로벌노티파이어 사용을 위해 불러옴
Future<void> syncCourtAlarms(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(keyCourtAlarms)
      .where(keyUserUid, isEqualTo: uid)
      .orderBy(keyDateCreate, descending: true)
      .get();

  final list = snapshot.docs.map((e) => ModelCourtAlarm.fromJson(e.data())).toList();
  Global.vnCourtAlarms.value = list;
  debugPrint('📥 알람 동기화 완료: ${list.length}개 불러옴');
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          navigatorObservers: [RouteObserver()],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Pretendard',
            scaffoldBackgroundColor: colorWhite,
            appBarTheme: const AppBarTheme(
              backgroundColor: colorWhite,
              shadowColor: null,
              scrolledUnderElevation: 0,
              foregroundColor: colorGray900,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TS.s18w600(colorGray900),
              iconTheme: IconThemeData(color: colorGray900),
            ),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          ),
          home: const RouteSplash(),
        );
      },
    );
  }
}
