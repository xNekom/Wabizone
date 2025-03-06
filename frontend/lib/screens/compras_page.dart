import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/dialog_utils.dart';
import '../utils/constants_utils.dart';
import '../widgets/producto_list_item.dart';

class ComprasPage extends StatefulWidget {
  final Usuario usuario;
  const ComprasPage({super.key, required this.usuario});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  Map<String, int> cantidades = {};
  List<Producto> productos = [];
  bool _isLoading = true;

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
                const SizedBox(height: 20),
              ],
            ),
          ),
      ],
    );
  }
}
