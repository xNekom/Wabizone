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

    // Si es una URL de datos (base64), lo considero válido
    if (imagePath.startsWith('data:image')) {
      return null;
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
        withData: true, // Siempre necesitamos los datos para manejar base64
      );

      if (result != null) {
        if (kIsWeb || result.files.first.bytes != null) {
          // En web o cuando tenemos los bytes disponibles, usamos data URLs
          final bytes = result.files.first.bytes!;
          final mimeType = _getMimeType(result.files.first.extension ?? '');
          return Uri.dataFromBytes(bytes, mimeType: mimeType).toString();
        } else if (result.files.first.path != null) {
          return result.files.first.path;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Helper para determinar el tipo MIME basado en la extensión
  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/png'; // Default fallback
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

  // Procesa una imagen base64 para asegurar que sea válida y no exceda el tamaño máximo
  static String? processBase64Image(String? base64Image,
      {int maxLength = 100000}) {
    if (base64Image == null || base64Image.trim().isEmpty) {
      debugPrint('processBase64Image: Imagen vacía o nula');
      return null;
    }

    debugPrint(
        'processBase64Image: Procesando imagen de ${base64Image.length} caracteres');

    // Si no es una cadena larga, probablemente no es base64
    if (base64Image.length < 500) {
      return base64Image;
    }

    // Verificar y añadir prefijo si es necesario
    String processedImage = base64Image;
    if (!base64Image.startsWith('data:image')) {
      debugPrint('processBase64Image: Añadiendo prefijo data:URL');
      processedImage = 'data:image/png;base64,' +
          base64Image.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), '');
    }

    // Truncar si excede el tamaño máximo
    if (processedImage.length > maxLength) {
      debugPrint(
          'processBase64Image: Imagen demasiado grande, truncando a $maxLength caracteres');
      return processedImage.substring(0, maxLength);
    }

    return processedImage;
  }

  // Optimiza el proceso de selección de imágenes para asegurar que son válidas
  static Future<String?> pickAndProcessImage({int maxLength = 100000}) async {
    String? imagePath = await pickImage();
    if (imagePath == null) return null;

    // Si es una URL de datos (base64), procesarla
    if (imagePath.startsWith('data:')) {
      return processBase64Image(imagePath, maxLength: maxLength);
    }

    return imagePath;
  }
}
