import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';

import '../../ui/component/custom_throttler.dart';

class Global {
  static BuildContext? contextSplash;

  static ValueNotifier<ModelUser?> userNotifier = ValueNotifier(null);
  static String? uid;

  static ValueNotifier<int> tabIndexNotifier = ValueNotifier(0);

  static SharedPreferences? pref;

  static WidgetRef? refSplash;

  static final CustomThrottler throttler = CustomThrottler(milliseconds: 1000);
}
