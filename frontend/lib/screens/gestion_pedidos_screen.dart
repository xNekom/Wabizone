import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedido_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PedidoProvider>(context, listen: false).obtenerTodosPedidos();
    });
  }

  Future<void> _confirmAndDeletePedido(Pedido pedido) async {
    bool? confirmado = await DialogUtils.showConfirmDialog(
      context: context,
      title: "Confirmar eliminación",
      content:
          "¿Está seguro de que desea eliminar el pedido ${pedido.nPedido}? Esta acción no se puede deshacer.",
    );

    if (confirmado != true) return;

    try {
      await DialogUtils.showLoadingSpinner(context);

      final pedidoProvider =
          Provider.of<PedidoProvider>(context, listen: false);

      bool resultado = await pedidoProvider.eliminarPedido(pedido.id);

      Navigator.pop(context);

      if (resultado) {
        DialogUtils.showSnackBar(
          context,
          "Pedido eliminado correctamente",
          color: Constants.successColor,
        );
      } else {
        DialogUtils.showSnackBar(
          context,
          pedidoProvider.error,
          color: Constants.errorColor,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      DialogUtils.showSnackBar(
        context,
        "Error al eliminar el pedido: $e",
        color: Constants.errorColor,
      );
    }
  }

  Future<void> _confirmAndChangeEstado(
      Pedido pedido, String? nuevoEstado) async {
    if (nuevoEstado == null) return;

    bool? confirmado = await DialogUtils.showConfirmDialog(
        context: context,
        title: "Confirmar cambio de estado",
        content:
            "¿Está seguro de cambiar el estado del pedido a '$nuevoEstado'?");

    if (confirmado != true) return;

    try {
      await DialogUtils.showLoadingSpinner(context);

      final pedidoProvider =
          Provider.of<PedidoProvider>(context, listen: false);

      bool resultado =
          await pedidoProvider.cambiarEstadoPedido(pedido.id, nuevoEstado);

      Navigator.pop(context);

      if (resultado) {
        DialogUtils.showSnackBar(context, "Estado actualizado a '$nuevoEstado'",
            color:
                Constants.estadoColores[nuevoEstado] ?? Constants.successColor);
      } else {
        DialogUtils.showSnackBar(context, pedidoProvider.error,
            color: Constants.errorColor);
      }
    } catch (e) {
      Navigator.pop(context);
      DialogUtils.showSnackBar(context, "Error al actualizar el estado: $e",
          color: Constants.errorColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Pedidos",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<PedidoProvider>(
        builder: (context, pedidoProvider, child) {
          if (pedidoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pedidoProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${pedidoProvider.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => pedidoProvider.obtenerTodosPedidos(),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            );
          }

          final pedidos = pedidoProvider.pedidos;

          if (pedidos.isEmpty) {
            return const Center(
              child: Text("No hay pedidos disponibles."),
            );
          }

          return RefreshIndicator(
            onRefresh: () => pedidoProvider.obtenerTodosPedidos(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return PedidoListItem(
                  pedido: pedido,
                  onEstadoChanged: (nuevoEstado) =>
                      _confirmAndChangeEstado(pedido, nuevoEstado),
                  onDelete: () => _confirmAndDeletePedido(pedido),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
