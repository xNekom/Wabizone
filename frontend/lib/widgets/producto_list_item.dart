import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../utils/constants_utils.dart';
import '../utils/format_utils.dart';
import '../utils/image_utils.dart';
import '../providers/carrito_provider.dart';
import '../screens/cart_screen.dart';

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
      int productoIdNumerico = _getProductIdFromCustomId(producto.id);

      carritoProvider.addToCart(
        productoId: productoIdNumerico,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: cantidad,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '¡$cantidad ${cantidad == 1 ? 'unidad' : 'unidades'} de ${producto.nombre} añadido al carrito!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver carrito',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
            textColor: Colors.white,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al añadir al carrito: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getProductIdFromCustomId(String customId) {
    if (customId.startsWith('p')) {
      try {
        return int.parse(customId.substring(1));
      } catch (e) {
        throw Exception('ID de producto inválido');
      }
    } else {
      try {
        return int.parse(customId);
      } catch (e) {
        throw Exception('ID de producto inválido');
      }
    }
  }

  Widget _buildProductImage(BuildContext context) {
    try {
      if (producto.imagen.isNotEmpty &&
          !producto.imagen.contains('producto_default.png')) {
        if (producto.imagen.startsWith('data:image')) {
          try {
            return Image.memory(
              ImageUtils.extractImageBytes(producto.imagen),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
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

        if (producto.imagen.startsWith('assets/')) {
          return Image.asset(
            producto.imagen,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
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

        if (producto.imagen.startsWith('http')) {
          return Image.network(
            producto.imagen,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
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

      if (producto.id == 'p4' || producto.id == '4') {
        return Image.asset(
          'assets/imagenes/prod4.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorImage(context);
          },
        );
      }

      return Image(
        image: ImageUtils.getImageProvider(producto.imagen),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage(context);
        },
      );
    } catch (e) {
      return _buildErrorImage(context);
    }
  }

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
