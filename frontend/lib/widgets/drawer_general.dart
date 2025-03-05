import 'package:flutter/material.dart';
import '../utils/constants_utils.dart';
import 'package:web/web.dart' as web;
import 'dart:io';

class DrawerGeneral extends StatelessWidget {
  final VoidCallback onCerrarSesion;
  final VoidCallback onSalir;
  final VoidCallback? onPerfil;

  const DrawerGeneral({
    super.key,
    required this.onCerrarSesion,
    required this.onSalir,
    this.onPerfil,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Constants.primaryColor,
            ),
            child: Image.asset('assets/imagenes/logo.png'),
          ),
          if (onPerfil != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: onPerfil,
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: onCerrarSesion,
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Salir'),
            onTap: () => _handleSalir(context),
          ),
        ],
      ),
    );
  }

  void _handleSalir(BuildContext context) {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        exit(0);
      } else {
        web.window.close();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, cierre esta pestaña manualmente'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, cierre la aplicación manualmente'),
        ),
      );
    }
  }
}
