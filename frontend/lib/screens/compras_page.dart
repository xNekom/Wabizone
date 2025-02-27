import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/producto.dart';
import '../models/pedido.dart';
import '../services/producto_service.dart';
import '../services/pedido_service.dart';
import '../utils/dialog_utils.dart';
import '../utils/constants_utils.dart';
import '../utils/format_utils.dart';
import '../utils/button_styles.dart';
import '../widgets/producto_list_item.dart';

class ComprasPage extends StatefulWidget {
  final Usuario usuario;
  const ComprasPage({super.key, required this.usuario});

  @override
  _ComprasPageState createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  Map<String, int> cantidades = {};
  List<Producto> productos = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final listaProductos = await ProductoService.obtenerTodosProductos();
      if (!mounted) return;

      setState(() {
        productos = listaProductos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        DialogUtils.showSnackBar(
            context, "Error al cargar productos: ${e.toString()}",
            color: Constants.errorColor);
      });
    }
  }

  double calcularTotal() {
    double total = 0;
    for (var producto in productos) {
      int cantidad = cantidades[producto.id] ?? 0;
      total += cantidad * producto.precio;
    }
    return total;
  }

  void _incrementarCantidad(Producto producto) {
    setState(() {
      int cantidadActual = cantidades[producto.id] ?? 0;
      if (cantidadActual < producto.stock) {
        cantidades[producto.id] = cantidadActual + 1;
      } else {
        DialogUtils.showSnackBar(context, "No hay suficiente stock disponible",
            color: Constants.warningColor);
      }
    });
  }

  void _decrementarCantidad(Producto producto) {
    setState(() {
      int cantidadActual = cantidades[producto.id] ?? 0;
      if (cantidadActual > 0) {
        cantidades[producto.id] = cantidadActual - 1;
      }
    });
  }

  bool _validarStock() {
    for (var producto in productos) {
      int cantidad = cantidades[producto.id] ?? 0;
      if (cantidad > producto.stock) {
        DialogUtils.showSnackBar(context,
            "${producto.nombre}: No hay suficiente stock. Stock disponible: ${producto.stock}",
            color: Constants.errorColor);
        return false;
      }
    }
    return true;
  }

  void _realizarCompra() {
    bool hayProductos = cantidades.values.any((cantidad) => cantidad > 0);
    if (!hayProductos) {
      DialogUtils.showSnackBar(context, "Seleccione al menos un producto",
          color: Constants.warningColor);
      return;
    }

    if (!_validarStock()) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double total = calcularTotal();
        return AlertDialog(
          title: const Text("Confirmar Compra"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Resumen del pedido:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...productos.map((producto) {
                  int cantidad = cantidades[producto.id] ?? 0;
                  if (cantidad > 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                          "${producto.nombre}: $cantidad x ${FormatUtils.formatPrice(producto.precio)}"),
                    );
                  }
                  return const SizedBox.shrink();
                }).whereType<Padding>(),
                const Divider(),
                Text("Total: ${FormatUtils.formatPrice(total)}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmarCompra();
              },
              style: estiloBoton(),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarCompra() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      String pedidoId = "P${DateTime.now().millisecondsSinceEpoch}";
      String detallesPedido = "";
      double total = 0;

      // Construir el detalle del pedido
      for (var producto in productos) {
        int cantidad = cantidades[producto.id] ?? 0;
        if (cantidad > 0) {
          if (cantidad <= producto.stock) {
            detallesPedido +=
                "${producto.nombre}: $cantidad x ${FormatUtils.formatPrice(producto.precio)}\n";
            total += cantidad * producto.precio;

            // Actualizar el stock (esto se haría idealmente en el backend)
            Producto productoActualizado = Producto(
              id: producto.id,
              nombre: producto.nombre,
              descripcion: producto.descripcion,
              imagen: producto.imagen,
              stock: producto.stock - cantidad,
              precio: producto.precio,
            );

            // Actualizar el producto en el backend
            await ProductoService.actualizarProducto(productoActualizado,
                int.parse(producto.id.replaceAll(RegExp(r'[^0-9]'), '')));
          } else {
            if (!mounted) return;

            setState(() {
              _isProcessing = false;
            });
            DialogUtils.showSnackBar(
                context, "Error: Stock insuficiente para ${producto.nombre}",
                color: Constants.errorColor);
            return;
          }
        }
      }

      // Crear el pedido
      Pedido pedido = Pedido(
        id: pedidoId,
        nPedido: DateTime.now().millisecondsSinceEpoch,
        detallesPedido: detallesPedido,
        estadoPedido: "Pendiente",
        precioTotal: total,
      );

      // Guardar el pedido
      Pedido? pedidoCreado = await PedidoService.crearPedido(pedido);
      if (!mounted) return;

      if (pedidoCreado != null) {
        DialogUtils.showSnackBar(context, "Compra realizada con éxito",
            color: Constants.successColor);
        setState(() {
          cantidades.clear();
        });

        // Recargar productos para actualizar stock
        await _cargarProductos();
      } else {
        DialogUtils.showSnackBar(context, "Error al crear el pedido",
            color: Constants.errorColor);
      }
    } catch (e) {
      if (!mounted) return;

      DialogUtils.showSnackBar(
          context, "Error al procesar la compra: ${e.toString()}",
          color: Constants.errorColor);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (productos.isEmpty)
          const Center(
            child: Text(
              "No hay productos disponibles",
              style: TextStyle(fontSize: 18),
            ),
          )
        else
          SingleChildScrollView(
            child: Column(
              children: [
                ...productos.map((producto) {
                  int currentQuantity = cantidades[producto.id] ?? 0;
                  return ProductoListItem(
                    producto: producto,
                    cantidad: currentQuantity,
                    onIncrement: () => _incrementarCantidad(producto),
                    onDecrement: () => _decrementarCantidad(producto),
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _isProcessing
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ElevatedButton(
                  onPressed: productos.isEmpty ? null : _realizarCompra,
                  style: estiloBoton(),
                  child: const Text("Realizar Compra"),
                ),
        ),
      ],
    );
  }
}
