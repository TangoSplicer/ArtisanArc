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
    GetIt.instance.reset();
    GetIt.instance.registerSingleton<InventoryService>(mockService);
    
    when(mockService.fetchItems()).thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('InventoryScreen renders and shows empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: InventoryScreen(),
    ));

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('No Items Yet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
