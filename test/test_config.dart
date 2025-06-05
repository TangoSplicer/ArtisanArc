import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_platform_interface/method_channel_path_provider.dart';

void setupTestHive() {
  PathProviderPlatform.instance = MethodChannelPathProvider();
  Hive.init('./test_hive');
}