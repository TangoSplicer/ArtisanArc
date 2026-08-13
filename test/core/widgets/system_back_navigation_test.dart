import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('system back returns to Home after a feature route is pushed', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => context.push('/inventory'),
                child: const Text('Open Inventory'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Inventory screen'))),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open Inventory'));
    await tester.pumpAndSettle();
    expect(find.text('Inventory screen'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Open Inventory'), findsOneWidget);
  });
}
