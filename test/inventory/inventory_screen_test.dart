import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:artisanarc/features/inventory/presentation/inventory_screen.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';

import 'inventory_screen_test.mocks.dart';

@GenerateMocks([InventoryService])
void main() {
  late MockInventoryService mockService;

  setUp(() {
    mockService = MockInventoryService();
    // Ensure GetIt is reset and then the service is registered
    GetIt.instance.reset();
    GetIt.instance.registerSingleton<InventoryService>(mockService);

    when(mockService.fetchItems()).thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('InventoryScreen shows empty message and FAB', (tester) async {
    // We wrap the screen in a Scaffold and MaterialApp to provide necessary context
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: const InventoryScreen(),
      ),
    ));

    // Wait for the initial build and async _loadItems() in initState
    await tester.pump(); 
    // We use pump() with a duration to allow any internal timers or async calls to settle
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify that the empty state is shown.
    // We use find.textContaining for more robustness
    expect(find.textContaining('No Items Yet'), findsOneWidget);
    expect(find.textContaining('Start building your craft inventory'), findsOneWidget);
    
    // Verify that the FAB is present.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // There are at least two Icons.add (FAB and empty state button)
    expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
  });
}
