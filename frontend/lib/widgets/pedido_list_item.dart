import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/constants_utils.dart';
import '../utils/format_utils.dart';
import '../utils/image_utils.dart';

class PedidoListItem extends StatefulWidget {
  final Pedido pedido;
  final ValueChanged<String?>? onEstadoChanged;
  final VoidCallback? onDelete;

  const PedidoListItem({
    super.key,
    required this.pedido,
    this.onEstadoChanged,
    this.onDelete,
  });

  @override
  State<PedidoListItem> createState() => _PedidoListItemState();
}

class _PedidoListItemState extends State<PedidoListItem>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> productosEnPedido = [];
  bool _cargandoProductos = true;
  List<Producto> _todosLosProductos = [];
  bool _isExpanded = false;

  @override
  bool get wantKeepAlive => true;

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

      if (widget.pedido.detallesPedido.isNotEmpty) {
        productosEnPedido =
            _parsearDetallesPedido(widget.pedido.detallesPedido);
      }
    } catch (e) {
      // Se ignora la excepción y se continúa con la lista vacía de productos
    } finally {
      if (mounted) {
        setState(() {
          _cargandoProductos = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _parsearDetallesPedido(String detalles) {
    List<Map<String, dynamic>> resultado = [];

    try {
      if (detalles.isEmpty) {
        return resultado;
      }

      List<String> lineas = detalles.split('\n');
      bool productosEncontrados = false;

      for (String linea in lineas) {
        linea = linea.trim();
        if (linea.isEmpty) continue;

        if (linea == 'Productos:') {
          productosEncontrados = true;
          continue;
        }

        if (!productosEncontrados) continue;

        if (linea.startsWith('-')) {
          linea = linea.substring(1).trim();

          int indexDosPuntos = linea.indexOf(':');
          if (indexDosPuntos == -1) continue;

          String nombreProducto = linea.substring(0, indexDosPuntos).trim();
          String resto = linea.substring(indexDosPuntos + 1).trim();

          List<String> partes = resto.split('x');
          if (partes.length < 2) continue;

          int cantidad = int.tryParse(partes[0].trim()) ?? 0;
          if (cantidad <= 0) continue;

          String precioStr = partes[1].split('=')[0].trim();
          double precio = 0.0;

          try {
            precioStr =
                precioStr.replaceAll(' €', '').replaceAll('€', '').trim();
            precio = double.parse(precioStr);
          } catch (e) {
            continue;
          }

          Producto productoEncontrado;
          try {
            productoEncontrado = _todosLosProductos.firstWhere(
              (p) => p.nombre.toLowerCase() == nombreProducto.toLowerCase(),
              orElse: () => Producto(
                id: '0',
                nombre: nombreProducto,
                descripcion: 'Producto no encontrado en el catálogo',
                imagen: 'assets/imagenes/default_product.png',
                stock: 0,
                precio: precio,
              ),
            );
          } catch (e) {
            productoEncontrado = Producto(
              id: '0',
              nombre: nombreProducto,
              descripcion: 'Error al buscar producto',
              imagen: 'assets/imagenes/default_product.png',
              stock: 0,
              precio: precio,
            );
          }

          resultado.add({
            'producto': productoEncontrado,
            'cantidad': cantidad,
            'precioUnitario': productoEncontrado.precio,
            'precioTotal': cantidad * productoEncontrado.precio,
          });
        }
      }

      return resultado;
    } catch (e) {
      return resultado;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pedido #${widget.pedido.id}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (widget.pedido.nombreUsuario != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Usuario: ${widget.pedido.nombreUsuario}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                    tooltip: "Eliminar pedido",
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              initiallyExpanded: _isExpanded,
              maintainState: true,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded = expanded;
                });
              },
              title: Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Detalles del envío",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              children: [
                if (widget.pedido.nombreCompleto != null)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Datos del cliente:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            Icons.person, widget.pedido.nombreCompleto!),
                      ],
                    ),
                  ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Datos de envío:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.pedido.direccion != null)
                        _buildInfoRow(
                            Icons.location_on, widget.pedido.direccion!),
                      if (widget.pedido.ciudad != null)
                        _buildInfoRow(
                            Icons.location_city, widget.pedido.ciudad!),
                      if (widget.pedido.codigoPostal != null)
                        _buildInfoRow(Icons.local_post_office,
                            widget.pedido.codigoPostal!),
                      if (widget.pedido.telefono != null)
                        _buildInfoRow(Icons.phone, widget.pedido.telefono!),
                      if (widget.pedido.email != null)
                        _buildInfoRow(Icons.email, widget.pedido.email!),
                      if (widget.pedido.comentarios != null &&
                          widget.pedido.comentarios!.isNotEmpty)
                        _buildInfoRow(
                            Icons.comment, widget.pedido.comentarios!),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Total: ${FormatUtils.formatPrice(widget.pedido.total)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Productos:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                                    producto.precio * cantidad),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onEstadoChanged != null)
                  _buildEstadoDropdown(context)
                else
                  _buildEstadoText(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoDropdown(BuildContext context) {
    final String estadoActual = _getEstadoValido(widget.pedido.estado);

    return DropdownButton<String>(
      value: estadoActual,
      items: Constants.estadoIconos.keys.map((estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Constants.estadoIconos[estado] ?? Icons.error,
                color: Constants.estadoColores[estado] ?? Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                estado,
                style: TextStyle(
                    color: Constants.estadoColores[estado] ?? Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: widget.onEstadoChanged,
    );
  }

  Widget _buildEstadoText() {
    final String estadoActual = _getEstadoValido(widget.pedido.estado);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Constants.estadoIconos[estadoActual] ?? Icons.help_outline,
          color: Constants.estadoColores[estadoActual] ?? Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          estadoActual,
          style: TextStyle(
            color: Constants.estadoColores[estadoActual] ?? Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getEstadoValido(String estadoOriginal) {
    String estadoNormalizado = _normalizarTexto(estadoOriginal);

    for (String estado in Constants.estadoIconos.keys) {
      if (_normalizarTexto(estado) == estadoNormalizado) {
        return estado;
      }
    }

    if (estadoNormalizado == 'pendiente') {
      return 'Pedido';
    }

    if (estadoNormalizado == 'en produccion' ||
        estadoNormalizado == 'enproduccion') {
      return 'En Producción';
    }

    if (estadoNormalizado == 'en reparto' || estadoNormalizado == 'enreparto') {
      return 'En Reparto';
    }

    if (estadoNormalizado == 'entregado') {
      return 'Entregado';
    }

    return Constants.estadoIconos.keys.first;
  }

  String _normalizarTexto(String texto) {
    if (texto.isEmpty) return '';

    String normalizado = texto.toLowerCase();

    normalizado = normalizado
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');

    normalizado = normalizado.replaceAll(' ', '');

    return normalizado;
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _buildErrorImage();
    }

    // Extraer el ID del producto si es posible
    String productId = "";
    if (imagePath.startsWith('p') && imagePath.length < 5) {
      productId = imagePath.substring(1);
    } else if (imagePath.length == 1 && int.tryParse(imagePath) != null) {
      productId = imagePath;
    } else if (imagePath.contains('Producto ')) {
      final match = RegExp(r'Producto (\d+)').firstMatch(imagePath);
      if (match != null) {
        productId = match.group(1) ?? "";
      }
    }

    // Si tenemos un ID válido, mostrar la imagen correspondiente
    if (productId.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          'assets/imagenes/prod$productId.png',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorImage(),
        ),
      );
    }

    // Para otros tipos de imágenes
    if (imagePath.startsWith('data:image')) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            ImageUtils.extractImageBytes(imagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildErrorImage(),
          ),
        );
      } catch (e) {
        return _buildErrorImage();
      }
    }

    if (imagePath.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorImage(),
        ),
      );
    }

    if (imagePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorImage(),
        ),
      );
    }

    return _buildErrorImage();
  }

  Widget _buildErrorImage() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
