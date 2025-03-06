import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/button_styles.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';
import 'package:provider/provider.dart';
import '../providers/usuario_provider.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Usuario usuario;
  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _edadController;
  late TextEditingController _contrasenaController;
  late TextEditingController _confirmarContrasenaController;
  String _lugarSeleccionado = '';

  @override
  void initState() {
    super.initState();
    _edadController =
        TextEditingController(text: widget.usuario.edad.toString());
    _contrasenaController =
        TextEditingController(text: widget.usuario.contrasena);
    _confirmarContrasenaController =
        TextEditingController(text: widget.usuario.contrasena);
    _lugarSeleccionado = widget.usuario.lugarNacimiento;
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      final usuarioActualizado = Usuario(
        id: widget.usuario.id,
        trato: widget.usuario.trato,
        imagen: widget.usuario.imagen,
        edad: int.parse(_edadController.text),
        usuario: widget.usuario.usuario,
        contrasena: _contrasenaController.text,
        lugarNacimiento: _lugarSeleccionado,
        bloqueado: widget.usuario.bloqueado,
        esAdmin: widget.usuario.esAdmin,
      );

      final usuarioProvider =
          Provider.of<UsuarioProvider>(context, listen: false);

      int userId = 0;
      try {
        userId = int.parse(widget.usuario.id ?? "0");
      } catch (e) {
        String numericString =
            widget.usuario.usuario.replaceAll(RegExp(r'[^0-9]'), '');
        userId = numericString.isEmpty ? 0 : int.parse(numericString);
      }

      usuarioProvider
          .actualizarUsuario(usuarioActualizado, userId)
          .then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Usuario actualizado")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${usuarioProvider.error}")));
        }
      });
    }
  }

  @override
  void dispose() {
    _edadController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Editar Usuario", style: TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  String? newPath = await ImageUtils.pickImage();
                  if (newPath != null) {
                    setState(() {
                      widget.usuario.imagen = newPath;
                    });
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withValues(
                          red: Constants.primaryColor.r.toDouble(),
                          green: Constants.primaryColor.g.toDouble(),
                          blue: Constants.primaryColor.b.toDouble(),
                          alpha: (0.3 * 255).toDouble(),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: widget.usuario.imagen.isEmpty
                          ? Icon(Icons.person,
                              size: 80, color: Constants.primaryColor)
                          : ClipOval(
                              child: Image(
                                image: ImageUtils.getImageProvider(
                                    widget.usuario.imagen),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Constants.primaryColor,
                        radius: 18,
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Edad",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.primaryColor),
                  ),
                  labelStyle: TextStyle(color: Constants.primaryColor),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obligatorio";
                  }
                  int? edad = int.tryParse(value);
                  if (edad == null || edad < 0 || edad > 120) {
                    return "Edad inválida";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _lugarSeleccionado.isEmpty
                    ? Constants.capitales.first
                    : (_lugarSeleccionado),
                decoration: InputDecoration(
                  labelText: "Lugar de Nacimiento",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.primaryColor),
                  ),
                  labelStyle: TextStyle(color: Constants.primaryColor),
                ),
                items: Constants.capitales.map((String capital) {
                  return DropdownMenuItem<String>(
                    value: capital,
                    child: Text(capital),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _lugarSeleccionado = newValue;
                    });
                  }
                },
                validator: (value) => (value == null || value.isEmpty)
                    ? "Campo obligatorio"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.primaryColor),
                  ),
                  labelStyle: TextStyle(color: Constants.primaryColor),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Campo obligatorio"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarContrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmar Contraseña",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.primaryColor),
                  ),
                  labelStyle: TextStyle(color: Constants.primaryColor),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obligatorio";
                  }
                  if (value != _contrasenaController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarCambios,
                style: estiloBoton(),
                child: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
