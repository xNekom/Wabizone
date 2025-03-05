import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/format_utils.dart';

class PedidoCard extends StatefulWidget {
  final Pedido pedido;
  final Map<String, IconData> estadoIconos;
  final Map<String, Color> estadoColores;
  final Function(String) onEstadoChanged;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.estadoIconos,
    required this.estadoColores,
    required this.onEstadoChanged,
  });

  @override
  State<PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  List<Map<String, dynamic>> productosEnPedido = [];
  bool _cargandoProductos = true;
  List<Producto> _todosLosProductos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargandoProductos = true;
    });

    try {
      _todosLosProductos = await ProductoService.obtenerTodosProductos();
      productosEnPedido = _parsearDetallesPedido(widget.pedido.detallesPedido);
    } catch (e) {
    } finally {
      setState(() {
        _cargandoProductos = false;
      });
    }
  }

  List<Map<String, dynamic>> _parsearDetallesPedido(String detalles) {
    List<Map<String, dynamic>> resultado = [];
    List<String> lineas = detalles.split('\n');

    for (String linea in lineas) {
      if (linea.trim().isEmpty) continue;

      int indexDosPuntos = linea.indexOf(':');
      if (indexDosPuntos == -1) continue;

      String nombreProducto = linea.substring(0, indexDosPuntos).trim();
      String resto = linea.substring(indexDosPuntos + 1).trim();

      List<String> partes = resto.split('x');
      if (partes.length < 2) continue;

      int cantidad = int.tryParse(partes[0].trim()) ?? 0;
      String precioStr = partes[1].trim();

      Producto? productoEncontrado = _todosLosProductos.firstWhere(
        (p) => p.nombre == nombreProducto,
        orElse: () => Producto(
          id: '0',
          nombre: nombreProducto,
          descripcion: '',
          imagen: 'assets/images/placeholder.png',
          stock: 0,
          precio: 0,
        ),
      );

      resultado.add({
        'producto': productoEncontrado,
        'cantidad': cantidad,
        'precioUnitario': productoEncontrado.precio,
        'precioTotal': cantidad * productoEncontrado.precio,
      });
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pedido: ${widget.pedido.id}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.pedido.usuario != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Cliente: ${widget.pedido.usuario}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Productos:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_cargandoProductos)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (productosEnPedido.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("No hay detalles de productos disponibles"),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productosEnPedido.length,
                    itemBuilder: (context, index) {
                      final item = productosEnPedido[index];
                      final producto = item['producto'] as Producto;
                      final cantidad = item['cantidad'] as int;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildProductImage(producto.imagen),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$cantidad x ${FormatUtils.formatPrice(producto.precio)}",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              FormatUtils.formatPrice(
                                  cantidad * producto.precio),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: ${FormatUtils.formatPrice(widget.pedido.total)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButton<String>(
                  value: widget.pedido.estado,
                  items: ["Pedido", "En Producción", "En Reparto", "Entregado"]
                      .map((estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.estadoIconos[estado],
                            color: widget.estadoColores[estado],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            estado,
                            style:
                                TextStyle(color: widget.estadoColores[estado]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (nuevoEstado) {
                    if (nuevoEstado != null &&
                        nuevoEstado != widget.pedido.estado) {
                      widget.onEstadoChanged(nuevoEstado);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 50);
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }

    if (imagePath.endsWith('.png') ||
        imagePath.endsWith('.jpg') ||
        imagePath.endsWith('.jpeg')) {
      String fullPath = 'assets/imagenes/$imagePath';
      return Image.asset(
        fullPath,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }

    return const Icon(Icons.image_not_supported, size: 50);
  }
}
