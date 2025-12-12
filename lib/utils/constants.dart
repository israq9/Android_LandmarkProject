class AppConstants {
  // API endpoints
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  // Default values
  static const double defaultLatitude = 23.6850; // Center of Bangladesh
  static const double defaultLongitude = 90.3563;
  static const double defaultZoom = 12.0;
  
  // Map settings
  static const double mapZoom = 15.0;
  static const double mapMinZoom = 5.0;
  static const double mapMaxZoom = 20.0;
  
  // Image settings
  static const int maxImageSize = 800; // pixels
  static const int imageQuality = 85; // percentage
  
  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  // Form validation messages
  static const String requiredField = 'This field is required';
  static const String invalidCoordinates = 'Invalid coordinates';
  static const String invalidImage = 'Please select an image';
  
  // Placeholder image URL
  static const String placeholderImage = 'assets/images/placeholder.png';
  
  // Local storage keys
  static const String themeModeKey = 'theme_mode';
  static const String firstLaunchKey = 'first_launch';
  
  // Error messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  
  // Success messages
  static const String landmarkAdded = 'Landmark added successfully';
  static const String landmarkUpdated = 'Landmark updated successfully';
  static const String landmarkDeleted = 'Landmark deleted successfully';
}
