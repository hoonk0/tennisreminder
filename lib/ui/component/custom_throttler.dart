import 'dart:async';
import 'package:flutter/material.dart';

class CustomThrottler {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  CustomThrottler({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer == null) {
      action.call();

      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _timer?.cancel();
        _timer = null;
      });
    }
  }
}
