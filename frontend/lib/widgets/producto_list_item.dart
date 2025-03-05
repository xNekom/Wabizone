import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../utils/constants_utils.dart';
import '../utils/format_utils.dart';
import '../utils/image_utils.dart';
import '../providers/carrito_provider.dart';
import '../screens/cart_screen.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class ProductoListItem extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final Function() onIncrement;
  final Function() onDecrement;
  final bool isEditable;

  const ProductoListItem({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.onIncrement,
    required this.onDecrement,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: _buildProductImage(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(producto.descripcion),
                  const SizedBox(height: 4),
                  Text("Precio: ${FormatUtils.formatPrice(producto.precio)}"),
                  Text(
                    "Stock: ${producto.stock}",
                    style: TextStyle(
                      color: producto.stock > 0
                          ? Constants.successColor
                          : Constants.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isEditable && producto.stock > 0 && cantidad > 0)
                    ElevatedButton.icon(
                      onPressed: () => _addToCart(context),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Añadir al carrito'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            if (isEditable)
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: cantidad > 0 ? onDecrement : null,
                        icon: const Icon(Icons.remove),
                        color:
                            cantidad > 0 ? Constants.errorColor : Colors.grey,
                      ),
                      Text(
                        cantidad.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed:
                            producto.stock > cantidad ? onIncrement : null,
                        icon: const Icon(Icons.add),
                        color: producto.stock > cantidad
                            ? Constants.successColor
                            : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos una unidad'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final carritoProvider =
        Provider.of<CarritoProvider>(context, listen: false);

    try {
      // Buscar el producto ID numérico real basado en su identificador personalizado
      // En lugar de convertir directamente el customId que puede tener formato de texto como 'p1'
      int productoIdNumerico = _getProductIdFromCustomId(producto.id);

      carritoProvider.addToCart(
        productoId: productoIdNumerico,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: cantidad,
      );

      // Mostrar notificación de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '¡$cantidad ${cantidad == 1 ? 'unidad' : 'unidades'} de ${producto.nombre} añadido al carrito!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver carrito',
            onPressed: () {
              // Navegar a la pantalla del carrito
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
            textColor: Colors.white,
          ),
        ),
      );
    } catch (e) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al añadir al carrito: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método auxiliar para obtener el ID numérico a partir del customId
  int _getProductIdFromCustomId(String customId) {
    // Si el customId tiene un formato como "p1", extraer el número
    if (customId.startsWith('p')) {
      try {
        return int.parse(customId.substring(1));
      } catch (e) {
        throw Exception('ID de producto inválido');
      }
    } else {
      // Intentar parsear directamente si el customId ya es un número
      try {
        return int.parse(customId);
      } catch (e) {
        throw Exception('ID de producto inválido');
      }
    }
  }

  Widget _buildProductImage(BuildContext context) {
    try {
      print(
          'ProductoListItem: Construyendo imagen para producto: ${producto.id} - ${producto.nombre}');
      print('ProductoListItem: Ruta de imagen: ${producto.imagen}');

      // Si el producto tiene una imagen específica (no vacía y no es la imagen por defecto)
      if (producto.imagen.isNotEmpty &&
          !producto.imagen.contains('producto_default.png')) {
        // Verificar si es una imagen base64
        if (producto.imagen.startsWith('data:image')) {
          print('ProductoListItem: Detectada imagen base64');
          try {
            return Image.memory(
              ImageUtils.extractImageBytes(producto.imagen),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(
                    'ProductoListItem: Error al cargar imagen base64: $error');
                // Si falla, intentamos con la imagen específica para Producto 4
                if (producto.id == 'p4' || producto.id == '4') {
                  return Image.asset(
                    'assets/imagenes/prod4.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildErrorImage(context),
                  );
                }
                return _buildErrorImage(context);
              },
            );
          } catch (e) {
            print('ProductoListItem: Error al procesar imagen base64: $e');
            // Si falla, intentamos con la imagen específica para Producto 4
            if (producto.id == 'p4' || producto.id == '4') {
              return Image.asset(
                'assets/imagenes/prod4.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildErrorImage(context),
              );
            }
            return _buildErrorImage(context);
          }
        }

        // Si es una ruta de asset
        if (producto.imagen.startsWith('assets/')) {
          print(
              'ProductoListItem: Detectada ruta de asset: ${producto.imagen}');
          return Image.asset(
            producto.imagen,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('ProductoListItem: Error al cargar asset: $error');
              // Si falla, intentamos con la imagen específica para Producto 4
              if (producto.id == 'p4' || producto.id == '4') {
                return Image.asset(
                  'assets/imagenes/prod4.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildErrorImage(context),
                );
              }
              return _buildErrorImage(context);
            },
          );
        }

        // Si es una URL
        if (producto.imagen.startsWith('http')) {
          print(
              'ProductoListItem: Detectada URL de imagen: ${producto.imagen}');
          return Image.network(
            producto.imagen,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('ProductoListItem: Error al cargar imagen de red: $error');
              // Si falla, intentamos con la imagen específica para Producto 4
              if (producto.id == 'p4' || producto.id == '4') {
                return Image.asset(
                  'assets/imagenes/prod4.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildErrorImage(context),
                );
              }
              return _buildErrorImage(context);
            },
          );
        }
      }

      // Caso especial para Producto 4 - Siempre intentamos cargar la imagen específica como fallback
      if (producto.id == 'p4' || producto.id == '4') {
        print('ProductoListItem: Cargando imagen específica para Producto 4');
        return Image.asset(
          'assets/imagenes/prod4.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print(
                'ProductoListItem: Error al cargar imagen de Producto 4: $error');
            return _buildErrorImage(context);
          },
        );
      }

      // Para otros productos, usamos el ImageProvider de ImageUtils
      return Image(
        image: ImageUtils.getImageProvider(producto.imagen),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('ProductoListItem: Error al cargar imagen: $error');
          return _buildErrorImage(context);
        },
      );
    } catch (e) {
      print('ProductoListItem: Error general al construir imagen: $e');
      return _buildErrorImage(context);
    }
  }

  // Método para construir una imagen de error
  Widget _buildErrorImage(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[600],
          size: 40,
        ),
      ),
    );
  }
}
