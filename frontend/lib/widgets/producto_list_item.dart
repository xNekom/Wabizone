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
              child: Image(
                image: ImageUtils.getImageProvider(producto.imagen),
                fit: BoxFit.cover,
              ),
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
}
