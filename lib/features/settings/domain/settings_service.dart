import '../data/settings_repository.dart';

abstract class SettingsService {
  Future<void> changeLocale(String localeCode);
  Future<String?> getCurrentLocale();

  Future<void> updateVATStatus(bool registered);
  Future<bool> isVATRegistered();

  Future<void> setThreshold(double threshold);
  Future<double?> getThreshold();
}

class SettingsServiceImpl implements SettingsService {
  final SettingsRepository _repo;

  SettingsServiceImpl(this._repo);

  @override
  Future<void> changeLocale(String localeCode) => _repo.setLocale(localeCode);

  @override
  Future<String?> getCurrentLocale() => _repo.getLocale();

  @override
  Future<void> updateVATStatus(bool registered) => _repo.setVATRegistered(registered);

  @override
  Future<bool> isVATRegistered() => _repo.getVATRegistered();

  @override
  Future<void> setThreshold(double threshold) => _repo.setVATThreshold(threshold);

  @override
  Future<double?> getThreshold() => _repo.getVATThreshold();
}