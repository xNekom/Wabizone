import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/button_styles.dart';
import '../utils/constants_utils.dart';
import '../widgets/contact_item.dart';
import 'editar_perfil_screen.dart';
import 'contacto_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class YoPage extends StatelessWidget {
  final Usuario usuario;
  final Function(int) onTabChange;

  const YoPage({
    super.key,
    required this.usuario,
    required this.onTabChange,
  });

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  Future<void> _launchMaps() async {
    const String googleMapsUrl =
        'https://maps.google.com/?q=40.416775,-3.703790';
    await _launchURL(googleMapsUrl);
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'soporte@wabizone.com',
      queryParameters: {
        'subject': 'Consulta desde la app',
      },
    );
    if (!await launchUrl(emailUri)) {
      throw Exception('No se pudo abrir el cliente de correo');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+34123456789',
    );
    if (!await launchUrl(phoneUri)) {
      throw Exception('No se pudo realizar la llamada');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    builder: (context) => EditarPerfilScreen(usuario: usuario)),
              );
            },
            style: estiloBoton(),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text("Editar perfil"),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Información de Contacto",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _launchPhone,
                    child: const ContactItem(
                      icon: Icons.phone,
                      title: "Teléfono",
                      content: "+34 123 456 789",
                      actionText: "Llamar ahora",
                    ),
                  ),
                  InkWell(
                    onTap: _launchEmail,
                    child: const ContactItem(
                      icon: Icons.email,
                      title: "Email",
                      content: "soporte@wabizone.com",
                      actionText: "Enviar correo",
                    ),
                  ),
                  InkWell(
                    onTap: () => _launchURL("https://www.wabizone.com"),
                    child: const ContactItem(
                      icon: Icons.web,
                      title: "Sitio Web",
                      content: "www.wabizone.com",
                      actionText: "Visitar web",
                    ),
                  ),
                  InkWell(
                    onTap: _launchMaps,
                    child: const ContactItem(
                      icon: Icons.location_on,
                      title: "Dirección",
                      content: "Calle Principal 123, Madrid",
                      actionText: "Ver en mapa",
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Más información'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Constants.primaryColor,
                side: BorderSide(color: Constants.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
