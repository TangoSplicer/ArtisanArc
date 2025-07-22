import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:artisanarc/presentation/onboarding/onboarding_screen.dart';
import 'package:artisanarc/presentation/screens/export/export_screen.dart';
import 'package:artisanarc/presentation/screens/home_screen.dart';
import 'package:artisanarc/presentation/screens/inventory/inventory_screen.dart';
import 'package:artisanarc/presentation/screens/projects/project_screen.dart';
import 'package:artisanarc/presentation/screens/settings/settings_screen.dart';
import 'package:artisanarc/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectScreen(),
      ),
      GoRoute(
        path: '/export',
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),
    ],
  );

  static GoRouter createFallbackRouter(Widget initialScreen) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => initialScreen,
        ),
      ],
    );
  }
}