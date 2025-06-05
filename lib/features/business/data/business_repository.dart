import 'package:hive/hive.dart';
import 'sale_model.dart';

abstract class BusinessRepository {
  Future<void> createSale(SaleRecord sale);
  Future<List<SaleRecord>> getSales();
  Future<void> deleteSale(String id);
}

class BusinessRepositoryImpl implements BusinessRepository {
  static const _boxName = 'salesBox';

  Future<Box<SaleRecord>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<SaleRecord>(_boxName);
    }
    return Hive.box<SaleRecord>(_boxName);
  }

  @override
  Future<void> createSale(SaleRecord sale) async {
    final box = await _getBox();
    await box.put(sale.id, sale);
  }

  @override
  Future<List<SaleRecord>> getSales() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<void> deleteSale(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}