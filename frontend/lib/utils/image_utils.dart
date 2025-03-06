import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  static const String defaultLogoImage = 'assets/imagenes/logo.png';
  static const String defaultProductImage =
      'assets/imagenes/producto_default.png';
  static const String assetPath = 'assets/imagenes/';

  static String getProductImage(String productId) {
    if (productId.isEmpty) {
      return defaultProductImage;
    }

    if (productId == 'p4' || productId == '4') {
      return 'assets/imagenes/prod4.png';
    }

    switch (productId) {
      case 'p1':
        return 'assets/imagenes/prod1.png';
      case 'p2':
        return 'assets/imagenes/prod2.png';
      case 'p3':
        return 'assets/imagenes/prod3.png';
      case 'p4':
        return 'assets/imagenes/prod4.png';
      default:
        if (productId.startsWith('p')) {
          try {
            final numId = productId.substring(1);
            return 'assets/imagenes/prod$numId.png';
          } catch (e) {
            // Se ignora la excepción y se continúa con el flujo normal
          }
        } else if (RegExp(r'^\d+$').hasMatch(productId)) {
          return 'assets/imagenes/prod$productId.png';
        }
        return defaultProductImage;
    }
  }

  static String? validateImageFormat(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    if (imagePath.startsWith('data:image/')) {
      return null;
    }

    if (imagePath.startsWith('assets/')) {
      return null;
    }

    final extension = path.extension(imagePath).toLowerCase();
    if (extension.isEmpty && !imagePath.contains('.')) {
      if (imagePath.startsWith('p') || imagePath.startsWith('http')) {
        return null;
      }
    }

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];

    if (!validExtensions.contains(extension)) {
      if (imagePath.length < 20 && !imagePath.contains('/')) {
        return null;
      }
      return "Formato de imagen no válido. Use: JPG, JPEG, PNG, GIF, WEBP o BMP";
    }

    return null;
  }

  static Future<String?> pickImage({bool isForProfile = false}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final bytes = result.files.first.bytes!;
      final fileName = result.files.first.name;
      final fileSize = bytes.length;
      final extension = path.extension(fileName).toLowerCase();

      if (bytes.isEmpty) {
        return null;
      }

      Uint8List processedBytes = bytes;

      if (fileSize > 100 * 1024) {
        try {
          processedBytes = await comprimirImagen(bytes,
              maxWidth: isForProfile ? 400 : 800,
              maxHeight: isForProfile ? 400 : 800,
              calidad: isForProfile ? 60 : 80);

          if (processedBytes.isEmpty) {
            processedBytes = bytes;
          }
        } catch (e) {
          processedBytes = bytes;
        }
      }

      final maxSizeBytes = 15 * 1024 * 1024;

      if (processedBytes.length > maxSizeBytes) {
        try {
          processedBytes = await comprimirImagen(processedBytes,
              maxWidth: 400, maxHeight: 400, calidad: 50);

          if (processedBytes.length > maxSizeBytes) {
            return null;
          }
        } catch (e) {
          if (processedBytes.length > maxSizeBytes) {
            return null;
          }
        }
      }

      try {
        final img64 = base64Encode(processedBytes);
        String mimeType = 'image/png';

        if (extension == '.jpg' || extension == '.jpeg') {
          mimeType = 'image/jpeg';
        } else if (extension == '.gif') {
          mimeType = 'image/gif';
        } else if (extension == '.webp') {
          mimeType = 'image/webp';
        } else if (extension == '.bmp') {
          mimeType = 'image/bmp';
        }

        final dataUrl = 'data:$mimeType;base64,$img64';

        if (img64.isEmpty) {
          return null;
        }

        try {
          base64Decode(img64);
        } catch (e) {
          return null;
        }

        return dataUrl;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List> comprimirImagen(
    Uint8List bytes, {
    int maxWidth = 800,
    int maxHeight = 800,
    int calidad = 80,
  }) async {
    try {
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxWidth || image.height > maxHeight) {
        final aspectRatio = image.width / image.height;

        if (image.width > image.height) {
          newWidth = maxWidth;
          newHeight = (newWidth / aspectRatio).round();

          if (newHeight > maxHeight) {
            newHeight = maxHeight;
            newWidth = (newHeight * aspectRatio).round();
          }
        } else {
          newHeight = maxHeight;
          newWidth = (newHeight * aspectRatio).round();

          if (newWidth > maxWidth) {
            newWidth = maxWidth;
            newHeight = (newWidth / aspectRatio).round();
          }
        }
      }

      final img.Image resizedImage =
          (newWidth != image.width || newHeight != image.height)
              ? img.copyResize(image, width: newWidth, height: newHeight)
              : image;

      Uint8List compressedBytes;

      bool isJpeg = false;
      try {
        if (bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
          isJpeg = true;
        }
      } catch (e) {
        // Se ignora la excepción y se asume que no es JPEG
      }

      if (isJpeg) {
        compressedBytes =
            Uint8List.fromList(img.encodeJpg(resizedImage, quality: calidad));
      } else {
        compressedBytes = Uint8List.fromList(img.encodePng(resizedImage));
      }

      return compressedBytes;
    } catch (e) {
      return bytes;
    }
  }

  static String getDefaultImage(bool isUser) {
    return defaultLogoImage;
  }

  static bool isAssetImage(String path) {
    return path.startsWith('assets/');
  }

  static bool isDataUrl(String path) {
    return path.startsWith('data:image');
  }

  static Uint8List extractImageBytes(String base64Image) {
    try {
      final dataStart = base64Image.indexOf(',') + 1;
      final base64Data = base64Image.substring(dataStart);

      return base64Decode(base64Data);
    } catch (e) {
      return Uint8List(0);
    }
  }

  static void debugImage(String? imagePath, String source) {}

  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage(defaultProductImage);
    }

    // Caso especial para Producto 4
    if (imagePath == 'p4' ||
        imagePath == '4' ||
        imagePath.contains('prod4') ||
        imagePath.contains('Producto 4') ||
        imagePath.contains('producto 4')) {
      return const AssetImage('assets/imagenes/prod4.png');
    }

    if (isDataUrl(imagePath)) {
      try {
        final comma = imagePath.indexOf(',');
        if (comma != -1) {
          final data = imagePath.substring(comma + 1);
          try {
            final decodedBytes = base64Decode(data);
            return MemoryImage(decodedBytes);
          } catch (e) {
            // Fallback a imagen por defecto
            return const AssetImage(defaultProductImage);
          }
        }
      } catch (e) {
        // Se ignora la excepción y se continúa con el manejo predeterminado de imágenes
      }
    }

    if (isAssetImage(imagePath)) {
      String cleanPath = imagePath;
      if (cleanPath.startsWith('assets/assets/')) {
        cleanPath = cleanPath.replaceFirst('assets/', '');
      }
      return AssetImage(cleanPath);
    }

    if (imagePath.startsWith('p') && !imagePath.contains('.')) {
      try {
        final productId = imagePath.substring(1);
        final specificPath = 'assets/imagenes/prod$productId.png';
        return AssetImage(specificPath);
      } catch (e) {
        return const AssetImage(defaultProductImage);
      }
    }

    if (RegExp(r'^\d+$').hasMatch(imagePath)) {
      final specificPath = 'assets/imagenes/prod$imagePath.png';
      return AssetImage(specificPath);
    }

    return const AssetImage(defaultProductImage);
  }
}
