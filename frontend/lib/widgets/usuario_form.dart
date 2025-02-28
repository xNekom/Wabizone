import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/validation_utils.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';

class UsuarioForm extends StatefulWidget {
  final Usuario? usuario;
  final Function(Usuario) onSave;
  final bool isEditing;

  final TextEditingController usuarioController;
  final TextEditingController contrasenaController;
  final TextEditingController edadController;
  final String selectedTrato;
  final String? imagenPath;
  final bool esAdmin;
  final Function(String?) onTratoChanged;
  final Function(String?) onImagenChanged;
  final Function(bool?) onAdminChanged;
  final String? selectedLugarNacimiento;
  final Function(String?) onLugarNacimientoChanged;
  final bool bloqueado;
  final Function(bool?) onBloqueadoChanged;

  const UsuarioForm({
    super.key,
    this.usuario,
    required this.onSave,
    required this.isEditing,
    required this.usuarioController,
    required this.contrasenaController,
    required this.edadController,
    required this.selectedTrato,
    required this.imagenPath,
    required this.esAdmin,
    required this.onTratoChanged,
    required this.onImagenChanged,
    required this.onAdminChanged,
    this.selectedLugarNacimiento,
    required this.onLugarNacimientoChanged,
    this.bloqueado = false,
    required this.onBloqueadoChanged,
  });

  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  @override
  Widget build(BuildContext context) {
    print('Renderizando UsuarioForm - isEditing: ${widget.isEditing}');
    print('Usuario: ${widget.usuarioController.text}');
    print(
        'Contraseña: ${widget.contrasenaController.text.isNotEmpty ? '****' : 'vacía'}');
    print('Edad: ${widget.edadController.text}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          value: widget.selectedTrato,
          items: ["Sr.", "Sra."].map((trato) {
            return DropdownMenuItem(value: trato, child: Text(trato));
          }).toList(),
          onChanged: widget.onTratoChanged,
          decoration: const InputDecoration(labelText: "Trato"),
          validator: (value) {
            print('Validando trato: $value');
            return value == null || value.isEmpty
                ? 'El trato es obligatorio'
                : null;
          },
        ),
        TextFormField(
          controller: widget.usuarioController,
          decoration: const InputDecoration(labelText: "Usuario"),
          validator: (value) {
            print('Validando usuario: $value');
            return ValidationUtils.validateRequired(value);
          },
        ),
        TextFormField(
          controller: widget.contrasenaController,
          decoration: const InputDecoration(labelText: "Contraseña"),
          obscureText: true,
          validator: (value) {
            print('Validando contraseña: $value');
            return ValidationUtils.validatePassword(value);
          },
        ),
        TextFormField(
          controller: widget.edadController,
          decoration: const InputDecoration(labelText: "Edad"),
          keyboardType: TextInputType.number,
          validator: (value) {
            print('Validando edad: $value');
            return ValidationUtils.validateAge(value);
          },
        ),
        DropdownButtonFormField<String>(
          value: widget.selectedLugarNacimiento ?? "Madrid",
          items: Constants.capitales.map((capital) {
            return DropdownMenuItem(value: capital, child: Text(capital));
          }).toList(),
          onChanged: widget.onLugarNacimientoChanged,
          decoration: const InputDecoration(labelText: "Lugar de Nacimiento"),
          validator: (value) {
            return value == null || value.isEmpty
                ? 'El lugar de nacimiento es obligatorio'
                : null;
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.imagenPath ?? "No se ha seleccionado imagen",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () async {
                String? newPath = await ImageUtils.pickImage();
                if (newPath != null && mounted) {
                  widget.onImagenChanged(newPath);
                }
              },
              icon: const Icon(Icons.image),
            ),
            if (widget.imagenPath != null)
              IconButton(
                onPressed: () => widget.onImagenChanged(null),
                icon: const Icon(Icons.clear),
              ),
          ],
        ),
        const SizedBox(height: 10),
        CheckboxListTile(
          title: const Text("Es Administrador"),
          value: widget.esAdmin,
          onChanged: widget.onAdminChanged,
        ),
      ],
    );
  }
}
