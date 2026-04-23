import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  AppPermissionHandler._();

  static Future<bool> ensureLocation() async {
    final s = await Permission.location.request();
    return s.isGranted;
  }

  static Future<bool> ensureCamera() async {
    final s = await Permission.camera.request();
    return s.isGranted;
  }

  static Future<bool> ensurePhotos() async {
    final s = await Permission.photos.request();
    if (s.isGranted) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  static Future<bool> ensureNotifications() async {
    final s = await Permission.notification.request();
    return s.isGranted;
  }
}
