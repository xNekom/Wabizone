import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/button_styles.dart';
import 'editar_usuario_screen.dart';

class YoPage extends StatelessWidget {
  final Usuario usuario;
  final Function(int) onTabChange;

  const YoPage({
    super.key,
    required this.usuario,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => onTabChange(1),
            style: estiloBoton(),
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            label: const Text("Mis pedidos"),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditarUsuarioScreen(usuario: usuario)),
              );
            },
            style: estiloBoton(),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text("Editar usuario"),
          ),
        ],
      ),
    );
  }
}
