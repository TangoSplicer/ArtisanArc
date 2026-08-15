import 'package:uuid/uuid.dart';

import '../data/inventory_model.dart';
import '../data/inventory_repository.dart';
import '../data/material_purchase_model.dart';
import '../data/material_purchase_repository.dart';
import '../data/supplier_model.dart';
import '../data/supplier_repository.dart';

class ProcurementService {
  ProcurementService(
    this._inventoryRepository,
    this._supplierRepository,
    this._purchaseRepository,
  );

  final InventoryRepository _inventoryRepository;
  final SupplierRepository _supplierRepository;
  final MaterialPurchaseRepository _purchaseRepository;
  final Uuid _uuid = const Uuid();

  Future<List<Supplier>> getSuppliers() => _supplierRepository.getSuppliers();

  Future<Supplier> saveSupplier({
    String? id,
    required String name,
    String? website,
    String? contactNote,
    String? notes,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Supplier name is required.');
    }
    final supplier = Supplier(
      id: id ?? _uuid.v4(),
      name: cleanName,
      website: website?.trim().isEmpty ?? true ? null : website!.trim(),
      contactNote:
          contactNote?.trim().isEmpty ?? true ? null : contactNote!.trim(),
      notes: notes?.trim().isEmpty ?? true ? null : notes!.trim(),
    );
    await _supplierRepository.saveSupplier(supplier);
    return supplier;
  }

  Future<MaterialPurchase> recordPurchase({
    required InventoryItem material,
    Supplier? supplier,
    required double quantityPurchased,
    required String unit,
    required double totalPaid,
    DateTime? purchasedAt,
    String? note,
  }) async {
    if (!material.isMaterialStock) {
      throw StateError(
          'Only material-stock records can receive a material purchase.');
    }
    if (quantityPurchased <= 0 || totalPaid < 0) {
      throw ArgumentError(
          'Purchase quantity must be positive and paid amount cannot be negative.');
    }
    final cleanUnit = unit.trim();
    if (cleanUnit.isEmpty)
      throw ArgumentError.value(unit, 'unit', 'A unit is required.');
    if (material.measurementUnit != null &&
        !_sameUnit(material.measurementUnit!, cleanUnit)) {
      throw StateError(
          'This material already uses ${material.measurementUnit}. Record purchases in that same unit.');
    }

    final date = purchasedAt ?? DateTime.now();
    final purchase = MaterialPurchase(
      id: _uuid.v4(),
      inventoryItemId: material.id,
      materialName: material.name,
      supplierId: supplier?.id,
      supplierName: supplier?.name,
      purchasedAt: date,
      quantityPurchased: quantityPurchased,
      unit: cleanUnit,
      totalPaid: totalPaid,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
    );
    final currentMeasured = material.usesMeasuredQuantity
        ? material.measuredQuantity!
        : material.quantity.toDouble();
    final updated = material.copyWith(
      measuredQuantity: currentMeasured + quantityPurchased,
      measurementUnit: cleanUnit,
      price: purchase.unitCost,
      lastUpdated: date,
    );
    await _purchaseRepository.savePurchase(purchase);
    await _inventoryRepository.updateItem(updated);
    return purchase;
  }

  Future<List<MaterialPurchase>> getPurchaseHistory(
          [String? inventoryItemId]) =>
      _purchaseRepository.getPurchases(inventoryItemId: inventoryItemId);

  bool _sameUnit(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
