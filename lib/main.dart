import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';
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
  // 알림 권한 요청 (iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // APNs/FCM 토큰 확인 및 요청
  if (Platform.isIOS) {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      Global.fcmToken = await FirebaseMessaging.instance.getToken();
      print('✅ FCM 토큰(iOS): ${Global.fcmToken}');
    } else {
      print('❌ APNs 토큰이 아직 없음, FCM 토큰 요청 지연됨');
    }
  } else {
    Global.fcmToken = await FirebaseMessaging.instance.getToken();
    if (Global.fcmToken != null) {
      print('✅ FCM 토큰(Android): ${Global.fcmToken}');
    } else {
      print('❌ FCM 토큰을 받아오지 못했습니다.');
    }
  }

  CourtNotificationFixedDayEachMonth.setupFirebaseForegroundHandler();

  AuthRepository.initialize(appKey: '26476b06b753504ad14bb998f377645f');

  await initializeNotification();

  ///카카오로그인
  KakaoSdk.init(
    nativeAppKey: 'a68764f8b9c47a0adfaaa1c72d4f7ef2',
    javaScriptAppKey: 'b7483b27f8dca683d382b98e5d85c550',
  );

  ///네이버로그인
  if (Platform.isIOS) {
    NaverLoginSDK.initialize(
      clientId: 'DTY9BzaNLS7fQGjW3Z1T',
      clientSecret: '9sVNkL7iRd',
      urlScheme: 'naverDTY9BzaNLS7fQGjW3Z1T', // ✅ iOS에서 필수
    );
  } else {
    NaverLoginSDK.initialize(
      clientId: 'DTY9BzaNLS7fQGjW3Z1T',
      clientSecret: '9sVNkL7iRd',
    );
  }

  ///네이버맵
  await FlutterNaverMap().init(
    clientId: '5s09r12irx',
    onAuthFailed: (ex) {
      print('네이버 지도 인증 실패: $ex');
    },
  );

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

  // Initialize FlutterLocalNotificationsPlugin before setting up message listener
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,

      ),
    ),
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('📥 포그라운드 메시지 수신: ${message.notification?.title} / ${message.notification?.body}');
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
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  });
  // 알림 권한 요청 (iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
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
