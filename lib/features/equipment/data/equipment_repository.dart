import 'package:hive/hive.dart';
import 'equipment_model.dart';

class EquipmentRepository {
  static const String _boxName = 'equipmentLedgerBox';

  Future<Box<EquipmentItem>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<EquipmentItem>(_boxName);
    }
    return Hive.box<EquipmentItem>(_boxName);
  }

  Future<List<EquipmentItem>> getEquipment() async {
    final box = await _openBox();
    return box.values.toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  }

  Future<void> saveEquipment(EquipmentItem item) async {
    final box = await _openBox();
    await box.put(item.id, item);
  }

  Future<void> deleteEquipment(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
