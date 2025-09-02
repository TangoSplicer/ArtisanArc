import 'package:hive/hive.dart';
import '../../features/inventory/data/inventory_model.dart';
import '../../features/business/data/sale_model.dart';
import '../../features/compliance/data/compliance_model.dart';
import '../../features/project/data/project_model.dart';
import '../../features/project/domain/entities/supply_need.dart';
import '../../features/shopping/data/shopping_list_model.dart';

void registerHiveAdapters() {
  _registerAdapterIfNotRegistered(InventoryItemAdapter());
  _registerAdapterIfNotRegistered(SaleRecordAdapter());
  _registerAdapterIfNotRegistered(ComplianceEntryAdapter());
  _registerAdapterIfNotRegistered(ProjectAdapter());
  _registerAdapterIfNotRegistered(MilestoneAdapter());
  _registerAdapterIfNotRegistered(SupplyNeedAdapter());
  _registerAdapterIfNotRegistered(ShoppingListAdapter());
  _registerAdapterIfNotRegistered(ShoppingListItemAdapter());
}

void _registerAdapterIfNotRegistered<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}