import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/core/widgets/searchable_selection_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('searchable selector filters options and returns the chosen value', (tester) async {
    String? selectedMaterial;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchableSelectionField<String>(
            options: const ['Fabric', 'Paper', 'Wool Yarn'],
            labelText: 'Material',
            hintText: 'Search material',
            itemLabel: (value) => value,
            onChanged: (value) => selectedMaterial = value,
          ),
        ),
      ),
    );

    expect(find.text('Search material'), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'yarn');
    await tester.pumpAndSettle();

    expect(find.text('Wool Yarn'), findsOneWidget);
    expect(find.text('Fabric'), findsNothing);

    await tester.tap(find.text('Wool Yarn'));
    await tester.pumpAndSettle();

    expect(selectedMaterial, 'Wool Yarn');
    expect(find.text('Wool Yarn'), findsOneWidget);
    expect(find.text('Search material'), findsNothing);
  });

  testWidgets('top-level feature screen exposes Home when no back stack exists', (tester) async {
    final router = GoRouter(
      initialLocation: '/inventory',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Home hub'))),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const Scaffold(
            appBar: PersonalAppBar(title: Text('Inventory')),
            body: Center(child: Text('Inventory content')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Home'), findsOneWidget);
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home hub'), findsOneWidget);
  });
}
