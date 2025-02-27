import 'package:flutter/material.dart';
import '../utils/constants_utils.dart';
import '../widgets/contact_item.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

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
            const ContactItem(
              icon: Icons.phone,
              title: "Teléfono",
              content: "+34 123 456 789",
            ),
            const ContactItem(
              icon: Icons.email,
              title: "Email",
              content: "soporte@tuapp.com",
            ),
            const ContactItem(
              icon: Icons.web,
              title: "Sitio Web",
              content: "www.tuapp.com",
            ),
            const ContactItem(
              icon: Icons.location_on,
              title: "Dirección",
              content: "Calle Principal 123, Ciudad",
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
          ],
        ),
      ),
    );
  }
}
