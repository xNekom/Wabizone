import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../utils/constants_utils.dart';
import '../widgets/pedido_list_item.dart';

class PedidosPage extends StatefulWidget {
  final Usuario usuario;

  const PedidosPage({
    super.key,
    required this.usuario,
  });

  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allPedidos = await PedidoService.obtenerTodosPedidos();
      setState(() {
        _pedidos = allPedidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar pedidos: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
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
    }

    if (_pedidos.isEmpty) {
      return const Center(
        child: Text(
          "No hay pedidos realizados",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarPedidos,
      child: ListView.builder(
        itemCount: _pedidos.length,
        itemBuilder: (context, index) {
          Pedido pedido = _pedidos[index];
          return PedidoListItem(
            pedido: pedido,
          );
        },
      ),
    );
  }
}
