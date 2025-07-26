import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:artisanarc/presentation/screens/home_screen.dart';
import 'package:artisanarc/presentation/onboarding/onboarding_screen.dart';
import 'package:artisanarc/features/inventory/presentation/inventory_screen.dart';
import 'package:artisanarc/features/inventory/presentation/add_inventory_item_screen.dart';
import 'package:artisanarc/features/settings/presentation/settings_screen.dart';
import 'package:artisanarc/features/business/presentation/business_dashboard_screen.dart';
import 'package:artisanarc/features/business/presentation/daily_sales_screen.dart';
import 'package:artisanarc/features/business/presentation/new_sale_entry_screen.dart';
import 'package:artisanarc/features/project/presentation/project_list_screen.dart';
import 'package:artisanarc/features/project/presentation/project_planner_screen.dart';
import 'package:artisanarc/features/qr/presentation/qr_scanner_page.dart';
import 'package:artisanarc/features/compliance/presentation/compliance_screen.dart';
import 'package:artisanarc/features/shopping/presentation/shopping_list_overview_screen.dart';
import 'package:artisanarc/features/shopping/presentation/shopping_list_detail_screen.dart';
import 'package:artisanarc/features/ai/presentation/craft_ai_widget.dart';
import 'package:artisanarc/presentation/screens/export/export_screen.dart';
import 'package:artisanarc/presentation/screens/error_screen.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => ErrorScreen(error: state.error?.message),
    routes: [
       GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const HomeScreen(),
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
        routes: [
          GoRoute(
            path: 'add',
            name: 'addInventoryItem',
            builder: (context, state) => const AddInventoryItemScreen(),
          ),
        ],
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
        routes: [
          GoRoute(
            path: 'sales',
            name: 'dailySales',
            builder: (context, state) => const DailySalesScreen(),
          ),
          GoRoute(
            path: 'new-sale',
            name: 'newSale',
            builder: (context, state) => const NewSaleEntryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'addProject',
            builder: (context, state) => const ProjectPlannerScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'editProject',
            builder: (context, state) {
              final projectId = state.pathParameters['id'];
              if (projectId == null) {
                return const ErrorScreen(error: 'Project ID is missing');
              }
              return ProjectPlannerScreen(projectId: projectId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/scan-qr',
        name: 'scanQrCode',
        builder: (context, state) => const QRScannerPage(),
      ),
      GoRoute(
        path: '/compliance',
        name: 'compliance',
        builder: (context, state) => const ComplianceScreen(),
      ),
      GoRoute(
        path: '/shopping-lists',
        name: 'shoppingLists',
        builder: (context, state) => const ShoppingListOverviewScreen(),
        routes: [
          GoRoute(
            path: ':listId',
            name: 'shoppingListDetail',
            builder: (context, state) {
              final listId = state.pathParameters['listId'];
              if (listId == null) {
                return const ErrorScreen(error: 'List ID is missing');
              }
              return ShoppingListDetailScreen(shoppingListId: listId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/ai-assistant/:craftType',
        name: 'aiAssistant',
        builder: (context, state) {
          final craftType = state.pathParameters['craftType'];
          if (craftType == null) {
            return const ErrorScreen(error: 'Craft type is missing');
          }
          return CraftAIWidget(craft: craftType);
        },
      ),
      GoRoute(
        path: '/export',
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),
    ],
  );
}
