import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';
import '../utils/image_utils.dart';

class RegistroForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String selectedTrato;
  final Function(String?) onTratoChanged;
  final String? imagenPath;
  final VoidCallback onSelectImage;
  final TextEditingController edadController;
  final TextEditingController usuarioController;
  final TextEditingController contrasenaController;
  final TextEditingController repiteContrasenaController;
  final String? selectedCapital;
  final Function(String?) onCapitalChanged;
  final bool aceptaTerminos;
  final Function(bool?) onTerminosChanged;
  final List<String> capitales;
  final TextEditingController nombreController;
  final TextEditingController apellidosController;
  final Function(BuildContext)? onRegistroExitoso;

  const RegistroForm({
    super.key,
    required this.formKey,
    required this.selectedTrato,
    required this.onTratoChanged,
    required this.imagenPath,
    required this.onSelectImage,
    required this.edadController,
    required this.usuarioController,
    required this.contrasenaController,
    required this.repiteContrasenaController,
    required this.selectedCapital,
    required this.onCapitalChanged,
    required this.aceptaTerminos,
    required this.onTerminosChanged,
    required this.capitales,
    required this.nombreController,
    required this.apellidosController,
    this.onRegistroExitoso,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text("Trato: "),
              Radio<String>(
                value: "Sr.",
                groupValue: selectedTrato,
                onChanged: onTratoChanged,
              ),
              const Text("Sr."),
              Radio<String>(
                value: "Sra.",
                groupValue: selectedTrato,
                onChanged: onTratoChanged,
              ),
              const Text("Sra."),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (imagenPath != null)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: ImageUtils.getImageProvider(imagenPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Imagen de perfil:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      imagenPath != null
                          ? imagenPath!.length > 30
                              ? "Imagen seleccionada"
                              : imagenPath!
                          : "No se ha seleccionado imagen",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            ImageUtils.validateImageFormat(imagenPath) != null
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSelectImage,
                icon: const Icon(Icons.image),
                tooltip: "Seleccionar imagen",
              ),
            ],
          ),
          if (ImageUtils.validateImageFormat(imagenPath) != null)
            Text(
              ImageUtils.validateImageFormat(imagenPath)!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          const SizedBox(height: 8),
          TextFormField(
            controller: usuarioController,
            decoration: const InputDecoration(
              labelText: "Usuario",
              border: OutlineInputBorder(),
            ),
            validator: (value) => ValidationUtils.validateUsername(value),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: contrasenaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Contraseña",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo obligatorio";
              if (value.length < 6) return "Mínimo 6 caracteres";
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: repiteContrasenaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Repite Contraseña",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo obligatorio";
              if (value != contrasenaController.text) {
                return "Las contraseñas no coinciden";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: edadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Edad",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo obligatorio";
              int? edad = int.tryParse(value);
              if (edad == null) return "Debe ser un número";
              if (edad <= 0) return "La edad debe ser positiva";
              if (edad > 120) return "Edad no válida";
              return null;
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedCapital,
            decoration: const InputDecoration(
              labelText: "Lugar de Nacimiento",
              border: OutlineInputBorder(),
            ),
            items: capitales.map((cap) {
              return DropdownMenuItem(
                value: cap,
                child: Text(cap),
              );
            }).toList(),
            onChanged: onCapitalChanged,
            validator: (value) =>
                (value == null || value.isEmpty) ? "Campo obligatorio" : null,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text("Acepto los Términos y Condiciones"),
            value: aceptaTerminos,
            onChanged: onTerminosChanged,
          ),
        ],
      ),
    );
  }
}
