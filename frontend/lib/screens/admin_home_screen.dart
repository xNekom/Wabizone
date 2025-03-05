import 'dart:io';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/drawer_general.dart';
import '../utils/constants_utils.dart';
import 'login_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'gestion_productos_screen.dart';
import 'gestion_pedidos_screen.dart';
import 'package:provider/provider.dart';
import '../providers/usuario_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  final Usuario usuario;
  const AdminHomeScreen({super.key, required this.usuario});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  void _cerrarSesion() {
    // Llama a logout del provider para limpiar el estado
    Provider.of<UsuarioProvider>(context, listen: false).logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _salir() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido ${widget.usuario.usuario}",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: DrawerGeneral(
        onCerrarSesion: _cerrarSesion,
        onSalir: _salir,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                ),
                icon: const Icon(Icons.person, color: Colors.white),
                label: const Text("Gestión de Usuarios",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GestionUsuariosScreen(adminActual: widget.usuario)),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                ),
                icon: const Icon(Icons.inventory, color: Colors.white),
                label: const Text("Gestión de Productos",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GestionProductosScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                ),
                icon: const Icon(Icons.list, color: Colors.white),
                label: const Text("Gestión de Pedidos",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GestionPedidosScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
