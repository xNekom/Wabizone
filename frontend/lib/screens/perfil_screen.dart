import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';

class PerfilScreen extends StatelessWidget {
  final Usuario? usuario;
  const PerfilScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    if (usuario == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
        ),
        body: const Center(child: Text('No hay datos de usuario')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundImage: ImageUtils.getImageProvider(usuario!.imagen),
                  backgroundColor: Constants.primaryColor.withOpacity(0.2),
                  child: usuario!.imagen.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 100,
                          color: Constants.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Trato: ${usuario!.trato}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Edad: ${usuario!.edad}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Usuario: ${usuario!.usuario}',
                                style: const TextStyle(fontSize: 18)),
                            if (usuario!.esAdmin) const SizedBox(width: 4),
                            if (usuario!.esAdmin) Constants.adminBadge,
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Lugar de Nacimiento: ${usuario!.lugarNacimiento}',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
