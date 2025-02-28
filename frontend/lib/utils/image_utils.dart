import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

class ImageUtils {
  static const String defaultLogoImage = 'assets/imagenes/logo.png';
  static const String assetPath = 'assets/imagenes/';

  static String? validateImageFormat(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null; // No me preocupo si no hay imagen, es opcional en los formularios
    }

    final extension = path.extension(imagePath).toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif'];

    if (!validExtensions.contains(extension)) {
      return "Formato de imagen no válido. Use: JPG, JPEG, PNG o GIF";
    }

    return null;
  }

  static Future<String?> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData:
            kIsWeb, // Necesito esto activado para que funcione en la versión web
      );

      if (result != null) {
        if (kIsWeb) {
          // En web tengo que usar data URLs porque el sistema de archivos funciona diferente
          final bytes = result.files.first.bytes!;
          return Uri.dataFromBytes(bytes, mimeType: 'image/png').toString();
        } else {
          return result.files.first.path;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static String getDefaultImage(bool isUser) {
    return isUser ? "default_user.png" : "default_product.png";
  }

  static bool isAssetImage(String path) {
    return path.startsWith('assets/');
  }

  static bool isDataUrl(String path) {
    return path.startsWith('data:image');
  }

  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage(defaultLogoImage);
    }

    if (isAssetImage(imagePath)) {
      // Me aseguro que la ruta del asset esté bien formada para evitar errores de carga
      final String assetName = imagePath.startsWith(assetPath)
          ? imagePath
          : '$assetPath${imagePath.split('/').last}';
      return AssetImage(assetName);
    } else if (isDataUrl(imagePath)) {
      return NetworkImage(imagePath);
    } else if (kIsWeb) {
      // En web necesito manejar las rutas de manera especial por el sistema de archivos
      if (!imagePath.contains('://')) {
        return AssetImage('$assetPath${imagePath.split('/').last}');
      }
      return NetworkImage(imagePath);
    } else {
      try {
        return FileImage(File(imagePath));
      } catch (e) {
        debugPrint('Error loading image: $e');
        return const AssetImage(defaultLogoImage);
      }
    }
  }
}
