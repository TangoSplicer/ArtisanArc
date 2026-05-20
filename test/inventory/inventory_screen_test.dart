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
    // Ensure GetIt is reset before each test
    GetIt.instance.reset();
    GetIt.instance.registerSingleton<InventoryService>(mockService);

    when(mockService.fetchItems()).thenAnswer((_) async => []);
  });

  tearDown(() {
    // Ensure GetIt is reset after each test
    GetIt.instance.reset();
  });

  testWidgets('InventoryScreen shows empty message and FAB', (tester) async {
    // Provide a simple Material app with a Scaffold for the test
    await tester.pumpWidget(const MaterialApp(
      home: InventoryScreen(),
    ));

    // Wait for the async loading of items in initState and subsequent UI rebuilds
    await tester.pumpAndSettle();

    // Verify empty state title
    expect(find.text('No Items Yet'), findsOneWidget);
    
    // Verify FAB or action button exists
    // EmptyStateWidget has an action button with Icons.add, and Scaffold has a FAB with Icons.add
    expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
  });
}
