import 'package:flutter/material.dart';
import '../utils/constants_utils.dart';
import '../widgets/contact_item.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacto y Ayuda"),
        backgroundColor: Constants.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Información de Contacto",
              style: TextStyle(
                fontSize: 24,
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
                subtitle: "+34 123 456 789",
                actionText: "Llamar ahora",
              ),
            ),
            InkWell(
              onTap: _launchEmail,
              child: const ContactItem(
                icon: Icons.email,
                title: "Email",
                subtitle: "soporte@wabizone.com",
                actionText: "Enviar correo",
              ),
            ),
            InkWell(
              onTap: () => _launchURL("https://www.wabizone.com"),
              child: const ContactItem(
                icon: Icons.web,
                title: "Sitio Web",
                subtitle: "www.wabizone.com",
                actionText: "Visitar web",
              ),
            ),
            InkWell(
              onTap: _launchMaps,
              child: const ContactItem(
                icon: Icons.location_on,
                title: "Dirección",
                subtitle: "Calle Principal 123, Madrid",
                actionText: "Ver en mapa",
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Redes Sociales",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, size: 40),
                  color: Colors.blue,
                  onPressed: () =>
                      _launchURL("https://www.facebook.com/wabizone"),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 40),
                  color: Colors.purple,
                  onPressed: () =>
                      _launchURL("https://www.instagram.com/wabizone"),
                ),
                IconButton(
                  icon: const Icon(Icons.message, size: 40),
                  color: Colors.lightBlue,
                  onPressed: () =>
                      _launchURL("https://www.twitter.com/wabizone"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Horario de Atención",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text("Lunes a Viernes: 9:00 - 20:00"),
            const Text("Sábados: 10:00 - 14:00"),
            const Text("Domingos: Cerrado"),
            const SizedBox(height: 24),
            Text(
              "Sobre Nosotros",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Wabizone es una tienda especializada en productos de alta calidad. "
              "Nuestro compromiso es ofrecer la mejor experiencia de compra a nuestros clientes, "
              "con productos seleccionados cuidadosamente y un servicio de atención personalizado.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            Text(
              "Nuestra Ubicación",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _launchMaps,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/imagenes/mapa.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.location_on,
                    color: Constants.primaryColor,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
