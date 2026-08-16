import 'package:get_it/get_it.dart';
import '../../inventory/domain/inventory_service.dart';
import '../data/wholesale_model.dart';
import '../data/wholesale_repository.dart';

class WholesaleService {
  final WholesaleRepository _repository = GetIt.I<WholesaleRepository>();
  final InventoryService _inventoryService = GetIt.I<InventoryService>();

  Future<List<WholesalePartner>> getPartners() => _repository.getPartners();
  Future<WholesalePartner?> getPartnerById(String id) =>
      _repository.getPartnerById(id);

  Future<void> savePartner({
    String? id,
    required String name,
    required String contactName,
    required String email,
    required String phone,
    required String address,
    required String partnerType,
    required double commissionRatePercent,
    WholesalePartner? existing,
  }) async {
    final now = DateTime.now();
    final partner = WholesalePartner(
      id: id ??
          existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      contactName: contactName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      address: address.trim(),
      partnerType: partnerType,
      commissionRatePercent: commissionRatePercent,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _repository.savePartner(partner);
  }

  Future<void> deletePartner(String id) => _repository.deletePartner(id);

  Future<List<WholesaleBatch>> getBatches() => _repository.getBatches();
  Future<WholesaleBatch?> getBatchById(String id) =>
      _repository.getBatchById(id);

  Future<void> createBatch({
    required WholesalePartner partner,
    required String referenceNumber,
    required List<WholesaleBatchItem> items,
    required DateTime sentDate,
    required DateTime dueDate,
    required String notes,
  }) async {
    // Validate inventory and deduct sent quantities
    for (final item in items) {
      final invItem = await _inventoryService.getItemById(item.inventoryItemId);
      if (invItem == null) {
        throw StateError('Inventory item "${item.itemName}" no longer exists.');
      }
      if (invItem.quantity < item.quantitySent) {
        throw StateError(
            'Insufficient stock for "${invItem.name}". Available: ${invItem.quantity}, requested: ${item.quantitySent}');
      }
    }

    // Deduct stock
    for (final item in items) {
      final invItem = await _inventoryService.getItemById(item.inventoryItemId);
      if (invItem != null) {
        final updated = invItem.copyWith(
          quantity: invItem.quantity - item.quantitySent,
          lastUpdated: DateTime.now(),
        );
        await _inventoryService.updateItem(updated);
      }
    }

    final now = DateTime.now();
    final batch = WholesaleBatch(
      id: now.millisecondsSinceEpoch.toString(),
      partnerId: partner.id,
      partnerName: partner.name,
      referenceNumber: referenceNumber.trim().isEmpty
          ? 'BATCH-${now.millisecondsSinceEpoch.toString().substring(8)}'
          : referenceNumber.trim(),
      status: 'sent',
      items: items,
      sentDate: sentDate,
      dueDate: dueDate,
      notes: notes.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _repository.saveBatch(batch);
  }

  Future<void> settleBatch({
    required WholesaleBatch batch,
    required List<WholesaleBatchItem> settledItems,
    required String notes,
  }) async {
    // Reconcile items: any returned items go back to inventory stock.
    // Sold items remain deducted (as they were sold through the partner).
    for (final updatedItem in settledItems) {
      final originalItem = batch.items.firstWhere(
        (i) => i.id == updatedItem.id,
        orElse: () => updatedItem,
      );

      final returnedDifference =
          updatedItem.quantityReturned - originalItem.quantityReturned;
      if (returnedDifference > 0) {
        final invItem =
            await _inventoryService.getItemById(updatedItem.inventoryItemId);
        if (invItem != null) {
          final updatedInv = invItem.copyWith(
            quantity: invItem.quantity + returnedDifference,
            lastUpdated: DateTime.now(),
          );
          await _inventoryService.updateItem(updatedInv);
        }
      }
    }

    final now = DateTime.now();
    final updatedBatch = WholesaleBatch(
      id: batch.id,
      partnerId: batch.partnerId,
      partnerName: batch.partnerName,
      referenceNumber: batch.referenceNumber,
      status: 'settled',
      items: settledItems,
      sentDate: batch.sentDate,
      dueDate: batch.dueDate,
      settledDate: now,
      notes: notes.trim().isEmpty
          ? batch.notes
          : '${batch.notes}\nSettled: $notes',
      createdAt: batch.createdAt,
      updatedAt: now,
    );

    await _repository.saveBatch(updatedBatch);
  }

  Future<void> deleteBatch(String id) async {
    final batch = await getBatchById(id);
    if (batch != null && batch.status == 'sent') {
      // Return un-settled stock back to inventory
      for (final item in batch.items) {
        final remainingInStock = item.quantitySent - item.quantitySold;
        if (remainingInStock > 0) {
          final invItem =
              await _inventoryService.getItemById(item.inventoryItemId);
          if (invItem != null) {
            await _inventoryService.updateItem(invItem.copyWith(
              quantity: invItem.quantity + remainingInStock,
              lastUpdated: DateTime.now(),
            ));
          }
        }
      }
    }
    await _repository.deleteBatch(id);
  }
}
