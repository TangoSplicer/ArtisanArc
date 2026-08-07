import 'package:artisanarc/core/widgets/empty_state_widget.dart';
import 'package:artisanarc/features/inventory/presentation/inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryScreen', () {
    testWidgets('renders EmptyStateWidget when inventory is empty', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('Your inventory is empty.'), findsOneWidget);
      expect(find.text('Add your first item to get started.'), findsOneWidget);
    });
  });
}
