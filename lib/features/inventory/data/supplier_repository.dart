import 'package:hive/hive.dart';

import 'supplier_model.dart';

abstract class SupplierRepository {
  Future<void> saveSupplier(Supplier supplier);
  Future<List<Supplier>> getSuppliers();
  Future<void> deleteSupplier(String id);
}

class SupplierRepositoryImpl implements SupplierRepository {
  static const _boxName = 'suppliersBox';

  Future<Box<Supplier>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Supplier>(_boxName);
    }
    return Hive.box<Supplier>(_boxName);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    final box = await _getBox();
    final suppliers = box.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return suppliers;
  }

  @override
  Future<void> saveSupplier(Supplier supplier) async {
    final box = await _getBox();
    await box.put(supplier.id, supplier);
  }
}
