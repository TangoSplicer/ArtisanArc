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

// Project Use Cases
import '../../features/project/domain/usecases/create_project.dart';
import '../../features/project/domain/usecases/get_project_by_id.dart';
import '../../features/project/domain/usecases/get_projects.dart';
import '../../features/project/domain/usecases/update_project.dart';
import '../../features/project/domain/usecases/delete_project.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async {
  await $initGetIt(getIt); // Generated registrations

  // Custom service bindings (non-generated)

  // Assuming ProjectRepositoryImpl and ProjectServiceImpl might not be annotated
  // for injectable, or to ensure they are registered as specified.
  // If they ARE annotated, these manual ones might conflict or be redundant if build_runner runs.

  // Project Feature
  if (!getIt.isRegistered<ProjectRepository>()) {
    getIt.registerLazySingleton<ProjectRepository>(() => ProjectRepositoryImpl());
  }

  if (!getIt.isRegistered<ProjectService>()) {
    getIt.registerLazySingleton<ProjectService>(() => ProjectServiceImpl(getIt<ProjectRepository>()));
  }

  // Register Project Use Cases
  if (!getIt.isRegistered<CreateProject>()) {
    getIt.registerLazySingleton<CreateProject>(() => CreateProject(getIt<ProjectService>()));
  }
  if (!getIt.isRegistered<GetProjectById>()) {
    getIt.registerLazySingleton<GetProjectById>(() => GetProjectById(getIt<ProjectService>()));
  }
  if (!getIt.isRegistered<GetProjects>()) {
    getIt.registerLazySingleton<GetProjects>(() => GetProjects(getIt<ProjectService>()));
  }
  if (!getIt.isRegistered<UpdateProject>()) {
    getIt.registerLazySingleton<UpdateProject>(() => UpdateProject(getIt<ProjectService>()));
  }
  if (!getIt.isRegistered<DeleteProject>()) {
    getIt.registerLazySingleton<DeleteProject>(() => DeleteProject(getIt<ProjectService>()));
  }

  // Daily Sales Service: links Business & Inventory
  getIt.registerLazySingleton<DailySalesService>(() => DailySalesService(
        getIt<BusinessRepository>(),
        getIt<InventoryRepository>(),
      ));

  // AI service: direct manual registration (if needed later)
  getIt.registerLazySingleton<CraftHintService>(() => CraftHintService());
}