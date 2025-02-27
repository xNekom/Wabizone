import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../utils/button_styles.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Usuario usuario;
  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  _EditarUsuarioScreenState createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _edadController;
  late TextEditingController _lugarController;
  late TextEditingController _contrasenaController;

  @override
  void initState() {
    super.initState();
    _edadController =
        TextEditingController(text: widget.usuario.edad.toString());
    _lugarController =
        TextEditingController(text: widget.usuario.lugarNacimiento);
    _contrasenaController =
        TextEditingController(text: widget.usuario.contrasena);
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        widget.usuario.edad = int.parse(_edadController.text);
        widget.usuario.lugarNacimiento = _lugarController.text;
        widget.usuario.contrasena = _contrasenaController.text;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Usuario actualizado")));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _edadController.dispose();
    _lugarController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Usuario", style: TextStyle(color: Colors.white)),
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
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: ImageUtils.getImageProvider(widget.usuario.imagen),
                      backgroundColor: Constants.primaryColor.withOpacity(0.3),
                      child: widget.usuario.imagen.isEmpty
                          ? Icon(Icons.person, size: 80, color: Constants.primaryColor)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Constants.primaryColor,
                        radius: 18,
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
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
              TextFormField(
                controller: _lugarController,
                decoration: InputDecoration(
                  labelText: "Lugar de Nacimiento",
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
