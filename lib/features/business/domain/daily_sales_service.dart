import 'package.intl/intl.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../inventory/data/inventory_model.dart';
import '../../business/data/sale_model.dart';
import '../../business/data/business_repository.dart';
import 'linked_sale_model.dart';

class DailySalesService {
  final BusinessRepository salesRepo;
  final InventoryRepository inventoryRepo;

  DailySalesService(this.salesRepo, this.inventoryRepo);

  Future<Map<String, List<LinkedSaleModel>>> getGroupedSales() async {
    final sales = await salesRepo.getSales();
    final inventory = await inventoryRepo.getAllItems();

    final inventoryMap = {
      for (var item in inventory) item.id: item.name,
    };

    final Map<String, List<LinkedSaleModel>> grouped = {};

    for (final sale in sales) {
      final dateKey = DateFormat('yyyy-MM-dd').format(sale.date);
      final itemName = inventoryMap[sale.itemId] ?? '[Unlinked Item]';

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(
        LinkedSaleModel(sale: sale, itemName: itemName),
      );
    }

    return grouped;
  }
}