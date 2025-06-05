// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as get_it;
import 'package:injectable/injectable.dart' as injectable;

import '../../features/inventory/data/inventory_repository.dart';
import '../../features/inventory/domain/inventory_service.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/settings/domain/settings_service.dart';

final get_it.GetIt getIt = get_it.GetIt.instance;

@injectable.InjectableInit()
void init() {
  getIt
    ..registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl())
    ..registerLazySingleton<InventoryService>(() => InventoryServiceImpl(getIt()))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl())
    ..registerLazySingleton<SettingsService>(() => SettingsServiceImpl(getIt()));
}