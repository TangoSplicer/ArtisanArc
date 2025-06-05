import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SettingsRepository {
  Future<void> setLocale(String localeCode);
  Future<String?> getLocale();

  Future<void> setVATThreshold(double threshold);
  Future<double?> getVATThreshold();

  Future<void> setVATRegistered(bool isRegistered);
  Future<bool> getVATRegistered();
}

class SettingsRepositoryImpl implements SettingsRepository {
  final _storage = const FlutterSecureStorage();

  static const _localeKey = 'locale_code';
  static const _vatThresholdKey = 'vat_threshold';
  static const _vatRegisteredKey = 'vat_registered';

  @override
  Future<void> setLocale(String localeCode) async {
    await _storage.write(key: _localeKey, value: localeCode);
  }

  @override
  Future<String?> getLocale() => _storage.read(key: _localeKey);

  @override
  Future<void> setVATThreshold(double threshold) async {
    await _storage.write(key: _vatThresholdKey, value: threshold.toString());
  }

  @override
  Future<double?> getVATThreshold() async {
    final value = await _storage.read(key: _vatThresholdKey);
    return value != null ? double.tryParse(value) : null;
  }

  @override
  Future<void> setVATRegistered(bool isRegistered) async {
    await _storage.write(key: _vatRegisteredKey, value: isRegistered.toString());
  }

  @override
  Future<bool> getVATRegistered() async {
    final value = await _storage.read(key: _vatRegisteredKey);
    return value?.toLowerCase() == 'true';
  }
}