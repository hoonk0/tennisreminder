import 'dart:async';

import 'package:flutter/material.dart';

class Throttler {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Throttler({required this.milliseconds});

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

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}