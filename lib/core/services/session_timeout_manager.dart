import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/core/navigation/routes.dart';
import 'package:go_router/go_router.dart';

class AppLifecycleManager {
  static bool isFreshBoot = true;
}

class SessionTimeoutListener extends StatefulWidget {
  final Widget child;
  final AppLocalDataSource localDataSource;

  const SessionTimeoutListener({
    super.key,
    required this.child,
    required this.localDataSource,
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener> with WidgetsBindingObserver {
  Timer? _idleTimer;
  static const _timeoutDuration = Duration(minutes: 15);
  
  bool _isLoggedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetIdleTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }

  void _resetIdleTimer() {
    if (_isLoggedOut) return;
    
    _idleTimer?.cancel();
    _idleTimer = Timer(_timeoutDuration, _performLogout);
    
    // Save last active timestamp to storage
    widget.localDataSource.saveLastActiveTime(DateTime.now());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isLoggedOut) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App went to background - record timestamp
      widget.localDataSource.saveLastActiveTime(DateTime.now());
    } else if (state == AppLifecycleState.resumed) {
      // App returned to foreground - check if background duration exceeded timeout
      _checkBackgroundTimeout();
    }
  }

  Future<void> _checkBackgroundTimeout() async {
    final lastActive = await widget.localDataSource.getLastActiveTime();
    if (lastActive != null) {
      final difference = DateTime.now().difference(lastActive);
      if (difference >= _timeoutDuration) {
        _performLogout();
      } else {
        _resetIdleTimer();
      }
    } else {
      _resetIdleTimer();
    }
  }

  Future<void> _performLogout() async {
    if (_isLoggedOut) return;
    
    final session = await widget.localDataSource.getSession();
    if (session == null || session.tokens == null) {
      // No active session, no need to log out
      return;
    }

    _isLoggedOut = true;
    _idleTimer?.cancel();

    debugPrint('SessionTimeoutListener: Logging out due to 15-minute inactivity.');

    await widget.localDataSource.clearSession();
    await widget.localDataSource.clearLastActiveTime();

    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go('/login');
    } else {
      rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetIdleTimer(),
      onPointerHover: (_) => _resetIdleTimer(),
      onPointerMove: (_) => _resetIdleTimer(),
      onPointerSignal: (_) => _resetIdleTimer(),
      onPointerUp: (_) => _resetIdleTimer(),
      child: widget.child,
    );
  }
}
