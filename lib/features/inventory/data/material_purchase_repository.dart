import 'package:hive/hive.dart';

import 'material_purchase_model.dart';

abstract class MaterialPurchaseRepository {
  Future<void> savePurchase(MaterialPurchase purchase);
  Future<List<MaterialPurchase>> getPurchases({String? inventoryItemId});
}

class MaterialPurchaseRepositoryImpl implements MaterialPurchaseRepository {
  static const _boxName = 'materialPurchasesBox';

  Future<Box<MaterialPurchase>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<MaterialPurchase>(_boxName);
    }
    return Hive.box<MaterialPurchase>(_boxName);
  }

  @override
  Future<List<MaterialPurchase>> getPurchases({String? inventoryItemId}) async {
    final box = await _getBox();
    final purchases = box.values
        .where((purchase) =>
            inventoryItemId == null ||
            purchase.inventoryItemId == inventoryItemId)
        .toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return purchases;
  }

  @override
  Future<void> savePurchase(MaterialPurchase purchase) async {
    final box = await _getBox();
    await box.put(purchase.id, purchase);
  }
}
