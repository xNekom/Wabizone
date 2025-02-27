import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../utils/constants_utils.dart';
import '../utils/format_utils.dart';
import '../utils/image_utils.dart';

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
}
