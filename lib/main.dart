import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sizer/sizer.dart';
import 'package:tennisreminder_app/service/notification/court_notification_setting_upgrade.dart';
import 'package:tennisreminder_app/ui/route/route_splash.dart';
import 'package:tennisreminder_core/const/model/model_court_alarm.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'const/static/global.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AuthRepository.initialize(appKey: '26476b06b753504ad14bb998f377645f');

  await initializeNotification();

  KakaoSdk.init(
    nativeAppKey: 'a68764f8b9c47a0adfaaa1c72d4f7ef2',
    javaScriptAppKey: 'b7483b27f8dca683d382b98e5d85c550',
  );

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print('✅ 로그인된 사용자 UID: ${user.uid}');
    await _loadFavoriteCourts();
    await syncCourtAlarms(user.uid);
  } else {
    print('❌ 로그인된 사용자 없음 (FirebaseAuth.currentUser == null)');
  }

  runApp(const ProviderScope(child: MyApp()));
}

///알람 세팅
Future<void> initializeNotification() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    '기본 채널',
    description: '기본 알림 채널',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            '기본 채널',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_stat_notify',
          ),
        ),
      );
    }
  });
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
      .where(keyUid, isEqualTo: uid)
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
