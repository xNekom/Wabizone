import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../providers/auth_provider.dart';
import '../services/usuario_service.dart';
import '../utils/constants_utils.dart';
import '../utils/image_utils.dart';
import '../widgets/custom_text_field.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuario;

  const EditarPerfilScreen({super.key, required this.usuario});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _tratoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _lugarNacimientoController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  String? _imagenBase64;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usuarioController.text = widget.usuario.usuario;
    _tratoController.text = widget.usuario.trato;
    _edadController.text = widget.usuario.edad.toString();
    _lugarNacimientoController.text = widget.usuario.lugarNacimiento;
    _emailController.text = widget.usuario.email ?? '';
    _telefonoController.text = widget.usuario.telefono ?? '';
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _tratoController.dispose();
    _edadController.dispose();
    _lugarNacimientoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imagen = await ImageUtils.pickImage(isForProfile: true);
      if (imagen != null) {
        setState(() {
          _imagenBase64 = imagen;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al seleccionar imagen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_usuarioController.text != widget.usuario.usuario) {
        final usuarioExistente = await UsuarioService.buscarUsuarioPorNombre(
            _usuarioController.text);
        if (usuarioExistente != null) {
          setState(() {
            _errorMessage = 'El nombre de usuario ya está en uso';
            _isLoading = false;
          });
          return;
        }
      }

      final usuarioActualizado = Usuario(
        id: widget.usuario.id,
        imagen: _imagenBase64 ?? widget.usuario.imagen,
        trato: _tratoController.text,
        edad: int.tryParse(_edadController.text) ?? widget.usuario.edad,
        usuario: _usuarioController.text,
        contrasena: widget.usuario.contrasena,
        lugarNacimiento: _lugarNacimientoController.text,
        bloqueado: widget.usuario.bloqueado,
        esAdmin: widget.usuario.esAdmin,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        telefono:
            _telefonoController.text.isEmpty ? null : _telefonoController.text,
      );

      final success = await UsuarioService.actualizarUsuario(
          usuarioActualizado, int.parse(widget.usuario.id ?? '0'));

      if (success) {
        if (context.mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          authProvider.actualizarUsuario(usuarioActualizado);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, usuarioActualizado);
        }
      } else {
        setState(() {
          _errorMessage = 'Error al actualizar el perfil';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Constants.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _selectImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _imagenBase64 != null
                                ? MemoryImage(ImageUtils.extractImageBytes(
                                    _imagenBase64!))
                                : ImageUtils.getImageProvider(
                                    widget.usuario.imagen),
                            backgroundColor: Constants.primaryColor.withValues(
                              red: Constants.primaryColor.r.toDouble(),
                              green: Constants.primaryColor.g.toDouble(),
                              blue: Constants.primaryColor.b.toDouble(),
                              alpha: (0.2 * 255).toDouble(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Constants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    CustomTextField(
                      controller: _usuarioController,
                      label: 'Nombre de Usuario',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre de usuario';
                        }
                        if (value.length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _tratoController,
                      label: 'Trato',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su trato';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _edadController,
                      label: 'Edad',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su edad';
                        }
                        final edad = int.tryParse(value);
                        if (edad == null || edad <= 0 || edad > 120) {
                          return 'Por favor ingrese una edad válida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _lugarNacimientoController,
                      label: 'Lugar de Nacimiento',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su lugar de nacimiento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Ingrese un email válido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 9) {
                            return 'Ingrese un número de teléfono válido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
