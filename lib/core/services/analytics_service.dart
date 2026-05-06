import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AnalyticsService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _usageKey = 'app_usage_analytics';

  static Future<void> trackFeatureUsage(String feature) async {
    final currentData = await _getUsageData();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    currentData[feature] ??= {};
    currentData[feature][today] = (currentData[feature][today] ?? 0) + 1;
    
    await _storage.write(key: _usageKey, value: jsonEncode(currentData));
  }

  static Future<Map<String, dynamic>> getUsageAnalytics() async {
    return await _getUsageData();
  }

  static Future<Map<String, dynamic>> _getUsageData() async {
    final data = await _storage.read(key: _usageKey);
    if (data == null) return {};
    
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  static Future<void> clearAnalytics() async {
    await _storage.delete(key: _usageKey);
  }
}