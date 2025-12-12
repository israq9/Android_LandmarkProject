import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission status
  Future<LocationPermission> checkPermission() async {
    final status = await Permission.locationWhenInUse.status;
    
    if (status.isDenied) {
      // Request permission if not granted
      final result = await Permission.locationWhenInUse.request();
      if (result.isDenied) {
        return LocationPermission.denied;
      }
    }
    
    if (status.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied
      await openAppSettings();
      return LocationPermission.deniedForever;
    }
    
    return await Geolocator.checkPermission();
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      
      if (hasPermission == LocationPermission.denied ||
          hasPermission == LocationPermission.deniedForever) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two coordinates in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
