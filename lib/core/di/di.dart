import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

// Project Use Cases
import '../../features/project/domain/usecases/create_project.dart';
import '../../features/project/domain/usecases/get_project_by_id.dart';
import '../../features/project/domain/usecases/get_projects.dart';
import '../../features/project/domain/usecases/update_project.dart';
import '../../features/project/domain/usecases/delete_project.dart';

// Shopping Feature
import '../../features/shopping/data/shopping_repository.dart';
import '../../features/shopping/domain/shopping_service.dart';

// Theme Service
import '../../core/services/theme_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core Services
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());

  // Inventory Feature
  getIt.registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl());
  getIt.registerLazySingleton<InventoryService>(() => InventoryServiceImpl(getIt<InventoryRepository>()));

  // Business Feature
  getIt.registerLazySingleton<BusinessRepository>(() => BusinessRepositoryImpl());
  getIt.registerLazySingleton<BusinessService>(() => BusinessServiceImpl(getIt<BusinessRepository>()));

  // Compliance Feature
  getIt.registerLazySingleton<ComplianceRepository>(() => ComplianceRepositoryImpl());
  getIt.registerLazySingleton<ComplianceService>(() => ComplianceServiceImpl(getIt<ComplianceRepository>()));

  // Settings Feature
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());
  getIt.registerLazySingleton<SettingsService>(() => SettingsServiceImpl(getIt<SettingsRepository>()));

  // Project Feature
  getIt.registerLazySingleton<ProjectRepository>(() => ProjectRepositoryImpl());
  getIt.registerLazySingleton<ProjectService>(() => ProjectServiceImpl(getIt<ProjectRepository>()));

  // Register Project Use Cases
  getIt.registerLazySingleton<CreateProject>(() => CreateProject(getIt<ProjectService>()));
  getIt.registerLazySingleton<GetProjectById>(() => GetProjectById(getIt<ProjectService>()));
  getIt.registerLazySingleton<GetProjects>(() => GetProjects(getIt<ProjectService>()));
  getIt.registerLazySingleton<UpdateProject>(() => UpdateProject(getIt<ProjectService>()));
  getIt.registerLazySingleton<DeleteProject>(() => DeleteProject(getIt<ProjectService>()));

  // Daily Sales Service: links Business & Inventory
  getIt.registerLazySingleton<DailySalesService>(() => DailySalesService(
        getIt<BusinessRepository>(),
        getIt<InventoryRepository>(),
      ));

  // AI service: direct manual registration (if needed later)
  getIt.registerLazySingleton<CraftHintService>(() => CraftHintService());

  // Shopping Feature Dependencies
  getIt.registerLazySingleton<ShoppingRepository>(() => ShoppingRepositoryImpl());
  getIt.registerLazySingleton<ShoppingService>(() => ShoppingServiceImpl(getIt<ShoppingRepository>()));
}