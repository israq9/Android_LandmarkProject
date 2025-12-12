import 'dart:io';
import 'package:dio/dio.dart';
import 'package:landmark_manager/models/landmark.dart';

class ApiService {
  static const String _baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Get all landmarks
  Future<List<Landmark>> getLandmarks() async {
    try {
      final response = await _dio.get('');
      
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        if (responseData is List) {
          return responseData.map((json) => Landmark.fromJson(json)).toList();
        } 
        return [];
      } else {
        throw Exception('Failed to load landmarks');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create a new landmark
  Future<Landmark> createLandmark({
    required String title,
    required double lat,
    required double lon,
    required File image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'image': await MultipartFile.fromFile(image.path, filename: 'landmark_${DateTime.now().millisecondsSinceEpoch}.jpg'),
      });

      final response = await _dio.post(
        '',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Landmark.fromJson(response.data);
      } else {
        throw Exception('Failed to create landmark');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update an existing landmark
  Future<Landmark> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'id': id,
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: 'landmark_${id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      });

      final response = await _dio.put(
        '',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Landmark.fromJson(response.data);
      } else {
        throw Exception('Failed to update landmark');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete a landmark
  Future<bool> deleteLandmark(int id) async {
    try {
      // IMPORTANT: The backend API likely expects the 'id' as a query parameter or
      // form data, but sometimes DELETE requests with bodies are tricky.
      // Many PHP APIs expect DELETE parameters in the URL query string.
      // Let's try sending it as a query parameter instead of body data, which is safer.
      
      final response = await _dio.delete(
        '',
        queryParameters: {'id': id}, // Changed from data to queryParameters
      );

      return response.statusCode == 200;
    } catch (e) {
      // If query param fails, try the original way as fallback or debug further
      // But for simple PHP APIs, query param is usually the standard for DELETE.
      throw _handleError(e);
    }
  }

  // Handle errors
  dynamic _handleError(dynamic error) {
    if (error is DioException) { 
      if (error.response != null) {
        return 'Server error: ${error.response?.statusCode} - ${error.response?.statusMessage}';
      } else {
        return 'Network error: ${error.message}';
      }
    }
    return error.toString();
  }
}
