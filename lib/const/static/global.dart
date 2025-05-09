import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisreminder_core/const/model/model_user.dart';

class Global {
  static BuildContext? contextSplash;

  static ValueNotifier<ModelUser?> userNotifier = ValueNotifier(null);
  static String? uid;

  static ValueNotifier<int> tabIndexNotifier = ValueNotifier(0);

  static SharedPreferences? pref;
}
