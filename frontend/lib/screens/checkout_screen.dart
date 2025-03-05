import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/shopping_cart.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../providers/pedido_provider.dart';
import '../providers/usuario_provider.dart';
import '../utils/format_utils.dart';
import '../providers/producto_provider.dart';
import '../utils/image_utils.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Controladores para los campos del formulario
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _codigoPostalController = TextEditingController();

  // Estado para controlar la forma de pago seleccionada
  String _metodoPago = 'tarjeta';

  // Estado para indicar si se está procesando el pago
  bool _procesandoPago = false;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _codigoPostalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);
    // Asegurarse de que los productos estén cargados
    final productoProvider =
        Provider.of<ProductoProvider>(context, listen: false);
    if (productoProvider.productos.isEmpty) {
      productoProvider.obtenerTodosProductos();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
      ),
      body: carritoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : carritoProvider.isEmpty
              ? const Center(
                  child: Text('No hay productos en el carrito'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Resumen del carrito
                      _buildCartSummary(carritoProvider.cart),

                      const Divider(height: 32),

                      // Información de envío
                      _buildShippingForm(),

                      const Divider(height: 32),

                      // Métodos de pago
                      _buildPaymentMethods(),

                      const SizedBox(height: 24),

                      // Botón de finalizar compra
                      ElevatedButton(
                        onPressed: _procesandoPago
                            ? null
                            : () => _procesarPago(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _procesandoPago
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('FINALIZAR COMPRA',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Widget para mostrar el resumen del carrito
  Widget _buildCartSummary(ShoppingCart cart) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de productos
            ...cart.items.map((item) => _buildCartItem(item)),

            const Divider(height: 24),

            // Totales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text(FormatUtils.formatPrice(cart.total)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Envío:'),
                const Text('Gratis'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  FormatUtils.formatPrice(cart.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar cada ítem del carrito
  Widget _buildCartItem(CartItem item) {
    // Buscar la imagen del producto usando el provider de productos
    String imagenUrl = '';
    final productoProvider =
        Provider.of<ProductoProvider>(context, listen: false);

    for (var producto in productoProvider.productos) {
      try {
        int? idNum;
        if (producto.id.startsWith('p')) {
          idNum = int.parse(producto.id.substring(1));
        } else {
          idNum = int.parse(producto.id);
        }

        if (idNum == item.productoId) {
          imagenUrl = producto.imagen;
          break;
        }
      } catch (e) {
        // Ignorar errores de conversión
        continue;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen del producto
          if (imagenUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Image(
                  image: ImageUtils.getImageProvider(imagenUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image,
                          color: Colors.grey, size: 20),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported,
                  color: Colors.grey, size: 20),
            ),
          const SizedBox(width: 12),
          Text('${item.cantidad}x '),
          Expanded(
            child: Text(
              item.nombre,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(FormatUtils.formatPrice(item.subtotal)),
        ],
      ),
    );
  }

  // Widget para el formulario de información de envío
  Widget _buildShippingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de Envío',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _telefonoController,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _direccionController,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _codigoPostalController,
                decoration: const InputDecoration(
                  labelText: 'Código Postal',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget para los métodos de pago
  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de Pago',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RadioListTile<String>(
          title: const Row(
            children: [
              Icon(Icons.credit_card),
              SizedBox(width: 12),
              Text('Tarjeta de crédito/débito'),
            ],
          ),
          value: 'tarjeta',
          groupValue: _metodoPago,
          onChanged: (value) {
            setState(() {
              _metodoPago = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Row(
            children: [
              Icon(Icons.account_balance),
              SizedBox(width: 12),
              Text('Transferencia bancaria'),
            ],
          ),
          value: 'transferencia',
          groupValue: _metodoPago,
          onChanged: (value) {
            setState(() {
              _metodoPago = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Row(
            children: [
              Icon(Icons.payment),
              SizedBox(width: 12),
              Text('Pago contrareembolso'),
            ],
          ),
          value: 'contraentrega',
          groupValue: _metodoPago,
          onChanged: (value) {
            setState(() {
              _metodoPago = value!;
            });
          },
        ),
      ],
    );
  }

  // Método para procesar el pago
  Future<void> _procesarPago(BuildContext context) async {
    // Validar formulario
    if (_nombreController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _direccionController.text.isEmpty ||
        _ciudadController.text.isEmpty ||
        _codigoPostalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _procesandoPago = true;
    });

    // Obtener los proveedores
    final carritoProvider =
        Provider.of<CarritoProvider>(context, listen: false);
    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final productoProvider =
        Provider.of<ProductoProvider>(context, listen: false);

    try {
      // Crear el pedido con los datos del carrito
      final direccionCompleta =
          '${_direccionController.text}, ${_ciudadController.text}, ${_codigoPostalController.text}';
      final metodoPagoTexto = _metodoPago == 'tarjeta'
          ? 'Tarjeta'
          : _metodoPago == 'transferencia'
              ? 'Transferencia bancaria'
              : 'Pago contrareembolso';

      final detallesPedido =
          'Cliente: ${_nombreController.text}\nEmail: ${_emailController.text}\nTeléfono: ${_telefonoController.text}\nDirección: $direccionCompleta\n\nMétodo de pago: $metodoPagoTexto\n\nProductos:\n${carritoProvider.cart.items.map((item) {
        return '- ${item.nombre}: ${item.cantidad} x ${item.precio} = ${item.subtotal} €';
      }).join('\n')}';

      // Crear el objeto Pedido (con ID temporal que será reemplazado por el backend)
      final nuevoPedido = Pedido(
        id: 'temp', // Será asignado por el backend
        nPedido: 0, // Será asignado por el backend
        detallesPedido: detallesPedido,
        estadoPedido: 'Pendiente',
        precioTotal: carritoProvider.cart.total,
        usuarioId: usuarioProvider.usuarioActual?.id,
        nombreUsuario: usuarioProvider.usuarioActual?.usuario,
        nombreCompleto: _nombreController.text,
        direccion: _direccionController.text,
        ciudad: _ciudadController.text,
        codigoPostal: _codigoPostalController.text,
        telefono: _telefonoController.text,
        email: _emailController.text,
        comentarios: '',
      );

      // Crear el pedido en el backend
      final pedidoCreado = await pedidoProvider.crearPedido(nuevoPedido);

      if (pedidoCreado == null) {
        throw Exception('No se pudo crear el pedido');
      }

      // Actualizar el stock de productos
      List<Future<bool>> actualizacionesStock = [];

      for (var item in carritoProvider.cart.items) {
        // Buscar el producto por ID
        int productoId = item.productoId;
        String productoIdString = "";

        for (var producto in productoProvider.productos) {
          try {
            int? idNum;
            if (producto.id.startsWith('p')) {
              idNum = int.parse(producto.id.substring(1));
            } else {
              idNum = int.parse(producto.id);
            }

            if (idNum == productoId) {
              // Reducir el stock
              int nuevoStock = producto.stock - item.cantidad;
              if (nuevoStock < 0) nuevoStock = 0;

              // Crear copia del producto con stock actualizado
              final productoActualizado = Producto(
                id: producto.id,
                nombre: producto.nombre,
                descripcion: producto.descripcion,
                precio: producto.precio,
                stock: nuevoStock,
                imagen: producto.imagen,
              );

              // Actualizar el producto en la base de datos
              actualizacionesStock.add(productoProvider.actualizarProducto(
                  productoActualizado, idNum));

              break;
            }
          } catch (e) {
            print('Error al procesar ID de producto: $e');
            continue;
          }
        }
      }

      // Esperar a que todas las actualizaciones de stock terminen
      await Future.wait(actualizacionesStock);

      // Limpiar el carrito después de completar la compra
      await carritoProvider.clearCart();

      setState(() {
        _procesandoPago = false;
      });

      if (!mounted) return;

      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Pedido Realizado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu pedido ha sido procesado correctamente. Recibirás un email con los detalles de tu compra.',
              ),
              const SizedBox(height: 12),
              Text('Número de pedido: ${pedidoCreado.nPedido}'),
              Text('Estado: ${pedidoCreado.estadoPedido}'),
              Text(
                  'Total: ${FormatUtils.formatPrice(pedidoCreado.precioTotal)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo

                // En lugar de volver a la pantalla anterior directamente,
                // volvemos al HomeScreen con el índice del carrito
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _procesandoPago = false;
      });

      if (!mounted) return;

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
