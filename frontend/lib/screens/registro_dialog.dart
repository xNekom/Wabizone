import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../providers/usuario_provider.dart';
import '../utils/dialog_utils.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';
import '../utils/button_styles.dart';
import '../widgets/registro_form.dart';

class RegistroDialog extends StatefulWidget {
  const RegistroDialog({super.key});

  @override
  _RegistroDialogState createState() => _RegistroDialogState();
}

class _RegistroDialogState extends State<RegistroDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTrato = "Sr.";
  String? _imagenPath;
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _repiteContrasenaController =
      TextEditingController();
  String? _selectedCapital = "A Coruña";
  bool _aceptaTerminos = false;
  bool _isLoading = false;

  Future<void> _registrar() async {
    print('Botón de Registro presionado');

    final isValid = _formKey.currentState!.validate();
    print('Formulario válido: $isValid');

    if (isValid) {
      if (!_aceptaTerminos) {
        DialogUtils.showSnackBar(
            context, "Debe aceptar los términos y condiciones",
            color: Constants.errorColor);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      print('Datos para registro:');
      print('Usuario: ${_usuarioController.text}');
      print('Edad: ${_edadController.text}');
      print('Trato: $_selectedTrato');
      print('Lugar: $_selectedCapital');

      Usuario nuevoUsuario = Usuario(
        trato: _selectedTrato,
        imagen: _imagenPath ?? ImageUtils.getDefaultImage(false),
        edad: int.parse(_edadController.text),
        usuario: _usuarioController.text,
        contrasena: _contrasenaController.text,
        lugarNacimiento: _selectedCapital ?? "Madrid",
        bloqueado: false,
        esAdmin: false,
      );

      try {
        final usuarioProvider =
            Provider.of<UsuarioProvider>(context, listen: false);
        print('Llamando a usuarioProvider.registrar...');
        final Map<String, dynamic> result =
            await usuarioProvider.registrar(nuevoUsuario);

        print('Resultado del registro: $result');

        if (!mounted) return;

        if (result['success']) {
          DialogUtils.showSnackBar(context, result['message'],
              color: Constants.successColor);
          Navigator.pop(context);
        } else {
          DialogUtils.showSnackBar(context, result['message'],
              color: Constants.errorColor);
        }
      } catch (e) {
        print('Error en registro: $e');
        if (!mounted) return;

        DialogUtils.showSnackBar(
            context, "Error al conectar con el servidor: ${e.toString()}",
            color: Constants.errorColor);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _edadController.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _repiteContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Registro de Usuario"),
      content: SingleChildScrollView(
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : RegistroForm(
                formKey: _formKey,
                selectedTrato: _selectedTrato,
                onTratoChanged: (value) =>
                    setState(() => _selectedTrato = value!),
                imagenPath: _imagenPath,
                onSelectImage: () async {
                  String? newPath = await ImageUtils.pickImage();
                  if (newPath != null) {
                    setState(() => _imagenPath = newPath);
                  }
                },
                edadController: _edadController,
                usuarioController: _usuarioController,
                contrasenaController: _contrasenaController,
                repiteContrasenaController: _repiteContrasenaController,
                selectedCapital: _selectedCapital,
                onCapitalChanged: (value) =>
                    setState(() => _selectedCapital = value),
                aceptaTerminos: _aceptaTerminos,
                onTerminosChanged: (value) =>
                    setState(() => _aceptaTerminos = value ?? false),
                capitales: Constants.capitales,
              ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: estiloBoton(),
          child: const Text("Cancelar"),
        ),
        _isLoading
            ? const SizedBox(
                width: 95,
                height: 36,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : ElevatedButton(
                onPressed: _registrar,
                style: estiloBoton(),
                child: const Text("Registrar"),
              ),
      ],
    );
  }
}
