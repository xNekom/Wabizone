import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/editar_usuario_form.dart';

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
      appBar: AppBar(title: const Text("Editar Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: EditarUsuarioForm(
          formKey: _formKey,
          edadController: _edadController,
          lugarController: _lugarController,
          contrasenaController: _contrasenaController,
          onGuardar: _guardarCambios,
        ),
      ),
    );
  }
}
