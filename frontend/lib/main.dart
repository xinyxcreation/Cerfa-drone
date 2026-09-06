import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/models/current_user.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/services/auth_service.dart';
import 'core/navigation/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const CerfaDroneApp(),
  );
}

class CerfaDroneApp extends StatefulWidget {
  const CerfaDroneApp({
    super.key,
  });

  @override
  State<CerfaDroneApp> createState() =>
  _CerfaDroneAppState();
}

class _CerfaDroneAppState
extends State<CerfaDroneApp> {

  final AuthService _authService =
  const AuthService();

  CurrentUser? _currentUser;

  bool _loggedIn = false;
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    final authenticated =
    await _authService.hasSession();

    if (!authenticated) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loggedIn = false;
        _checkingSession = false;
      });

      return;
    }

    try {
      final user =
      await _authService.me();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = user;
        _loggedIn = true;
        _checkingSession = false;
      });
    } catch (_) {
      await _authService.logout();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = null;
        _loggedIn = false;
        _checkingSession = false;
      });
    }
  }

  void _onLoggedIn() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user =
      await _authService.me();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = user;
        _loggedIn = true;
      });
    } catch (_) {
      await _authService.logout();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = null;
        _loggedIn = false;
      });
    }
  }

  void _onLogout() {
    setState(() {
      _currentUser = null;
      _loggedIn = false;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],

      debugShowCheckedModeBanner: false,

      title: 'CERFA DRONE',

      theme: AppTheme.light(),

      home: _checkingSession
      ? const _LoadingPage()
      : _loggedIn && _currentUser != null
      ? AppShell(
        user: _currentUser!,
        onLogout: _onLogout,
      )
      : LoginPage(
        onLoggedIn: _onLoggedIn,
      ),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Scaffold(
      backgroundColor:
      Color(0xFFF5F5F5),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE30613),
        ),
      ),
    );
  }
}
