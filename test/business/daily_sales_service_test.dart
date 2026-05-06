import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:artisanarc/features/business/domain/daily_sales_service.dart';
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/business/data/business_repository.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';

@GenerateMocks([BusinessRepository, InventoryRepository])
import 'daily_sales_service_test.mocks.dart';

void main() {
  late MockBusinessRepository salesRepo;
  late MockInventoryRepository inventoryRepo;
  late DailySalesService service;

  setUp(() {
    salesRepo = MockBusinessRepository();
    inventoryRepo = MockInventoryRepository();
    service = DailySalesService(salesRepo, inventoryRepo);
  });

  test('groups sales by date and links inventory item names', () async {
    final today = DateTime.now();
    final sale = SaleRecord(
      id: '1',
      itemId: 'abc123',
      quantity: 2,
      pricePerUnit: 5.0,
      date: today,
    );

    when(salesRepo.getSales()).thenAnswer((_) async => [sale]);
    when(inventoryRepo.getAllItems()).thenAnswer((_) async => [
          InventoryItem(
            id: 'abc123',
            name: 'Test Yarn',
            category: 'Yarn',
            quantity: 10,
            lastUpdated: DateTime.now(),
          ),
        ]);

    final result = await service.getGroupedSales();
    final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    expect(result.containsKey(key), true);
    expect(result[key]!.first.itemName, 'Test Yarn');
  });
}
