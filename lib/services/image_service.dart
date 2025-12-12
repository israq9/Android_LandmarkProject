import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery
  Future<File?> pickImage() async {
    try {
      // Check and request permission
      final status = await Permission.photos.status;
      if (status.isDenied) {
        await Permission.photos.request();
        if (await Permission.photos.isDenied) {
          return null;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Take a photo with camera
  Future<File?> takePhoto() async {
    try {
      // Check and request camera permission
      final status = await Permission.camera.status;
      if (status.isDenied) {
        await Permission.camera.request();
        if (await Permission.camera.isDenied) {
          return null;
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Compress image to target width (maintaining aspect ratio)
  // and reduce quality
  Future<File> compressImage(File file, {int targetWidth = 1200}) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${path.basename(file.path)}';
      
      // Get image info
      final image = await decodeImageFromList(file.readAsBytesSync());
      final int width = image.width;
      final int height = image.height;
      
      // Calculate new dimensions maintaining aspect ratio
      int newWidth = width > height ? targetWidth : (targetWidth * width / height).round();
      int newHeight = width > height ? (targetWidth * height / width).round() : targetWidth;
      
      // Compress image
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: newWidth,
        minHeight: newHeight,
        autoCorrectionAngle: true,
      );
      
      return File(result!.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // Return original file if compression fails
      return file;
    }
  }

  // Get a thumbnail of the image
  Future<File> getThumbnail(File file, {int width = 200, int quality = 50}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/thumbnail_${path.basename(file.path)}';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: width,
      );
      
      return File(result!.path);
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      return file;
    }
  }
  
  // Delete temporary files
  Future<void> cleanTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        tempDir.list().listen((file) async {
          if (file is File && file.path.contains('compressed_') || 
              file.path.contains('thumbnail_')) {
            await file.delete();
          }
        });
      }
    } catch (e) {
      debugPrint('Error cleaning temp files: $e');
    }
  }
}
