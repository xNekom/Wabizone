import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usuarioController;
  final TextEditingController contrasenaController;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.usuarioController,
    required this.contrasenaController,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Image.asset("assets/imagenes/logo.png", height: 150),
          const SizedBox(height: 16),
          TextFormField(
            controller: usuarioController,
            decoration: const InputDecoration(
              labelText: "Usuario",
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? "Campo obligatorio" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: contrasenaController,
            decoration: const InputDecoration(
              labelText: "Contraseña",
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) =>
                (value == null || value.isEmpty) ? "Campo obligatorio" : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Iniciar Sesión"),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onForgotPassword,
            child: const Text("¿Olvidaste tu contraseña?"),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRegister,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Registro"),
          ),
        ],
      ),
    );
  }
}
