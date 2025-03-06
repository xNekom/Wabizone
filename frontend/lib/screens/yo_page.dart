import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/constants_utils.dart';
import '../widgets/contact_item.dart';
import 'editar_perfil_screen.dart';
import 'contacto_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/usuario_provider.dart';

class YoPage extends StatefulWidget {
  final Usuario usuario;
  final Function(int) onTabChange;

  const YoPage({super.key, required this.usuario, required this.onTabChange});

  @override
  State<YoPage> createState() => _YoPageState();
}

class _YoPageState extends State<YoPage> {
  late Usuario _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    if (usuarioProvider.usuarioActual != null) {
      _usuario = usuarioProvider.usuarioActual!;
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'No se pudo llamar a $phone';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Consulta desde la app&body=Hola, me gustaría consultar...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'No se pudo enviar email a $email';
    }
  }

  Future<void> _launchMaps(String address) async {
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {'api': '1', 'query': address},
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el mapa para $address';
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    if (usuarioProvider.usuarioActual != null &&
        usuarioProvider.usuarioActual!.id == _usuario.id) {
      _usuario = usuarioProvider.usuarioActual!;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Constants.primaryColor,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _usuario.imagen.isNotEmpty
                        ? MemoryImage(
                            Uri.parse(_usuario.imagen).data!.contentAsBytes())
                        : const AssetImage('assets/images/default_user.png')
                            as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _usuario.usuario,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_usuario.trato.isNotEmpty)
                    Text(
                      _usuario.trato,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final updatedUser = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditarPerfilScreen(usuario: _usuario),
                        ),
                      );

                      if (updatedUser != null) {
                        setState(() {
                          _usuario = updatedUser;
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Constants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de contacto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ContactItem(
                    icon: Icons.phone,
                    title: 'Teléfono',
                    subtitle: _usuario.telefono ?? 'No disponible',
                    onTap: _usuario.telefono != null
                        ? () => _launchPhone(_usuario.telefono!)
                        : null,
                  ),
                  ContactItem(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: _usuario.email ?? 'No disponible',
                    onTap: _usuario.email?.isNotEmpty == true
                        ? () => _launchEmail(_usuario.email!)
                        : null,
                  ),
                  ContactItem(
                    icon: Icons.location_on,
                    title: 'Lugar de nacimiento',
                    subtitle: _usuario.lugarNacimiento,
                    onTap: () => _launchMaps(_usuario.lugarNacimiento),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactoScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Contactar con soporte'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
