import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'di.config.dart';

// Inventory
import '../../features/inventory/data/inventory_repository.dart';
import '../../features/inventory/domain/inventory_service.dart';

// Business
import '../../features/business/data/business_repository.dart';
import '../../features/business/domain/business_service.dart';
import '../../features/business/domain/daily_sales_service.dart';

// Compliance
import '../../features/compliance/data/compliance_repository.dart';
import '../../features/compliance/domain/compliance_service.dart';

// Settings
import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/domain/settings_service.dart';

// Project
import '../../features/project/data/project_repository.dart';
import '../../features/project/domain/project_service.dart';

// AI
import '../../features/ai/domain/craft_hint_service.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async {
  await $initGetIt(getIt);

  // Custom service bindings (non-generated)

  // Daily Sales Service: links Business & Inventory
  getIt.registerLazySingleton<DailySalesService>(() => DailySalesService(
        getIt<BusinessRepository>(),
        getIt<InventoryRepository>(),
      ));

  // AI service: direct manual registration (if needed later)
  getIt.registerLazySingleton<CraftHintService>(() => CraftHintService());
}