import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';

class MockInventoryRepository extends Mock implements InventoryRepository {}

void main() {
  late InventoryService service;
  late MockInventoryRepository mockRepo;

  setUp(() {
    mockRepo = MockInventoryRepository();
    service = InventoryServiceImpl(mockRepo);
  });

  test('adds and fetches inventory item', () async {
    final testItem = InventoryItem(
      id: '1',
      name: 'Yarn Ball',
      category: 'Yarn',
      quantity: 3,
    );

    when(mockRepo.addItem(testItem)).thenAnswer((_) async => {});
    when(mockRepo.getAllItems()).thenAnswer((_) async => [testItem]);

    await service.createItem(testItem);
    final items = await service.fetchItems();

    expect(items.length, 1);
    expect(items.first.name, 'Yarn Ball');
  });
}