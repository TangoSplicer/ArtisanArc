import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'test_config.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setupTestHive();
  await testMain();
}
