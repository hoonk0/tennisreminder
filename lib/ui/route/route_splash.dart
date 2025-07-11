import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tennisreminder_app/ui/route/route_main.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import '../../const/static/global.dart';
import '../../service/stream/stream_me.dart';
import 'auth/route_auth_login.dart';

class RouteSplash extends ConsumerStatefulWidget {
  const RouteSplash({super.key});

  @override
  ConsumerState<RouteSplash> createState() => _RouteSplashState();
}

class _RouteSplashState extends ConsumerState<RouteSplash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkUserAndInitData();
  }

  Future<void> _checkUserAndInitData() async {
    final pref = await SharedPreferences.getInstance();
    final uid = pref.getString(keyUid);

    try {
      Global.uid = uid;

      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async {
          await Future.delayed(const Duration(milliseconds: 2000));

          /// FirebaseAuth에 등록되어 있지 않음: 아무것도 안함
          if (uid == null) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RouteAuthLogin()));
          }

          /// FirebaseAuth에 등록되어 있음
          else {
            StreamMe.listenMe();

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RouteMain(),
                settings: const RouteSettings(name: 'home'),
              ),
            );
          }
        },
      );
    } catch (e) {

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RouteAuthLogin()));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Global.refSplash = ref;
    Global.contextSplash = context;
    return Scaffold(
      backgroundColor: colorWhite,
      body: Center(
        child: Image.asset(
          'assets/images/mainlogo.png',
          width: 80.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
