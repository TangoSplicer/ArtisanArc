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
    final getIt = GetIt.instance;
    
    // Clear GetIt for a clean state
    getIt.reset();
    
    // Register the mock service
    getIt.registerSingleton<InventoryService>(mockService);

    // Default mock behavior
    when(mockService.fetchItems()).thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('InventoryScreen shows empty message and FAB', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: InventoryScreen(),
    ));

    // Wait for the async _loadItems() in initState to complete
    await tester.pump(); // Initial build
    await tester.pumpAndSettle(); // Wait for Future and animations

    // Verify that the empty state is shown.
    expect(find.text('No Items Yet'), findsOneWidget);
    expect(find.textContaining('Start building your craft inventory'), findsOneWidget);
    
    // Verify that the FAB is present.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
  });
}
