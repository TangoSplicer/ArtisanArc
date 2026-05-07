import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

// Mock class for PathProviderPlatform to avoid internal import issues
class MockPathProviderPlatform extends PathProviderPlatform {}

Future<void> setupTestHive() async {
  // Use a placeholder or mock for testing environments where platform channels are missing
  try {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  } catch (e) {
    // Ignore if already set or not applicable
  }
  Hive.init('./test_hive');
}
