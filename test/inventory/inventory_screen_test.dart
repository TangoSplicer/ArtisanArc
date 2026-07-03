import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artisanarc/features/inventory/presentation/inventory_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';

class MockInventoryService extends Mock implements InventoryService {
  @override
  Future<List<dynamic>> fetchItems() async => [];
}

void main() {
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<InventoryService>()) {
      getIt.registerSingleton<InventoryService>(MockInventoryService());
    }
  });

  testWidgets('InventoryScreen renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: InventoryScreen(),
    ));

    expect(find.text('Inventory'), findsOneWidget);
  });
}
