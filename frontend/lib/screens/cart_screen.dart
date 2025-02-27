import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../providers/producto_provider.dart';
import '../utils/constants_utils.dart';
import '../utils/image_utils.dart';
import 'checkout_screen.dart';
import '../utils/format_utils.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asegurarse de que los productos estén cargados
    final productoProvider =
        Provider.of<ProductoProvider>(context, listen: false);
    if (productoProvider.productos.isEmpty) {
      productoProvider.obtenerTodosProductos();
    }

    return Consumer<CarritoProvider>(
      builder: (context, carritoProvider, child) {
        if (carritoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (carritoProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${carritoProvider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reiniciar el estado del carrito
                    carritoProvider.clearCart();
                  },
                  child: const Text('Intentar nuevamente'),
                ),
              ],
            ),
          );
        }

        if (carritoProvider.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Añade productos para comenzar a comprar',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: carritoProvider.cart.items.length,
                    itemBuilder: (context, index) {
                      final CartItem item = carritoProvider.cart.items[index];
                      return _buildCartItem(
                          context, item, carritoProvider, productoProvider);
                    },
                  ),
                ),
                _buildCartSummary(context, carritoProvider),
                // Añadir espacio para el botón flotante
                const SizedBox(height: 70),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Navegar a la pantalla de checkout
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                label: const Text('Proceder al pago'),
                icon: const Icon(Icons.payment),
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton(
                heroTag: "btnClearCart",
                onPressed: () => _confirmClearCart(context),
                tooltip: 'Vaciar carrito',
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.delete_outline),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item,
      CarritoProvider carritoProvider, ProductoProvider productoProvider) {
    // Encontrar el producto completo por ID para obtener la imagen
    Producto? productoCompleto;
    String? imagenUrl;

    // Buscar en la lista de productos por el ID del producto
    for (var producto in productoProvider.productos) {
      // Intentar encontrar el ID numérico del producto
      int? idNum;
      try {
        // El ID del producto puede ser algo como 'p1', extraer el número
        if (producto.id.startsWith('p')) {
          idNum = int.parse(producto.id.substring(1));
        } else {
          idNum = int.parse(producto.id);
        }

        if (idNum == item.productoId) {
          productoCompleto = producto;
          imagenUrl = producto.imagen;
          break;
        }
      } catch (e) {
        // Ignorar errores de conversión
        continue;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto utilizando ImageUtils
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildProductImage(imagenUrl),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.opciones != null)
                    Text(
                      'Opciones: ${item.opciones}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.precio.toStringAsFixed(2)} €',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: item.cantidad > 1
                          ? () => _decrementarCantidad(
                              context, item, carritoProvider)
                          : () => _confirmRemoveItem(
                              context, item, carritoProvider),
                      iconSize: 20,
                    ),
                    Text(
                      '${item.cantidad}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          _incrementarCantidad(context, item, carritoProvider),
                      iconSize: 20,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      _confirmRemoveItem(context, item, carritoProvider),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    return Image(
      image: ImageUtils.getImageProvider(imagenUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error al cargar la imagen: $error');
        return Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildCartSummary(
      BuildContext context, CarritoProvider carritoProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                FormatUtils.formatPrice(carritoProvider.total),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${carritoProvider.itemCount} ${carritoProvider.itemCount == 1 ? 'producto' : 'productos'} en tu carrito',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _incrementarCantidad(
      BuildContext context, CartItem item, CarritoProvider carritoProvider) {
    carritoProvider.updateItemQuantity(item.productoId, item.cantidad + 1);
  }

  void _decrementarCantidad(
      BuildContext context, CartItem item, CarritoProvider carritoProvider) {
    carritoProvider.updateItemQuantity(item.productoId, item.cantidad - 1);
  }

  void _confirmRemoveItem(
      BuildContext context, CartItem item, CarritoProvider carritoProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Eliminar producto?'),
          content: Text(
              '¿Estás seguro que deseas eliminar ${item.nombre} del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                carritoProvider.removeFromCart(item.productoId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearCart(BuildContext context) {
    final carritoProvider =
        Provider.of<CarritoProvider>(context, listen: false);

    if (carritoProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito ya está vacío'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vaciar carrito'),
          content: const Text('¿Estás seguro que deseas vaciar tu carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                carritoProvider.clearCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Vaciar'),
            ),
          ],
        );
      },
    );
  }
}

// Mantener la clase CartScreen para compatibilidad
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const CartPage(),
    );
  }
}
