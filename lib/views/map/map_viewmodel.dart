import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:landmark_manager/models/landmark.dart';
import 'package:landmark_manager/providers/landmark_provider.dart';
import 'package:landmark_manager/utils/constants.dart';

class MapViewModel with ChangeNotifier {
  final LandmarkProvider _landmarkProvider;
  
  // Map controller
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;
  
  // Map state
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  // Current position
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;
  
  // Markers
  final Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;
  
  // Selected landmark
  Landmark? _selectedLandmark;
  Landmark? get selectedLandmark => _selectedLandmark;
  
  // Camera position
  CameraPosition get initialCameraPosition => CameraPosition(
    target: LatLng(
      _currentPosition?.latitude ?? AppConstants.defaultLatitude,
      _currentPosition?.longitude ?? AppConstants.defaultLongitude,
    ),
    zoom: AppConstants.defaultZoom,
  );

  MapViewModel(this._landmarkProvider) {
    _init();
  }

  Future<void> _init() async {
    await _getCurrentLocation();
    await _loadLandmarks();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _landmarkProvider.getCurrentLocation();
      if (location.lat != null && location.lon != null) {
        _currentPosition = LatLng(location.lat!, location.lon!);
        moveToCurrentLocation();
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  Future<void> _loadLandmarks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _landmarkProvider.loadLandmarks();
      _updateMarkers();
    } catch (e) {
      debugPrint('Error loading landmarks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateMarkers() {
    _markers.clear();
    
    for (final landmark in _landmarkProvider.landmarks) {
      final marker = Marker(
        markerId: MarkerId('marker_${landmark.id}'),
        position: LatLng(landmark.lat, landmark.lon),
        infoWindow: InfoWindow(
          title: landmark.title,
          onTap: () => _onMarkerTapped(landmark),
        ),
        onTap: () => _onMarkerTapped(landmark),
      );
      
      _markers.add(marker);
    }
    
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    moveToCurrentLocation();
  }

  // Changed to public (removed underscore) so it can be called from UI
  void moveToCurrentLocation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          _currentPosition!,
          AppConstants.mapZoom,
        ),
      );
    }
  }

  void _onMarkerTapped(Landmark landmark) {
    _selectedLandmark = landmark;
    notifyListeners();
    
    // Move camera to selected marker
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(landmark.lat, landmark.lon),
      ),
    );
  }

  void clearSelectedLandmark() {
    _selectedLandmark = null;
    notifyListeners();
  }

  Future<bool> deleteLandmark(Landmark landmark) async {
    if (landmark.id == null) return false;
    
    final success = await _landmarkProvider.deleteLandmark(landmark.id!);
    if (success) {
      _selectedLandmark = null;
      _updateMarkers();
    }
    return success;
  }

  void refresh() {
    _loadLandmarks();
  }
}
