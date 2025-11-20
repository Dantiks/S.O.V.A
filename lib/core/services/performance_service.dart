import 'package:flutter/foundation.dart';

class PerformanceService {
  final Map<String, DateTime> _startTimes = {};

  void startTrace(String name) {
    _startTimes[name] = DateTime.now();
  }

  void stopTrace(String name) {
    final start = _startTimes[name];
    if (start != null) {
      final duration = DateTime.now().difference(start);
      debugPrint('[$name] took ${duration.inMilliseconds}ms');
      _startTimes.remove(name);
    }
  }
}
