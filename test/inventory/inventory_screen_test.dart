import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:craft_supply_organiser/features/inventory/presentation/inventory_screen.dart';

void main() {
  testWidgets('InventoryScreen shows empty message and FAB', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));

    expect(find.text('No items found. Tap + to add.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}