import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/shopping_cart.dart';
import '../models/pedido.dart';
import '../providers/carrito_provider.dart';
import '../providers/pedido_provider.dart';
import '../providers/usuario_provider.dart';
import '../utils/format_utils.dart';
import '../providers/producto_provider.dart';
import '../utils/image_utils.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _codigoPostalController = TextEditingController();

  String _metodoPago = 'tarjeta';
  bool _procesandoPago = false;

  @override
  void initState() {
    super.initState();
    // Cargar productos si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productoProvider =
          Provider.of<ProductoProvider>(context, listen: false);
      if (productoProvider.productos.isEmpty) {
        productoProvider.obtenerTodosProductos();
      }
    });
  }

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
      ),
      body: _buildBody(carritoProvider),
    );
  }

  Widget _buildBody(CarritoProvider carritoProvider) {
    if (carritoProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (carritoProvider.isEmpty) {
      return const Center(child: Text('No hay productos en el carrito'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCartSummary(carritoProvider.cart),
            const Divider(height: 32),
            _buildShippingForm(),
            const Divider(height: 32),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildCheckoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return ElevatedButton(
      onPressed: _procesandoPago ? null : () => _procesarPago(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _procesandoPago
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('FINALIZAR COMPRA', style: TextStyle(fontSize: 16)),
    );
  }

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
            ...cart.items.map((item) => _buildCartItem(item)),
            const Divider(height: 24),
            _buildPriceSummary(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(ShoppingCart cart) {
    return Column(
      children: [
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
          children: const [
            Text('Envío:'),
            Text('Gratis'),
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
    );
  }

  Widget _buildCartItem(CartItem item) {
    final productoProvider =
        Provider.of<ProductoProvider>(context, listen: false);
    String imagenUrl = _getProductImageUrl(item.productoId, productoProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProductImage(imagenUrl),
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

  String _getProductImageUrl(
      int productoId, ProductoProvider productoProvider) {
    // Caso especial para Producto 4
    if (productoId == 4) {
      return 'assets/imagenes/prod4.png';
    }

    for (var producto in productoProvider.productos) {
      try {
        int? idNum;
        if (producto.id.startsWith('p')) {
          idNum = int.parse(producto.id.substring(1));
        } else {
          idNum = int.parse(producto.id);
        }

        if (idNum == productoId) {
          return producto.imagen;
        }
      } catch (e) {
        continue;
      }
    }
    return '';
  }

  Widget _buildProductImage(String imagenUrl) {
    if (imagenUrl.isNotEmpty) {
      return ClipRRect(
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
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        color: Colors.grey.shade300,
        child:
            const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
      );
    }
  }

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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nombre';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Por favor ingresa un email válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _telefonoController,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu teléfono';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _direccionController,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu dirección';
            }
            return null;
          },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu ciudad';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu código postal';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

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
        _buildPaymentOption(
          value: 'tarjeta',
          icon: Icons.credit_card,
          title: 'Tarjeta de crédito/débito',
        ),
        _buildPaymentOption(
          value: 'transferencia',
          icon: Icons.account_balance,
          title: 'Transferencia bancaria',
        ),
        _buildPaymentOption(
          value: 'contraentrega',
          icon: Icons.payment,
          title: 'Pago contrareembolso',
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String title,
  }) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      value: value,
      groupValue: _metodoPago,
      onChanged: (value) {
        setState(() {
          _metodoPago = value!;
        });
      },
    );
  }

  Future<void> _procesarPago(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _procesandoPago = true;
    });

    final carritoProvider =
        Provider.of<CarritoProvider>(context, listen: false);
    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);

    // Capturar el contexto antes de la operación asincrónica
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final direccionCompleta =
          '${_direccionController.text}, ${_ciudadController.text}, ${_codigoPostalController.text}';
      final metodoPagoTexto = _getMetodoPagoTexto();

      final detallesPedido = _generarDetallesPedido(
        carritoProvider.cart,
        metodoPagoTexto,
        direccionCompleta,
      );

      final nuevoPedido = Pedido(
        id: 'temp',
        nPedido: 0,
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

      final pedidoCreado = await pedidoProvider.crearPedido(nuevoPedido);

      if (pedidoCreado == null) {
        throw Exception('No se pudo crear el pedido');
      }

      await carritoProvider.clearCart();

      setState(() {
        _procesandoPago = false;
      });

      if (!mounted) return;

      _mostrarConfirmacionPedido(navigator, pedidoCreado);
    } catch (e) {
      setState(() {
        _procesandoPago = false;
      });

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getMetodoPagoTexto() {
    switch (_metodoPago) {
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia bancaria';
      case 'contraentrega':
        return 'Pago contrareembolso';
      default:
        return 'Tarjeta';
    }
  }

  String _generarDetallesPedido(
    ShoppingCart cart,
    String metodoPagoTexto,
    String direccionCompleta,
  ) {
    final productosTexto = cart.items.map((item) {
      return '- ${item.nombre}: ${item.cantidad} x ${item.precio} = ${item.subtotal} €';
    }).join('\n');

    return '''
Cliente: ${_nombreController.text}
Email: ${_emailController.text}
Teléfono: ${_telefonoController.text}
Dirección: $direccionCompleta

Método de pago: $metodoPagoTexto

Productos:
$productosTexto
''';
  }

  void _mostrarConfirmacionPedido(NavigatorState navigator, Pedido pedido) {
    showDialog(
      context: navigator.context,
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
            Text('Número de pedido: ${pedido.nPedido}'),
            Text('Estado: ${pedido.estadoPedido}'),
            Text('Total: ${FormatUtils.formatPrice(pedido.precioTotal)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              navigator.popUntil((route) => route.isFirst);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
