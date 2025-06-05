import 'package:intl/intl.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../inventory/data/inventory_model.dart';
import '../../business/data/sale_model.dart';
import '../../business/data/business_repository.dart';

class DailySalesService {
  final BusinessRepository salesRepo;
  final InventoryRepository inventoryRepo;

  DailySalesService(this.salesRepo, this.inventoryRepo);

  Future<Map<String, List<_LinkedSale>>> getGroupedSales() async {
    final sales = await salesRepo.getSales();
    final inventory = await inventoryRepo.getAllItems();

    final inventoryMap = {
      for (var item in inventory) item.id: item.name,
    };

    final Map<String, List<_LinkedSale>> grouped = {};

    for (final sale in sales) {
      final dateKey = DateFormat('yyyy-MM-dd').format(sale.date);
      final itemName = inventoryMap[sale.itemId] ?? '[Unlinked Item]';

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(
        _LinkedSale(sale: sale, itemName: itemName),
      );
    }

    return grouped;
  }
}

class _LinkedSale {
  final SaleRecord sale;
  final String itemName;

  _LinkedSale({required this.sale, required this.itemName});
}