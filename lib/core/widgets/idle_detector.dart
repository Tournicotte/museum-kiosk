import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/core/config/app_config.dart';

// Wraps any screen that must reset to Attract on idle.
// Any pointer event (tap, scroll) resets the countdown.
// Cancel the timer in dispose — enforced by this widget.
class IdleDetector extends ConsumerStatefulWidget {
  const IdleDetector({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<IdleDetector> createState() => _IdleDetectorState();
}

class _IdleDetectorState extends ConsumerState<IdleDetector> {
  late Timer _timer;

  void _startTimer() {
    final seconds = ref.read(appConfigProvider).idleTimeoutSeconds;
    _timer = Timer(Duration(seconds: seconds), _onIdle);
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  void _onIdle() {
    if (mounted) context.go(KioskRoutes.attract);
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _resetTimer(),
        child: widget.child,
      );
}
