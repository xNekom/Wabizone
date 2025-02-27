import 'package:flutter/material.dart';

class EditarUsuarioForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController edadController;
  final TextEditingController lugarController;
  final TextEditingController contrasenaController;
  final VoidCallback onGuardar;

  const EditarUsuarioForm({
    super.key,
    required this.formKey,
    required this.edadController,
    required this.lugarController,
    required this.contrasenaController,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: edadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: "Edad", border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo obligatorio";
              int? edad = int.tryParse(value);
              if (edad == null || edad < 0 || edad > 120) {
                return "Edad inválida";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: lugarController,
            decoration: const InputDecoration(
                labelText: "Lugar de Nacimiento", border: OutlineInputBorder()),
            validator: (value) =>
                (value == null || value.isEmpty) ? "Campo obligatorio" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: contrasenaController,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: "Contraseña", border: OutlineInputBorder()),
            validator: (value) =>
                (value == null || value.isEmpty) ? "Campo obligatorio" : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onGuardar,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Guardar cambios"),
          ),
        ],
      ),
    );
  }
}
