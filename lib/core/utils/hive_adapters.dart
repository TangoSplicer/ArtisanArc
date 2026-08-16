import 'package:hive/hive.dart';
import '../../features/inventory/data/inventory_model.dart';
import '../../features/inventory/data/stock_adjustment_model.dart';
import '../../features/inventory/data/supplier_model.dart';
import '../../features/inventory/data/material_purchase_model.dart';
import '../../features/business/data/sale_model.dart';
import '../../features/business/data/stall_session_model.dart';
import '../../features/compliance/data/compliance_model.dart';
import '../../features/project/data/project_model.dart';
import '../../features/project/data/production_run_model.dart';
import '../../features/project/domain/entities/supply_need.dart';
import '../../features/shopping/data/shopping_list_model.dart';
import '../../features/commissions/data/commission_model.dart';
import '../../features/recipes/data/make_recipe_model.dart';
import '../../features/collections/data/maker_collection_model.dart';
import '../../features/wholesale/data/wholesale_model.dart';
import '../../features/patterns/data/pattern_model.dart';
import '../../features/stitches/data/stitch_model.dart';
import '../../features/equipment/data/equipment_model.dart';

void registerHiveAdapters() {
  _registerAdapterIfNotRegistered(InventoryItemAdapter());
  _registerAdapterIfNotRegistered(StockAdjustmentAdapter());
  _registerAdapterIfNotRegistered(SupplierAdapter());
  _registerAdapterIfNotRegistered(MaterialPurchaseAdapter());
  _registerAdapterIfNotRegistered(SaleRecordAdapter());
  _registerAdapterIfNotRegistered(StallSessionAdapter());
  _registerAdapterIfNotRegistered(ComplianceEntryAdapter());
  _registerAdapterIfNotRegistered(ProjectAdapter());
  _registerAdapterIfNotRegistered(ProductionRunAdapter());
  _registerAdapterIfNotRegistered(MilestoneAdapter());
  _registerAdapterIfNotRegistered(SupplyNeedAdapter());
  _registerAdapterIfNotRegistered(ShoppingListAdapter());
  _registerAdapterIfNotRegistered(ShoppingListItemAdapter());
  _registerAdapterIfNotRegistered(CommissionAdapter());
  _registerAdapterIfNotRegistered(CommissionStatusAdapter());
  _registerAdapterIfNotRegistered(MakeRecipeAdapter());
  _registerAdapterIfNotRegistered(RecipeVariantAdapter());
  _registerAdapterIfNotRegistered(MakerCollectionAdapter());
  _registerAdapterIfNotRegistered(CollectionRecipeTargetAdapter());
  _registerAdapterIfNotRegistered(WholesalePartnerAdapter());
  _registerAdapterIfNotRegistered(WholesaleBatchAdapter());
  _registerAdapterIfNotRegistered(WholesaleBatchItemAdapter());
  _registerAdapterIfNotRegistered(StoredPatternAdapter());
  _registerAdapterIfNotRegistered(RowCounterAdapter());
  _registerAdapterIfNotRegistered(StitchReferenceAdapter());
  _registerAdapterIfNotRegistered(EquipmentItemAdapter());
}

void _registerAdapterIfNotRegistered<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}
