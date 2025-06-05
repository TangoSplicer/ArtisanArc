import 'package:hive/hive.dart';

import '../../features/inventory/data/inventory_model.dart';
import '../../features/business/data/sale_model.dart';
import '../../features/compliance/data/compliance_model.dart';
import '../../features/project/data/project_model.dart';

void registerHiveAdapters() {
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(SaleRecordAdapter());
  Hive.registerAdapter(ComplianceEntryAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(MilestoneAdapter());
}