import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../utils/constants_utils.dart';
import '../utils/format_utils.dart';

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

class _PedidoListItemState extends State<PedidoListItem> {
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
      // Obtener todos los productos
      _todosLosProductos = await ProductoService.obtenerTodosProductos();
      // Parsear los detalles del pedido
      productosEnPedido = _parsearDetallesPedido(widget.pedido.detallesPedido);
    } catch (e) {
      print('Error al cargar productos: $e');
    } finally {
      setState(() {
        _cargandoProductos = false;
      });
    }
  }

  // Método para parsear los detalles del pedido y extraer productos, cantidades y precios
  List<Map<String, dynamic>> _parsearDetallesPedido(String detalles) {
    List<Map<String, dynamic>> resultado = [];

    // Dividir por líneas
    List<String> lineas = detalles.split('\n');

    for (String linea in lineas) {
      if (linea.trim().isEmpty) continue;

      // Formato esperado: "Nombre Producto: cantidad x precio"
      int indexDosPuntos = linea.indexOf(':');
      if (indexDosPuntos == -1) continue;

      String nombreProducto = linea.substring(0, indexDosPuntos).trim();
      String resto = linea.substring(indexDosPuntos + 1).trim();

      // Extraer cantidad y precio
      List<String> partes = resto.split('x');
      if (partes.length < 2) continue;

      int cantidad = int.tryParse(partes[0].trim()) ?? 0;
      String precioStr = partes[1].trim();

      // Buscar el producto en la lista de todos los productos
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

      // Depuración
      print(
          'Producto encontrado: ${productoEncontrado.nombre}, Imagen: ${productoEncontrado.imagen}');

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pedido: ${widget.pedido.id}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                    tooltip: "Eliminar pedido",
                  ),
              ],
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

            // Listado de productos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Productos:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                // Lista de productos
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
                            // Imagen del producto
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildProductImage(producto.imagen),
                            ),
                            const SizedBox(width: 12),
                            // Detalles del producto
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
                            // Precio total
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
    // Verificar si el estado actual existe en las constantes
    final String estadoActual = _getEstadoValido(widget.pedido.estado);

    print("Estado actual: $estadoActual");
    print("Estado original: ${widget.pedido.estado}");
    print("Estados disponibles: ${Constants.estadoIconos.keys.toList()}");

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
    // Verificar si el estado actual existe en las constantes
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

  // Método para obtener un estado válido que exista en Constants.estadoIconos
  String _getEstadoValido(String estadoOriginal) {
    // Normalizar el estado para comparación (eliminar tildes y convertir a minúsculas)
    String estadoNormalizado = _normalizarTexto(estadoOriginal);

    // Revisar cada clave en el mapa de estados
    for (String estado in Constants.estadoIconos.keys) {
      if (_normalizarTexto(estado) == estadoNormalizado) {
        return estado; // Devolver la clave original con el formato correcto
      }
    }

    // Manejar casos especiales
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

    // Si no se encuentra ninguna coincidencia, devolver el primer estado disponible
    return Constants.estadoIconos.keys.first;
  }

  // Método para normalizar texto (eliminar tildes y convertir a minúsculas)
  String _normalizarTexto(String texto) {
    if (texto.isEmpty) return '';

    // Convertir a minúsculas
    String normalizado = texto.toLowerCase();

    // Reemplazar tildes
    normalizado = normalizado
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');

    // Eliminar espacios
    normalizado = normalizado.replaceAll(' ', '');

    return normalizado;
  }

  // Método para construir la imagen del producto
  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 40);
    }

    // Verificar si la ruta es una URL completa
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          print('Error cargando imagen de red: $error');
          return const Icon(Icons.broken_image, size: 40);
        },
      );
    }

    // Verificar si es un asset completo
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          print('Error cargando asset: $error');
          return const Icon(Icons.broken_image, size: 40);
        },
      );
    }

    // Si solo tenemos el nombre del archivo (como 'prod1.png'), asumimos que está en assets/imagenes/
    if (imagePath.endsWith('.png') ||
        imagePath.endsWith('.jpg') ||
        imagePath.endsWith('.jpeg')) {
      String fullPath = 'assets/imagenes/$imagePath';
      print('Intentando cargar imagen desde: $fullPath');
      return Image.asset(
        fullPath,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          print(
              'Error cargando imagen con ruta construida ($fullPath): $error');
          return const Icon(Icons.broken_image, size: 40);
        },
      );
    }

    // En cualquier otro caso
    return const Icon(Icons.image_not_supported, size: 40);
  }
}
