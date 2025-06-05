import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:craft_supply_organiser/presentation/screens/home_screen.dart';
import 'package:craft_supply_organiser/presentation/screens/splash_screen.dart';
import 'package:craft_supply_organiser/presentation/screens/inventory/inventory_screen.dart';
import 'package:craft_supply_organiser/presentation/screens/settings/settings_screen.dart';
import 'package:craft_supply_organiser/presentation/screens/business/business_dashboard_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
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
        path: '/business',
        name: 'business',
        builder: (context, state) => const BusinessDashboardScreen(),
      ),
    ],
  );
}