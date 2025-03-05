import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';
import 'editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario? usuario;
  const PerfilScreen({super.key, required this.usuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  Future<void> _editarPerfil() async {
    if (_usuario == null) return;

    final usuarioActualizado = await Navigator.push<Usuario>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilScreen(usuario: _usuario!),
      ),
    );

    if (usuarioActualizado != null) {
      setState(() {
        _usuario = usuarioActualizado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
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
        backgroundColor: Constants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editarPerfil,
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _usuario!.imagen.isNotEmpty
                  ? CircleAvatar(
                      radius: 75,
                      backgroundImage:
                          ImageUtils.getImageProvider(_usuario!.imagen),
                      backgroundColor: Constants.primaryColor.withOpacity(0.2),
                    )
                  : CircleAvatar(
                      radius: 75,
                      backgroundColor: Constants.primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Constants.primaryColor,
                      ),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _usuario!.usuario,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_usuario!.esAdmin) const SizedBox(width: 8),
                  if (_usuario!.esAdmin) Constants.adminBadge,
                ],
              ),
              const SizedBox(height: 24),
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
                      _buildInfoRow(
                          Icons.person_outline, 'Trato', _usuario!.trato),
                      const Divider(),
                      _buildInfoRow(
                          Icons.cake, 'Edad', _usuario!.edad.toString()),
                      const Divider(),
                      _buildInfoRow(Icons.location_city, 'Lugar de Nacimiento',
                          _usuario!.lugarNacimiento),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _editarPerfil,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Constants.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
