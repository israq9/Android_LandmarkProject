import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:landmark_manager/models/landmark.dart';
import 'package:landmark_manager/services/api_service.dart';
import 'package:landmark_manager/services/location_service.dart';
import 'package:landmark_manager/services/image_service.dart';

class LandmarkProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();

  List<Landmark> _landmarks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Landmark> get landmarks => List.unmodifiable(_landmarks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the provider
  Future<void> initialize() async {
    await loadLandmarks();
  }

  // Load all landmarks
  Future<void> loadLandmarks() async {
    _setLoading(true);
    try {
      _landmarks = await _apiService.getLandmarks();
      _setError(null);
    } catch (e) {
      _setError('Failed to load landmarks: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new landmark
  Future<bool> createLandmark({
    required String title,
    required double lat,
    required double lon,
    required File image,
  }) async {
    _setLoading(true);
    try {
      // Compress image before upload
      final compressedImage = await _imageService.compressImage(image);
      
      final newLandmark = await _apiService.createLandmark(
        title: title,
        lat: lat,
        lon: lon,
        image: compressedImage,
      );
      
      _landmarks.add(newLandmark);
      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create landmark: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing landmark
  Future<bool> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? image,
  }) async {
    _setLoading(true);
    try {
      File? compressedImage;
      if (image != null) {
        compressedImage = await _imageService.compressImage(image);
      }

      final updatedLandmark = await _apiService.updateLandmark(
        id: id,
        title: title,
        lat: lat,
        lon: lon,
        image: compressedImage,
      );

      final index = _landmarks.indexWhere((l) => l.id == id);
      if (index != -1) {
        _landmarks[index] = updatedLandmark;
        notifyListeners();
      }
      
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to update landmark: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete all landmarks
  Future<void> deleteAllLandmarks() async {
    // 1. Create a copy of the list to iterate over safely
    final List<Landmark> landmarksToDelete = List.from(_landmarks);
    
    // 2. Clear UI immediately
    _landmarks.clear();
    notifyListeners();
    
    // 3. Delete from server one by one in background
    for (final landmark in landmarksToDelete) {
      if (landmark.id != null) {
        try {
          await _apiService.deleteLandmark(landmark.id!);
        } catch (e) {
          debugPrint('Error deleting landmark ${landmark.id}: $e');
        }
      }
    }
  }

  // Delete a landmark with "Force Delete" behavior (ignoring server errors)
  Future<bool> deleteLandmark(int id) async {
    // 1. Find the index and the item to be deleted
    final index = _landmarks.indexWhere((l) => l.id == id);
    if (index == -1) return false;
    
    // final landmarkToDelete = _landmarks[index];

    // 2. Optimistically remove from UI immediately
    _landmarks.removeAt(index);
    notifyListeners();
    
    // 3. Perform API call
    try {
      final success = await _apiService.deleteLandmark(id);
      
      if (!success) {
        // Force Delete: Don't rollback even if server fails
        debugPrint('Server failed to delete landmark, but removed locally.');
        
        // _landmarks.insert(index, landmarkToDelete);
        // _setError('Failed to delete landmark from server');
        // notifyListeners();
        // return false;
      }
      
      return true;
    } catch (e) {
      // Force Delete: Don't rollback on exception
      debugPrint('Error deleting landmark: $e. Removed locally.');
      
      // _landmarks.insert(index, landmarkToDelete);
      // _setError('Failed to delete landmark: $e');
      // notifyListeners();
      // return false;
      return true; // Return true so UI thinks it succeeded
    }
  }

  // Get current location
  Future<({double? lat, double? lon})> getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        return (lat: position.latitude, lon: position.longitude);
      }
      return (lat: null, lon: null);
    } catch (e) {
      _setError('Failed to get current location: $e');
      return (lat: null, lon: null);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      debugPrint('LandmarkProvider Error: $error');
    }
  }

  // Find a landmark by ID
  Landmark? getLandmarkById(int id) {
    try {
      return _landmarks.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
}
