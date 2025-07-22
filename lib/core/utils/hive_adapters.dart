import 'package:hive/hive.dart';

import 'package:hive/hive.dart';

import '../../features/inventory/data/inventory_model.dart';
import '../../features/business/data/sale_model.dart';
import '../../features/compliance/data/compliance_model.dart';
import '../../features/project/data/project_model.dart';
import '../../features/project/domain/entities/supply_need.dart'; // Added import for SupplyNeed
import '../../features/shopping/data/shopping_list_model.dart'; // Added import for ShoppingList models

void registerHiveAdapters() {
  // Ensure typeIds are unique and match class annotations
  // InventoryItemAdapter is typeId 0 (implicit from previous tasks)
  // SaleRecordAdapter is typeId 1 (assumed from business feature, needs verification)
  // ComplianceEntryAdapter is typeId ? (needs verification from its model file)
  // ProjectAdapter() is for typeId 3
  // MilestoneAdapter() is for typeId 5
  // SupplyNeedAdapter() is for typeId 4
  // ShoppingListAdapter() is for typeId 6
  // ShoppingListItemAdapter() is for typeId 7

  // Check if adapters are already registered to prevent errors during hot reload/restart
  _registerAdapterIfNotRegistered(ProjectAdapter());
  _registerAdapterIfNotRegistered(MilestoneAdapter());
  _registerAdapterIfNotRegistered(SupplyNeedAdapter());
  _registerAdapterIfNotRegistered(ShoppingListAdapter());
  _registerAdapterIfNotRegistered(ShoppingListItemAdapter());

  // Pre-existing adapters (ensure their typeIds are known and don't clash)
  _registerAdapterIfNotRegistered(InventoryItemAdapter());
  // _registerAdapterIfNotRegistered(SaleRecordAdapter()); // Uncomment if SaleRecordAdapter exists and needs registration
  // _registerAdapterIfNotRegistered(ComplianceEntryAdapter()); // Uncomment if ComplianceEntryAdapter exists
}

// Helper function to avoid re-registering adapters
void _registerAdapterIfNotRegistered<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}