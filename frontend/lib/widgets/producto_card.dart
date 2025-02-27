import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../utils/format_utils.dart';
import '../utils/image_utils.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: producto.imagen.isEmpty
              ? const Icon(Icons.image_not_supported, size: 40)
              : Image(
                  image: ImageUtils.getImageProvider(producto.imagen),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 40);
                  },
                ),
        ),
        title: Text(producto.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Precio: ${FormatUtils.formatPrice(producto.precio)} - Stock: ${producto.stock}"),
            Text(producto.descripcion,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
