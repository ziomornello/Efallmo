import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'utils/constants.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'models/bonus.dart';
import 'widgets/deep_link_listener.dart';

late final GoRouter _router;

Future<void> _initSupabase() async {
  try {
    await Supabase.initialize(
      url: 'https://xpinibmjluzxnbovwgeq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhwaW5pYm1qbHV6eG5ib3Z3Z2VxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4NDM5MzgsImV4cCI6MjA3MzQxOTkzOH0.54ZvjavkMv8wp718DUIkbKo1kA3sRGFZaC6vPT0wKRY',
    );
  } catch (e, st) {
    debugPrint('Supabase init error: $e\n$st');
  }
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final loc = state.matchedLocation;

      if (user == null) {
        final protected = loc.startsWith('/dashboard') || loc.startsWith('/guide') || loc.startsWith('/admin');
        if (protected) return '/landing';
        if (loc == '/') return '/landing';
        return null;
      } else {
        if (loc == '/' || loc == '/landing' || loc == '/login' || loc == '/register' || loc == '/auth') {
          return '/dashboard';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/guide',
        redirect: (context, state) {
          final extra = state.extra;
          if (extra is! Bonus) {
            return '/dashboard';
          }
          return null;
        },
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Bonus) {
            return GuideScreen(bonus: extra);
          }
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught zone error: $error\n$stack');
      return true;
    };

    await _initSupabase();
    _router = _createRouter();

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    debugPrint('Zone uncaught: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Efallmò',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: _router,
      builder: (context, child) => DeepLinkListener(child: child ?? const SizedBox.shrink()),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}