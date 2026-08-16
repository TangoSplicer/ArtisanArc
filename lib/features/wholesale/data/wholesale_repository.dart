import 'package:hive_flutter/hive_flutter.dart';
import 'wholesale_model.dart';

class WholesaleRepository {
  static const _partnersBox = 'wholesalePartnersBox';
  static const _batchesBox = 'wholesaleBatchesBox';

  Future<Box<WholesalePartner>> _getPartnersBox() async {
    if (!Hive.isBoxOpen(_partnersBox)) {
      await Hive.openBox<WholesalePartner>(_partnersBox);
    }
    return Hive.box<WholesalePartner>(_partnersBox);
  }

  Future<Box<WholesaleBatch>> _getBatchesBox() async {
    if (!Hive.isBoxOpen(_batchesBox)) {
      await Hive.openBox<WholesaleBatch>(_batchesBox);
    }
    return Hive.box<WholesaleBatch>(_batchesBox);
  }

  Future<List<WholesalePartner>> getPartners() async {
    final box = await _getPartnersBox();
    return box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<WholesalePartner?> getPartnerById(String id) async {
    final box = await _getPartnersBox();
    return box.get(id);
  }

  Future<void> savePartner(WholesalePartner partner) async {
    final box = await _getPartnersBox();
    await box.put(partner.id, partner);
  }

  Future<void> deletePartner(String id) async {
    final box = await _getPartnersBox();
    await box.delete(id);
  }

  Future<List<WholesaleBatch>> getBatches() async {
    final box = await _getBatchesBox();
    return box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<WholesaleBatch?> getBatchById(String id) async {
    final box = await _getBatchesBox();
    return box.get(id);
  }

  Future<void> saveBatch(WholesaleBatch batch) async {
    final box = await _getBatchesBox();
    await box.put(batch.id, batch);
  }

  Future<void> deleteBatch(String id) async {
    final box = await _getBatchesBox();
    await box.delete(id);
  }
}
