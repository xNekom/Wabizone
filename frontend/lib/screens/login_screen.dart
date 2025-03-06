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
import 'package:provider/provider.dart';
import '../providers/usuario_provider.dart';
import '../providers/carrito_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final usuarioProvider =
            Provider.of<UsuarioProvider>(context, listen: false);

        final success = await usuarioProvider.login(
            _usuarioController.text, _contrasenaController.text);

        if (!mounted) return;

        if (success) {
          final carritoProvider =
              Provider.of<CarritoProvider>(context, listen: false);
          if (usuarioProvider.usuarioActual != null) {
            await carritoProvider.transferCartToUser(
                int.parse(usuarioProvider.usuarioActual!.id!));
          }

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          final errorMsg = usuarioProvider.error.toLowerCase();

          if (errorMsg.contains('baneado') ||
              errorMsg.contains('bloqueado') ||
              errorMsg.contains('403') ||
              errorMsg.contains('forbidden')) {
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Cuenta bloqueada'),
                  ],
                ),
                content: Text(
                  'Has sido baneado, por favor contacta con un administrador',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    child: Text('Aceptar'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(usuarioProvider.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    return Consumer<UsuarioProvider>(
      builder: (context, usuarioProvider, child) {
        if (usuarioProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (usuarioProvider.isAdmin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminHomeScreen(
                        usuario: usuarioProvider.usuarioActual!)),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen(usuario: usuarioProvider.usuarioActual!)),
              );
            }
          });
        }

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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                                onPressed: _login,
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
      },
    );
  }
}
