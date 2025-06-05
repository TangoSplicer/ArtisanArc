import 'package:hive/hive.dart';

import 'package:hive/hive.dart';

import '../../features/inventory/data/inventory_model.dart';
import '../../features/business/data/sale_model.dart';
import '../../features/compliance/data/compliance_model.dart';
import '../../features/project/data/project_model.dart';
import '../../features/project/domain/entities/supply_need.dart'; // Added import for SupplyNeed

void registerHiveAdapters() {
  // Ensure typeIds are unique and match class annotations
  // ProjectAdapter() is for typeId 3
  // MilestoneAdapter() is for typeId 5 // Updated comment
  // SupplyNeedAdapter() is for typeId 4 (as defined in supply_need.dart)

  // Check if adapters are already registered to prevent errors during hot reload/restart
  if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
    Hive.registerAdapter(ProjectAdapter());
  }
  if (!Hive.isAdapterRegistered(MilestoneAdapter().typeId)) {
    Hive.registerAdapter(MilestoneAdapter());
  }
  if (!Hive.isAdapterRegistered(SupplyNeedAdapter().typeId)) { // Assuming SupplyNeedAdapter name
    Hive.registerAdapter(SupplyNeedAdapter());
  }

  // These seem to be pre-existing, ensure their typeIds don't clash.
  // For example, if InventoryItem is typeId 0 and SaleRecord is typeId 1.
  // ComplianceEntry's typeId also needs to be unique.
  if (!Hive.isAdapterRegistered(InventoryItemAdapter().typeId)) {
     Hive.registerAdapter(InventoryItemAdapter());
  }
  if (!Hive.isAdapterRegistered(SaleRecordAdapter().typeId)) {
    Hive.registerAdapter(SaleRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(ComplianceEntryAdapter().typeId)) {
    Hive.registerAdapter(ComplianceEntryAdapter());
  }
}