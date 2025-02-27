import 'package:flutter/material.dart';
import '../services/pedido_service.dart';
import '../models/pedido.dart';
import '../utils/dialog_utils.dart';
import '../utils/constants_utils.dart';
import '../widgets/pedido_list_item.dart';

class GestionPedidosScreen extends StatefulWidget {
  const GestionPedidosScreen({super.key});

  @override
  _GestionPedidosScreenState createState() => _GestionPedidosScreenState();
}

class _GestionPedidosScreenState extends State<GestionPedidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _pedidosFuture = PedidoService.obtenerTodosPedidos();
    });
  }

  // Método para confirmar y eliminar un pedido
  Future<void> _confirmAndDeletePedido(Pedido pedido) async {
    // Mostrar diálogo de confirmación
    bool? confirmado = await DialogUtils.showConfirmDialog(
      context: context,
      title: "Confirmar eliminación",
      content:
          "¿Está seguro de que desea eliminar el pedido ${pedido.id}? Esta acción no se puede deshacer.",
    );

    if (confirmado != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Mostrar spinner de carga
      await DialogUtils.showLoadingSpinner(context);

      // Eliminar el pedido
      bool resultado = await PedidoService.eliminarPedido(pedido.id);

      // Cerrar el spinner
      Navigator.pop(context);

      // Recargar los pedidos
      await _cargarPedidos();

      // Mostrar mensaje de éxito o error
      if (resultado) {
        DialogUtils.showSnackBar(
          context,
          "Pedido eliminado correctamente",
          color: Constants.successColor,
        );
      } else {
        DialogUtils.showSnackBar(
          context,
          "Error al eliminar el pedido",
          color: Constants.errorColor,
        );
      }
    } catch (e) {
      // Cerrar spinner en caso de error
      Navigator.pop(context);
      DialogUtils.showSnackBar(
        context,
        "Error al eliminar el pedido: $e",
        color: Constants.errorColor,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndChangeEstado(
      Pedido pedido, String? nuevoEstado) async {
    if (nuevoEstado == null) return;

    // Imprimir para depuración
    print('Cambio de estado solicitado:');
    print('- Estado actual: ${pedido.estado}');
    print('- Nuevo estado: $nuevoEstado');

    bool? confirmado = await DialogUtils.showConfirmDialog(
        context: context,
        title: "Confirmar cambio de estado",
        content:
            "¿Está seguro de cambiar el estado del pedido a '$nuevoEstado'?");

    if (confirmado != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Mostrar spinner de carga
      await DialogUtils.showLoadingSpinner(context);

      // Actualizar estado del pedido
      pedido.estadoPedido = nuevoEstado;

      // Imprimir para depuración
      print('Estado actualizado en el objeto pedido: ${pedido.estadoPedido}');

      // Actualizar el pedido en la base de datos
      bool resultado = await PedidoService.actualizarPedido(pedido, pedido.id);

      // Imprimir para depuración
      print('Resultado de actualización: $resultado');

      // Cerrar el spinner
      Navigator.pop(context);

      // Recargar los pedidos
      await _cargarPedidos();

      // Mostrar mensaje de éxito o error
      if (resultado) {
        DialogUtils.showSnackBar(context, "Estado actualizado a '$nuevoEstado'",
            color:
                Constants.estadoColores[nuevoEstado] ?? Constants.successColor);
      } else {
        DialogUtils.showSnackBar(context, "Error al actualizar estado",
            color: Constants.errorColor);
      }
    } catch (e) {
      // Cerrar spinner en caso de error
      Navigator.pop(context);
      DialogUtils.showSnackBar(context, "Error al actualizar el estado: $e",
          color: Constants.errorColor);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Pedidos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Pedido>>(
            future: _pedidosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error al cargar pedidos: ${snapshot.error}",
                        style: const TextStyle(color: Constants.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarPedidos,
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No hay pedidos disponibles"),
                );
              } else {
                final pedidos = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _cargarPedidos,
                  child: ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      Pedido pedido = pedidos[index];
                      return PedidoListItem(
                        pedido: pedido,
                        onEstadoChanged: (nuevoEstado) {
                          if (nuevoEstado != null &&
                              nuevoEstado != pedido.estado) {
                            _confirmAndChangeEstado(pedido, nuevoEstado);
                          }
                        },
                        onDelete: () => _confirmAndDeletePedido(pedido),
                      );
                    },
                  ),
                );
              }
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
