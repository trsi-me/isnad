import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static Future<bool> requestPermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  static Future<Position?> getCurrentLocation() async {
    final ok = await requestPermission();
    if (!ok) return null;
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
