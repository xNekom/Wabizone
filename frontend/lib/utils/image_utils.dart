import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image_compression/image_compression.dart';
import 'package:image/image.dart' as img;

// Importamos la constante MAX_IMAGE_SIZE_BYTES desde usuario_service.dart

class ImageUtils {
  static const String defaultLogoImage = 'assets/imagenes/logo.png';
  static const String defaultProductImage =
      'assets/imagenes/producto_default.png';
  static const String assetPath = 'assets/imagenes/';

  /// Devuelve la ruta de la imagen para un producto
  static String getProductImage(String productId) {
    // Si no hay ID, devolvemos la imagen por defecto
    if (productId.isEmpty) {
      return defaultProductImage;
    }

    // Caso especial para el producto 4 (problema crítico)
    if (productId == 'p4' || productId == '4') {
      print(
          'getProductImage: Detectado producto 4, retornando imagen específica');
      return 'assets/imagenes/prod4.png';
    }

    // Intentamos buscar una imagen específica para el producto basado en el ID
    switch (productId) {
      case 'p1':
        return 'assets/imagenes/prod1.png';
      case 'p2':
        return 'assets/imagenes/prod2.png';
      case 'p3':
        return 'assets/imagenes/prod3.png';
      case 'p4': // Añadido explícitamente para mayor claridad
        return 'assets/imagenes/prod4.png'; // Cambiado de defaultProductImage a prod4.png
      default:
        // Intenta construir la ruta basada en el ID
        if (productId.startsWith('p')) {
          try {
            final numId = productId.substring(1);
            return 'assets/imagenes/prod$numId.png';
          } catch (e) {
            print('Error al extraer ID numérico: $e');
          }
        } else if (RegExp(r'^\d+$').hasMatch(productId)) {
          return 'assets/imagenes/prod$productId.png';
        }
        return defaultProductImage;
    }
  }

  static String? validateImageFormat(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null; // No me preocupo si no hay imagen, es opcional en los formularios
    }

    // Si es una URL de datos (base64), es válida
    if (imagePath.startsWith('data:image/')) {
      return null;
    }

    // Si es un asset, también es válido
    if (imagePath.startsWith('assets/')) {
      return null;
    }

    // Si es solo un nombre de archivo, intentamos extraer la extensión
    final extension = path.extension(imagePath).toLowerCase();
    if (extension.isEmpty && !imagePath.contains('.')) {
      // Si no tiene extensión, puede ser un ID de producto (ej: p1) o una URL
      if (imagePath.startsWith('p') || imagePath.startsWith('http')) {
        return null;
      }
    }

    // Verificamos si tiene una extensión válida
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];

    if (!validExtensions.contains(extension)) {
      print('Extensión no válida: $extension para ruta: $imagePath');
      // Permitimos también si no tiene extensión pero es un nombre corto (posible ID)
      if (imagePath.length < 20 && !imagePath.contains('/')) {
        return null;
      }
      return "Formato de imagen no válido. Use: JPG, JPEG, PNG, GIF, WEBP o BMP";
    }

    return null;
  }

  /// Selecciona una imagen de la galería o cámara y la convierte a formato base64
  static Future<String?> pickImage({bool isForProfile = false}) async {
    print('Seleccionando imagen...');

    // Usamos FilePicker para seleccionar la imagen
    try {
      print('Abriendo selector de imágenes...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        print('No se seleccionó ninguna imagen');
        return null;
      }

      // Mostrar información sobre el archivo seleccionado
      final bytes = result.files.first.bytes!;
      final fileName = result.files.first.name;
      final fileSize = bytes.length;
      final extension = path.extension(fileName).toLowerCase();

      print(
          'Imagen seleccionada: $fileName (${(fileSize / 1024).toStringAsFixed(2)} KB)');
      print('Extensión del archivo: $extension');
      print('Tamaño en bytes: $fileSize');

      // Verificar que tenemos bytes válidos
      if (bytes.isEmpty) {
        print('Error: Los bytes de la imagen están vacíos');
        return null;
      }

      // Utilizamos un método más simple para comprimir la imagen
      Uint8List processedBytes = bytes;

      // Si la imagen es más grande de 100KB, la comprimimos
      if (fileSize > 100 * 1024) {
        print('Comprimiendo imagen porque supera los 100KB...');
        try {
          processedBytes = await comprimirImagen(bytes,
              maxWidth: isForProfile ? 400 : 800,
              maxHeight: isForProfile ? 400 : 800,
              calidad: isForProfile ? 60 : 80);

          print(
              'Imagen comprimida: ${(processedBytes.length / 1024).toStringAsFixed(2)} KB');

          // Verificar que la compresión fue exitosa
          if (processedBytes.isEmpty) {
            print(
                'Error: La compresión resultó en bytes vacíos, usando imagen original');
            processedBytes = bytes;
          }
        } catch (e) {
          print('Error durante la compresión: $e');
          // Si hay error en la compresión, usamos la imagen original
          processedBytes = bytes;
        }
      }

      // Límite de tamaño máximo para MEDIUMBLOB (16MB)
      // Por seguridad limitamos a 15MB
      final maxSizeBytes = 15 * 1024 * 1024;

      // Si aún es demasiado grande, aplicar más compresión
      if (processedBytes.length > maxSizeBytes) {
        print(
            '¡Advertencia! Imagen sigue siendo demasiado grande, aplicando compresión adicional');
        try {
          processedBytes = await comprimirImagen(processedBytes,
              maxWidth: 400, maxHeight: 400, calidad: 50);

          // Verificar si sigue siendo demasiado grande
          if (processedBytes.length > maxSizeBytes) {
            print(
                '¡Error! La imagen sigue siendo demasiado grande incluso después de la compresión');
            return null;
          }
        } catch (e) {
          print('Error durante la compresión adicional: $e');
          // Si la imagen es demasiado grande y no se puede comprimir, fallamos
          if (processedBytes.length > maxSizeBytes) {
            print('La imagen es demasiado grande y no se puede comprimir');
            return null;
          }
        }
      }

      // Convertir a base64
      try {
        final img64 = base64Encode(processedBytes);
        // Determinar el tipo MIME basado en la extensión
        String mimeType = 'image/png'; // Por defecto

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

        print('Imagen convertida a base64 correctamente.');
        print('Tipo MIME: $mimeType');
        print('Longitud de la cadena base64: ${img64.length} caracteres');
        print('Longitud total del dataUrl: ${dataUrl.length} caracteres');

        // Verificar que la cadena base64 no esté vacía
        if (img64.isEmpty) {
          print('Error: La cadena base64 está vacía');
          return null;
        }

        // Verificar que la cadena base64 sea válida decodificándola
        try {
          final testDecode = base64Decode(img64);
          print(
              'Verificación de base64 exitosa. Tamaño decodificado: ${testDecode.length} bytes');
        } catch (e) {
          print('Error al verificar base64: $e');
          return null;
        }

        return dataUrl;
      } catch (e) {
        print('Error al convertir a base64: $e');
        return null;
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      return null;
    }
  }

  /// Comprime una imagen a partir de sus bytes
  static Future<Uint8List> comprimirImagen(
    Uint8List bytes, {
    int maxWidth = 800,
    int maxHeight = 800,
    int calidad = 80,
  }) async {
    print('Iniciando compresión de imagen: ${bytes.length} bytes');
    print(
        'Parámetros: maxWidth=$maxWidth, maxHeight=$maxHeight, calidad=$calidad');

    try {
      // Decodificar la imagen
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        print('Error: No se pudo decodificar la imagen');
        throw Exception('No se pudo decodificar la imagen');
      }

      print('Imagen decodificada: ${image.width}x${image.height} píxeles');

      // Calcular las nuevas dimensiones manteniendo la relación de aspecto
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxWidth || image.height > maxHeight) {
        final aspectRatio = image.width / image.height;

        if (image.width > image.height) {
          // Imagen horizontal
          newWidth = maxWidth;
          newHeight = (newWidth / aspectRatio).round();

          // Si la altura sigue siendo mayor que maxHeight
          if (newHeight > maxHeight) {
            newHeight = maxHeight;
            newWidth = (newHeight * aspectRatio).round();
          }
        } else {
          // Imagen vertical
          newHeight = maxHeight;
          newWidth = (newHeight * aspectRatio).round();

          // Si el ancho sigue siendo mayor que maxWidth
          if (newWidth > maxWidth) {
            newWidth = maxWidth;
            newHeight = (newWidth / aspectRatio).round();
          }
        }

        print('Redimensionando imagen a: ${newWidth}x${newHeight} píxeles');
      } else {
        print('No es necesario redimensionar la imagen');
      }

      // Redimensionar la imagen si es necesario
      final img.Image resizedImage =
          (newWidth != image.width || newHeight != image.height)
              ? img.copyResize(image, width: newWidth, height: newHeight)
              : image;

      // Comprimir la imagen según el formato
      Uint8List compressedBytes;

      // Intentar determinar el formato original
      bool isJpeg = false;
      try {
        // Verificar los primeros bytes para determinar si es JPEG
        if (bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
          isJpeg = true;
          print('Formato detectado: JPEG');
        } else if (bytes.length > 8 &&
            bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4E &&
            bytes[3] == 0x47) {
          print('Formato detectado: PNG');
        } else {
          print('Formato no detectado, usando PNG por defecto');
        }
      } catch (e) {
        print('Error al detectar formato: $e');
      }

      // Comprimir según el formato
      if (isJpeg) {
        print('Comprimiendo como JPEG con calidad: $calidad');
        compressedBytes =
            Uint8List.fromList(img.encodeJpg(resizedImage, quality: calidad));
      } else {
        print('Comprimiendo como PNG');
        compressedBytes = Uint8List.fromList(img.encodePng(resizedImage));
      }

      print('Compresión completada: ${compressedBytes.length} bytes');
      print(
          'Tasa de compresión: ${(bytes.length / compressedBytes.length).toStringAsFixed(2)}x');

      return compressedBytes;
    } catch (e) {
      print('Error durante la compresión de imagen: $e');
      // Si hay un error, devolvemos la imagen original
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

  /// Método para extraer bytes de una imagen base64
  static Uint8List extractImageBytes(String base64Image) {
    try {
      // Extraer la parte de datos de la cadena base64
      final dataStart = base64Image.indexOf(',') + 1;
      final base64Data = base64Image.substring(dataStart);

      // Decodificar base64
      return base64Decode(base64Data);
    } catch (e) {
      print('Error al extraer bytes de imagen base64: $e');
      // Devolver un array vacío en caso de error
      return Uint8List(0);
    }
  }

  /// Método de depuración para ver información detallada sobre la imagen
  static void debugImage(String? imagePath, String source) {
    if (imagePath == null || imagePath.isEmpty) {
      print('[$source] Imagen: NULA o VACÍA');
      return;
    }

    print('[$source] Imagen: "$imagePath"');
    print('[$source] Es asset: ${isAssetImage(imagePath)}');
    print('[$source] Es dataUrl: ${isDataUrl(imagePath)}');
    print(
        '[$source] Es ID de producto: ${imagePath.startsWith('p') && !imagePath.contains('.')}');

    if (imagePath.startsWith('p') && !imagePath.contains('.')) {
      final productId = imagePath.substring(1);
      print('[$source] ID producto extraído: $productId');
      print('[$source] Ruta específica: assets/imagenes/prod$productId.png');
    }
  }

  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      print('ImageUtils: Imagen nula o vacía, usando imagen por defecto');
      return const AssetImage(defaultProductImage);
    }

    print('ImageUtils: Intentando cargar imagen: $imagePath');

    // Si es una URL de datos (base64), intentamos cargarla primero
    if (isDataUrl(imagePath)) {
      try {
        // Extraer la parte de base64 (después de la coma)
        final comma = imagePath.indexOf(',');
        if (comma != -1) {
          final data = imagePath.substring(comma + 1);
          try {
            final decodedBytes = base64Decode(data);
            print('ImageUtils: Imagen base64 decodificada correctamente');
            return MemoryImage(decodedBytes);
          } catch (e) {
            print('ImageUtils: Error al decodificar base64: $e');
            // Si falla y es el Producto 4, usamos la imagen específica
            if (imagePath.contains('p4') || imagePath.contains('Producto 4')) {
              print('ImageUtils: Fallback a imagen específica para Producto 4');
              return const AssetImage('assets/imagenes/prod4.png');
            }
          }
        }
      } catch (e) {
        print('ImageUtils: Error al procesar imagen base64: $e');
      }
    }

    // Si es un asset (empieza por "assets/"), intentamos cargarlo
    if (isAssetImage(imagePath)) {
      // Corregir rutas duplicadas
      String cleanPath = imagePath;
      if (cleanPath.startsWith('assets/assets/')) {
        cleanPath = cleanPath.replaceFirst('assets/', '');
        print(
            'ImageUtils: Corrigiendo ruta duplicada: $imagePath -> $cleanPath');
      }

      // Si es el Producto 4, asegurarnos de usar la imagen correcta
      if (cleanPath.contains('prod4') || cleanPath.contains('Producto 4')) {
        print('ImageUtils: Cargando imagen específica para Producto 4');
        return const AssetImage('assets/imagenes/prod4.png');
      }

      return AssetImage(cleanPath);
    }

    // Caso especial para Producto 4 - Siempre intentamos cargar la imagen específica
    if (imagePath == 'p4' ||
        imagePath == '4' ||
        imagePath.contains('prod4') ||
        imagePath.contains('Producto 4') ||
        imagePath.contains('producto 4')) {
      print('ImageUtils: Cargando imagen específica para Producto 4');
      return const AssetImage('assets/imagenes/prod4.png');
    }

    // Si es un ID de producto (ej: "p1", "p2", etc.)
    if (imagePath.startsWith('p') && !imagePath.contains('.')) {
      try {
        // Extraer el número del ID
        final productId = imagePath.substring(1);
        // Si es el Producto 4, asegurarnos de usar la imagen correcta
        if (productId == '4') {
          print('ImageUtils: ID de Producto 4 detectado');
          return const AssetImage('assets/imagenes/prod4.png');
        }
        // Intenta construir la ruta basada en el ID
        final specificPath = 'assets/imagenes/prod${productId}.png';
        return AssetImage(specificPath);
      } catch (e) {
        print('ImageUtils: Error al decodificar ID de producto: $e');
        return const AssetImage(defaultProductImage);
      }
    }

    // Si es sólo un número (podría ser ID de producto)
    if (RegExp(r'^\d+$').hasMatch(imagePath)) {
      // Si es el Producto 4, asegurarnos de usar la imagen correcta
      if (imagePath == '4') {
        print('ImageUtils: ID numérico de Producto 4 detectado');
        return const AssetImage('assets/imagenes/prod4.png');
      }
      final specificPath = 'assets/imagenes/prod$imagePath.png';
      return AssetImage(specificPath);
    }

    // Si llegamos aquí, es una ruta no estándar o no válida
    print('ImageUtils: Usando imagen por defecto (ruta no reconocida)');
    return const AssetImage(defaultProductImage);
  }
}
