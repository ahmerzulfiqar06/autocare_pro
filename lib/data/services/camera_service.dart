import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _savePhotoToAppDirectory(photo);
      }
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
    return null;
  }

  Future<String?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _savePhotoToAppDirectory(photo);
      }
    } catch (e) {
      throw Exception('Failed to pick photo: $e');
    }
    return null;
  }

  Future<String?> showImageSourceDialog(context) async {
    // This method should be called from a widget with showDialog
    // For now, return null - will be implemented in the UI
    return null;
  }

  Future<String> _savePhotoToAppDirectory(XFile photo) async {
    try {
      if (kIsWeb) {
        // For web, return the original path since we can't save to local filesystem
        // The image will be stored in browser memory/cache
        return photo.path;
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photosDir = path.join(appDir.path, 'photos');

      // Create photos directory if it doesn't exist
      final Directory photosDirectory = Directory(photosDir);
      if (!await photosDirectory.exists()) {
        await photosDirectory.create(recursive: true);
      }

      // Generate unique filename
      final String fileName = '${const Uuid().v4()}.jpg';
      final String filePath = path.join(photosDir, fileName);

      // Copy the file to app directory
      await File(photo.path).copy(filePath);

      return filePath;
    } catch (e) {
      throw Exception('Failed to save photo: $e');
    }
  }

  Future<void> deletePhoto(String photoPath) async {
    try {
      final File photoFile = File(photoPath);
      if (await photoFile.exists()) {
        await photoFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }

  Future<bool> photoExists(String photoPath) async {
    if (photoPath.isEmpty) return false;
    try {
      if (kIsWeb) {
        // For web, we can't check if file exists in the same way
        // Return true if path is not empty (basic check)
        return photoPath.isNotEmpty;
      }
      final File photoFile = File(photoPath);
      return await photoFile.exists();
    } catch (e) {
      return false;
    }
  }
}
