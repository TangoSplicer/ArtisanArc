import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions() async {
    return await [
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ].request();
  }

  static Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  static Future<bool> checkNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}