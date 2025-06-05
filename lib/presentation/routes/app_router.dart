import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:artisanarc/presentation/screens/home_screen.dart';
import 'package:artisanarc/presentation/onboarding/onboarding_screen.dart'; // Added onboarding
import 'package:artisanarc/features/inventory/presentation/inventory_screen.dart';
import 'package:artisanarc/features/inventory/presentation/add_inventory_item_screen.dart'; // Added
import 'package:artisanarc/features/settings/presentation/settings_screen.dart';
import 'package:artisanarc/features/business/presentation/business_dashboard_screen.dart';
import 'package:artisanarc/features/business/presentation/daily_sales_screen.dart'; // Added
import 'package:artisanarc/features/business/presentation/new_sale_entry_screen.dart'; // Added
import 'package:artisanarc/features/project/presentation/project_list_screen.dart'; // Added ProjectListScreen
import 'package:artisanarc/features/project/presentation/project_planner_screen.dart'; // Added ProjectPlannerScreen
import 'package:artisanarc/features/qr/presentation/qr_scanner_page.dart'; // Added QRScannerPage
import 'package:artisanarc/features/compliance/presentation/compliance_screen.dart'; // Added ComplianceScreen
import 'package:artisanarc/features/shopping/presentation/shopping_list_overview_screen.dart'; // Added ShoppingListOverviewScreen
import 'package:artisanarc/features/shopping/presentation/shopping_list_detail_screen.dart'; // Added ShoppingListDetailScreen
import 'package:artisanarc/features/ai/presentation/craft_ai_widget.dart'; // Added CraftAIWidget

class AppRouter {
  // TODO: Implement logic to check onboarding completion status
  // For now, defaulting to '/home'. This should be '/onboarding' if not completed.
  static const String initialRoute = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        // TODO: Add sub-routes for home screen sections if necessary
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryScreen(),
        routes: [ // Adding sub-route for adding inventory item
          GoRoute(
            path: 'add', // Accessible via /inventory/add
            name: 'addInventoryItem',
            builder: (context, state) => const AddInventoryItemScreen(),
          ),
          // TODO: Add route for viewing/editing inventory item details
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
        routes: [ // Adding sub-routes for business features
          GoRoute(
            path: 'sales', //  Accessible via /business/sales
            name: 'dailySales',
            builder: (context, state) => const DailySalesScreen(),
          ),
          GoRoute(
            path: 'new-sale', // Accessible via /business/new-sale
            name: 'newSale',
            builder: (context, state) => const NewSaleEntryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/projects',
        name: 'projects',
        builder: (context, state) => const ProjectListScreen(), // Points to the list screen
        routes: [
          GoRoute(
            path: 'add', //  Accessible via /projects/add
            name: 'addProject',
            builder: (context, state) => const ProjectPlannerScreen(), // ProjectPlannerScreen handles adding
          ),
          GoRoute(
            path: 'edit/:id', // Accessible via /projects/edit/some-id
            name: 'editProject',
            builder: (context, state) {
              final projectId = state.pathParameters['id'];
              return ProjectPlannerScreen(projectId: projectId); // Pass projectId for editing
            },
          ),
          // TODO: Add route for project details view if different from edit view
        ],
      ),
      GoRoute(
        path: '/scan-qr', // Top-level route for QR scanner
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
            path: ':listId', // Accessible via /shopping-lists/some-id
            name: 'shoppingListDetail',
            builder: (context, state) {
              final listId = state.pathParameters['listId'];
              if (listId == null) {
                // Handle error or redirect, though go_router should prevent this if path is matched
                return const Scaffold(body: Center(child: Text('Error: List ID missing')));
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
          final craftType = state.pathParameters['craftType'] ?? 'Unknown Craft';
          // URL decoding is handled automatically by go_router for path parameters
          return CraftAIWidget(craft: craftType);
        },
      ),
    ],
  );
}