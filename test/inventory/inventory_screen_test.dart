import 'package:artisanarc/core/widgets/empty_state_widget.dart';
import 'package:artisanarc/features/inventory/presentation/inventory_screen.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([InventoryService])
import 'inventory_screen_test.mocks.dart';

void main() {
  final sl = GetIt.instance;

  setUp(() {
    final mockService = MockInventoryService();
    // Return empty list by default
    when(mockService.fetchItems()).thenAnswer((_) async => []);
    sl.registerSingleton<InventoryService>(mockService);
  });

  tearDown(() async {
    await sl.reset();
  });

  group('InventoryScreen', () {
    testWidgets('renders EmptyStateWidget when inventory is empty',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));
      await tester.pump(); // Allow state to update after fetchItems

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No Created Items Yet'), findsOneWidget);
      expect(
          find.text(
              'Add the pieces you have made to keep a clear tally of what is ready.'),
          findsOneWidget);
    });

    testWidgets('renders a dedicated materials-stock empty state',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: InventoryScreen(viewMode: InventoryViewMode.materialsStock)));
      await tester.pump();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No Materials Stock Yet'), findsOneWidget);
      expect(
          find.text(
              'Add yarn, hooks, notions, and supplies so you can see what is available to work with.'),
          findsOneWidget);
    });
  });
}
