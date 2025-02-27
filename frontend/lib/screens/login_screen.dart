import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';
import '../utils/validation_utils.dart';
import '../utils/dialog_utils.dart';
import '../utils/constants_utils.dart';
import '../utils/button_styles.dart';
import 'registro_dialog.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String usuario = _usuarioController.text;
      String contrasena = _contrasenaController.text;

      try {
        String? mensajeError =
            await UsuarioService.validarUsuario(usuario, contrasena);
        if (!mounted) return;

        if (mensajeError != null) {
          DialogUtils.showSnackBar(context, mensajeError,
              color: Constants.errorColor);
          setState(() {
            _isLoading = false;
          });
          return;
        }

        Usuario? user = await UsuarioService.buscarUsuario(usuario, contrasena);
        if (!mounted) return;

        if (user != null) {
          if (user.esAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminHomeScreen(usuario: user)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(usuario: user)),
            );
          }
        }
      } catch (e) {
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

  Future<void> _olvidasteContrasena() async {
    TextEditingController nombreUsuarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recuperar contraseña"),
        content: TextField(
          controller: nombreUsuarioController,
          decoration: const InputDecoration(
            labelText: "Usuario",
            labelStyle: TextStyle(color: Colors.black),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              String nombre = nombreUsuarioController.text;
              final dialogContext = context;

              try {
                Navigator.pop(dialogContext);
                DialogUtils.showLoadingSpinner(context);
                Usuario? user =
                    await UsuarioService.buscarUsuarioPorNombre(nombre);
                if (!mounted) return;

                Navigator.pop(context);

                String mensaje = (user != null)
                    ? "La contraseña es: ${user.contrasena}"
                    : "Usuario no encontrado";

                DialogUtils.showSnackBar(context, mensaje,
                    color: user != null
                        ? Constants.successColor
                        : Constants.errorColor);
              } catch (e) {
                if (!mounted) return;

                Navigator.pop(context);
                DialogUtils.showSnackBar(
                    context, "Error al buscar usuario: ${e.toString()}",
                    color: Constants.errorColor);
              }
            },
            style: estiloBoton(),
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio de Sesión",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset("assets/imagenes/logo.png", height: 150),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usuarioController,
                      decoration: const InputDecoration(
                        labelText: "Usuario",
                        border: OutlineInputBorder(),
                      ),
                      validator: ValidationUtils.validateRequired,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contrasenaController,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: ValidationUtils.validateRequired,
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _iniciarSesion,
                            style: estiloBoton(),
                            child: const Text("Iniciar Sesión"),
                          ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _olvidasteContrasena,
                      style: TextButton.styleFrom(
                        foregroundColor: Constants.primaryColor,
                      ),
                      child: const Text("¿Olvidaste tu contraseña?"),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => const RegistroDialog(),
                      ),
                      style: estiloBoton(),
                      child: const Text("Registro"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
