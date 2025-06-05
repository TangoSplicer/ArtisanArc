import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PremiumChecker {
  static const _key = 'premium_unlocked';
  static final _storage = const FlutterSecureStorage();

  static Future<void> unlockPremium() async {
    await _storage.write(key: _key, value: 'true');
  }

  static Future<bool> isPremiumUnlocked() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }
}