import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';
import '../utils/button_styles.dart';
import '../utils/validation_utils.dart';
import '../utils/dialog_utils.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';
import '../widgets/usuario_form.dart';

class GestionUsuariosScreen extends StatefulWidget {
  final Usuario adminActual;
  const GestionUsuariosScreen({super.key, required this.adminActual});

  @override
  _GestionUsuariosScreenState createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Usuario>> _usuariosFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _usuariosFuture = UsuarioService.obtenerTodosUsuarios();
    });
  }

  void _crearUsuario() async {
    TextEditingController usuarioController = TextEditingController();
    TextEditingController contrasenaController = TextEditingController();
    TextEditingController edadController = TextEditingController();
    String selectedTrato = "Sr.";
    String? imagenPath;
    bool esAdmin = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Usuario"),
            content: SingleChildScrollView(
              child: UsuarioForm(
                isEditing: false,
                usuarioController: usuarioController,
                contrasenaController: contrasenaController,
                edadController: edadController,
                selectedTrato: selectedTrato,
                imagenPath: imagenPath,
                esAdmin: esAdmin,
                onTratoChanged: (value) =>
                    setDialogState(() => selectedTrato = value!),
                onImagenChanged: (value) =>
                    setDialogState(() => imagenPath = value),
                onAdminChanged: (value) =>
                    setDialogState(() => esAdmin = value!),
                onSave: (usuario) {},
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: estiloBoton(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    String? errorUsuario = ValidationUtils.validateRequired(
                        usuarioController.text);
                    String? errorContrasena = ValidationUtils.validatePassword(
                        contrasenaController.text);
                    String? errorEdad =
                        ValidationUtils.validateAge(edadController.text);

                    if (errorUsuario != null) {
                      DialogUtils.showSnackBar(context, errorUsuario,
                          color: Constants.errorColor);
                      return;
                    }
                    if (errorContrasena != null) {
                      DialogUtils.showSnackBar(context, errorContrasena,
                          color: Constants.errorColor);
                      return;
                    }
                    if (errorEdad != null) {
                      DialogUtils.showSnackBar(context, errorEdad,
                          color: Constants.errorColor);
                      return;
                    }

                    // Mostrar spinner de carga
                    DialogUtils.showLoadingSpinner(dialogContext);

                    try {
                      Usuario nuevoUsuario = Usuario(
                        trato: selectedTrato,
                        imagen:
                            imagenPath ?? ImageUtils.getDefaultImage(esAdmin),
                        edad: int.parse(edadController.text),
                        usuario: usuarioController.text,
                        contrasena: contrasenaController.text,
                        lugarNacimiento: "Madrid",
                        esAdmin: esAdmin,
                      );

                      Map<String, dynamic> result =
                          await UsuarioService.agregarUsuario(nuevoUsuario);

                      // Cerrar diálogo de carga y de creación
                      Navigator.of(dialogContext).pop(); // Cierra el spinner
                      Navigator.of(dialogContext)
                          .pop(); // Cierra el diálogo de creación

                      // Recargar los usuarios
                      _cargarUsuarios();

                      // Mostrar mensaje de éxito o error
                      if (result['success']) {
                        DialogUtils.showSnackBar(context, result['message'],
                            color: Constants.successColor);
                      } else {
                        DialogUtils.showSnackBar(context, result['message'],
                            color: Constants.errorColor);
                      }
                    } catch (e) {
                      // Cerrar diálogo de carga en caso de error
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(); // Cierra el spinner
                      }
                      DialogUtils.showSnackBar(
                          context, "Error al crear usuario: $e",
                          color: Constants.errorColor);
                    }
                  }
                },
                style: estiloBoton(),
                child: const Text("Crear"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editarUsuario(Usuario usuario) async {
    final dialogFormKey =
        GlobalKey<FormState>(); // Nuevo formKey específico para el diálogo
    TextEditingController usuarioController =
        TextEditingController(text: usuario.usuario);
    TextEditingController contrasenaController =
        TextEditingController(text: usuario.contrasena);
    TextEditingController edadController =
        TextEditingController(text: usuario.edad.toString());
    String selectedTrato = usuario.trato;
    String? imagenPath = usuario.imagen;
    bool esAdmin = usuario.esAdmin;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Editar Usuario"),
            content: SingleChildScrollView(
              child: Form(
                // Agregar Form widget
                key: dialogFormKey, // Usar el nuevo formKey
                child: UsuarioForm(
                  usuario: usuario,
                  isEditing: true,
                  usuarioController: usuarioController,
                  contrasenaController: contrasenaController,
                  edadController: edadController,
                  selectedTrato: selectedTrato,
                  imagenPath: imagenPath,
                  esAdmin: esAdmin,
                  onTratoChanged: (value) =>
                      setDialogState(() => selectedTrato = value!),
                  onImagenChanged: (value) => setDialogState(() {
                    imagenPath = value;
                    debugPrint('Nueva imagen seleccionada: $value');
                  }),
                  onAdminChanged: (value) =>
                      setDialogState(() => esAdmin = value!),
                  onSave: (usuario) {},
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: estiloBoton(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (dialogFormKey.currentState?.validate() ?? false) {
                    String? errorContrasena = ValidationUtils.validatePassword(
                        contrasenaController.text);
                    String? errorEdad =
                        ValidationUtils.validateAge(edadController.text);

                    if (errorContrasena != null) {
                      DialogUtils.showSnackBar(context, errorContrasena,
                          color: Constants.errorColor);
                      return;
                    }
                    if (errorEdad != null) {
                      DialogUtils.showSnackBar(context, errorEdad,
                          color: Constants.errorColor);
                      return;
                    }

                    // Mostrar spinner de carga
                    DialogUtils.showLoadingSpinner(dialogContext);

                    try {
                      usuario.trato = selectedTrato;
                      usuario.contrasena = contrasenaController.text;
                      usuario.edad = int.parse(edadController.text);
                      usuario.imagen = imagenPath ?? '';
                      usuario.esAdmin = esAdmin;

                      await UsuarioService.actualizarUsuario(
                          usuario,
                          int.parse(usuario.usuario
                              .replaceAll(RegExp(r'[^0-9]'), '0')));

                      // Cerrar diálogo de edición
                      Navigator.of(dialogContext).pop(); // Cierra el spinner
                      Navigator.of(dialogContext)
                          .pop(); // Cierra el diálogo de edición

                      // Recargar los usuarios
                      _cargarUsuarios();

                      DialogUtils.showSnackBar(
                          context, "Usuario actualizado correctamente",
                          color: Constants.successColor);
                    } catch (e) {
                      // Cerrar diálogo de carga en caso de error
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(); // Cierra el spinner
                      }
                      DialogUtils.showSnackBar(
                          context, "Error al actualizar usuario: $e",
                          color: Constants.errorColor);
                    }
                  }
                },
                style: estiloBoton(),
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error al cargar usuarios: ${snapshot.error}",
                    style: const TextStyle(color: Constants.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarUsuarios,
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No hay usuarios disponibles"),
            );
          } else {
            List<Usuario> usuarios = snapshot.data!
                .where((u) =>
                    u.usuario != "admin" &&
                    u.usuario != widget.adminActual.usuario)
                .toList();

            if (usuarios.isEmpty) {
              return const Center(
                child: Text("No hay otros usuarios para gestionar"),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                Usuario user = usuarios[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: ImageUtils.getImageProvider(user.imagen),
                      backgroundColor: Colors.grey[200],
                    ),
                    title: Row(
                      children: [
                        Text(user.usuario),
                        if (user.esAdmin) const SizedBox(width: 4),
                        if (user.esAdmin) Constants.adminBadge,
                      ],
                    ),
                    subtitle: Text(
                        "${user.trato} - ${user.edad} años - ${user.lugarNacimiento}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editarUsuario(user),
                        ),
                        IconButton(
                          icon: Icon(
                            user.bloqueado ? Icons.lock : Icons.lock_open,
                            color: user.bloqueado ? Colors.red : Colors.green,
                          ),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              // Antes de cambiar el estado, buscar el usuario por nombre para obtener su ID
                              Usuario? usuarioActual =
                                  await UsuarioService.buscarUsuarioPorNombre(
                                      user.usuario);
                              if (usuarioActual != null) {
                                user.bloqueado = !user.bloqueado;
                                // Obtener el ID del backend (el que devuelve la búsqueda)
                                int userId =
                                    int.parse(usuarioActual.id.toString());

                                await UsuarioService.actualizarUsuario(
                                    user, userId);

                                // Recargar usuarios para asegurar datos actualizados
                                await _cargarUsuarios();

                                DialogUtils.showSnackBar(
                                    context,
                                    user.bloqueado
                                        ? "Usuario bloqueado"
                                        : "Usuario desbloqueado",
                                    color: user.bloqueado
                                        ? Constants.errorColor
                                        : Constants.successColor);
                              } else {
                                throw Exception(
                                    "No se pudo encontrar el usuario para actualizar");
                              }
                            } catch (e) {
                              DialogUtils.showSnackBar(
                                  context, "Error al actualizar usuario: $e",
                                  color: Constants.errorColor);
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirmar = await DialogUtils.showConfirmDialog(
                                context: context,
                                title: "Confirmar eliminación",
                                content:
                                    "¿Está seguro de eliminar a ${user.usuario}?");

                            if (confirmar == true) {
                              await DialogUtils.showLoadingSpinner(context);
                              try {
                                // Buscar el usuario por nombre para obtener su ID
                                Usuario? usuarioActual =
                                    await UsuarioService.buscarUsuarioPorNombre(
                                        user.usuario);
                                if (usuarioActual != null) {
                                  // Obtener el ID del backend (el que devuelve la búsqueda)
                                  int userId =
                                      int.parse(usuarioActual.id.toString());

                                  await UsuarioService.eliminarUsuario(userId);

                                  // Cerrar el spinner
                                  Navigator.pop(context);

                                  // Recargar usuarios
                                  _cargarUsuarios();

                                  DialogUtils.showSnackBar(context,
                                      "Usuario eliminado correctamente",
                                      color: Constants.successColor);
                                } else {
                                  // Cerrar el spinner
                                  Navigator.pop(context);
                                  throw Exception(
                                      "No se pudo encontrar el usuario para eliminar");
                                }
                              } catch (e) {
                                // Cerrar el spinner en caso de error
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                DialogUtils.showSnackBar(
                                    context, "Error al eliminar usuario: $e",
                                    color: Constants.errorColor);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearUsuario,
        backgroundColor: Constants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
