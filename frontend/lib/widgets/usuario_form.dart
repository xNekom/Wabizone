import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/validation_utils.dart';
import '../utils/image_utils.dart';

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
  });

  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  @override
  Widget build(BuildContext context) {
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
        ),
        TextFormField(
          controller: widget.usuarioController,
          decoration: const InputDecoration(labelText: "Usuario"),
          enabled: !widget.isEditing,
          validator: ValidationUtils.validateRequired,
        ),
        TextFormField(
          controller: widget.contrasenaController,
          decoration: const InputDecoration(labelText: "Contraseña"),
          obscureText: true,
          validator: ValidationUtils.validatePassword,
        ),
        TextFormField(
          controller: widget.edadController,
          decoration: const InputDecoration(labelText: "Edad"),
          keyboardType: TextInputType.number,
          validator: ValidationUtils.validateAge,
        ),
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
        CheckboxListTile(
          title: const Text("Es Administrador"),
          value: widget.esAdmin,
          onChanged: widget.onAdminChanged,
        ),
      ],
    );
  }
}
