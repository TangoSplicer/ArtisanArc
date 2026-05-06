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
    getIt.reset();
    getIt.registerSingleton<InventoryService>(mockService);

    when(mockService.fetchItems()).thenAnswer((_) async => []);
  });

  testWidgets('InventoryScreen shows empty message and FAB', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No Items Yet'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets); // FAB and Action button both have Icons.add
  });
}
