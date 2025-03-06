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
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      // Forzar recarga de la pantalla
    });
  }

  void _crearUsuario() async {
    final dialogFormKey = GlobalKey<FormState>();
    TextEditingController usuarioController = TextEditingController();
    TextEditingController contrasenaController = TextEditingController();
    TextEditingController edadController = TextEditingController();
    String selectedTrato = "Sr.";
    String? imagenPath;
    bool esAdmin = false;
    bool bloqueado = false;
    String selectedLugarNacimiento = "Madrid";

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Usuario"),
            content: SingleChildScrollView(
              child: Form(
                key: dialogFormKey,
                child: UsuarioForm(
                  isEditing: false,
                  usuarioController: usuarioController,
                  contrasenaController: contrasenaController,
                  edadController: edadController,
                  selectedTrato: selectedTrato,
                  imagenPath: imagenPath,
                  esAdmin: esAdmin,
                  bloqueado: bloqueado,
                  selectedLugarNacimiento: selectedLugarNacimiento,
                  onTratoChanged: (value) =>
                      setDialogState(() => selectedTrato = value!),
                  onImagenChanged: (value) =>
                      setDialogState(() => imagenPath = value),
                  onAdminChanged: (value) =>
                      setDialogState(() => esAdmin = value!),
                  onLugarNacimientoChanged: (value) =>
                      setDialogState(() => selectedLugarNacimiento = value!),
                  onBloqueadoChanged: (value) =>
                      setDialogState(() => bloqueado = value!),
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
                  if (dialogFormKey.currentState!.validate()) {
                    final BuildContext dialogContext = context;

                    DialogUtils.showLoadingSpinner(dialogContext);

                    try {
                      Usuario nuevoUsuario = Usuario(
                        trato: selectedTrato,
                        imagen:
                            imagenPath ?? ImageUtils.getDefaultImage(esAdmin),
                        edad: int.parse(edadController.text),
                        usuario: usuarioController.text,
                        contrasena: contrasenaController.text,
                        lugarNacimiento: selectedLugarNacimiento,
                        bloqueado: bloqueado,
                        esAdmin: esAdmin,
                      );

                      Map<String, dynamic> resultado =
                          await UsuarioService.agregarUsuario(nuevoUsuario);

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (resultado['success']) {
                        Navigator.of(dialogContext).pop();

                        DialogUtils.showSnackBar(context, resultado['message'],
                            color: Constants.successColor);

                        _cargarUsuarios();
                      } else {
                        DialogUtils.showSnackBar(context, resultado['message'],
                            color: Constants.errorColor);
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      DialogUtils.showSnackBar(
                          context, "Error al crear el usuario: $e",
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
    final dialogFormKey = GlobalKey<FormState>();
    TextEditingController usuarioController =
        TextEditingController(text: usuario.usuario);
    TextEditingController contrasenaController =
        TextEditingController(text: usuario.contrasena);
    TextEditingController edadController =
        TextEditingController(text: usuario.edad.toString());

    final String usuarioOriginal = usuario.usuario;

    String selectedTrato = usuario.trato.isEmpty ? "Sr." : usuario.trato;
    String? imagenPath = usuario.imagen;
    bool esAdmin = usuario.esAdmin;
    bool bloqueado = usuario.bloqueado;
    String lugarNacimiento =
        usuario.lugarNacimiento.isEmpty ? "Madrid" : usuario.lugarNacimiento;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Editar Usuario"),
            content: SingleChildScrollView(
              child: Form(
                key: dialogFormKey,
                child: UsuarioForm(
                  usuario: usuario,
                  isEditing: true,
                  usuarioController: usuarioController,
                  contrasenaController: contrasenaController,
                  edadController: edadController,
                  selectedTrato: selectedTrato,
                  imagenPath: imagenPath,
                  esAdmin: esAdmin,
                  bloqueado: bloqueado,
                  selectedLugarNacimiento: lugarNacimiento,
                  onTratoChanged: (value) =>
                      setDialogState(() => selectedTrato = value!),
                  onImagenChanged: (value) => setDialogState(() {
                    imagenPath = value;
                  }),
                  onAdminChanged: (value) =>
                      setDialogState(() => esAdmin = value!),
                  onLugarNacimientoChanged: (value) =>
                      setDialogState(() => lugarNacimiento = value!),
                  onBloqueadoChanged: (value) =>
                      setDialogState(() => bloqueado = value!),
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
                      DialogUtils.showSnackBar(dialogContext, errorContrasena,
                          color: Constants.errorColor);
                      return;
                    }
                    if (errorEdad != null) {
                      DialogUtils.showSnackBar(dialogContext, errorEdad,
                          color: Constants.errorColor);
                      return;
                    }

                    if (usuarioController.text != usuarioOriginal) {
                      DialogUtils.showLoadingSpinner(dialogContext);

                      try {
                        Usuario? usuarioExistente =
                            await UsuarioService.buscarUsuarioPorNombre(
                                usuarioController.text);

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        if (usuarioExistente != null) {
                          DialogUtils.showSnackBar(dialogContext,
                              "El nombre de usuario ya existe. Por favor, elija otro nombre.",
                              color: Constants.errorColor);
                          return;
                        }
                      } catch (e) {
                        if (e.toString().contains('404') ||
                            e.toString().contains('not_found')) {
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } else {
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                          DialogUtils.showSnackBar(dialogContext,
                              "Error al verificar disponibilidad del nombre: $e",
                              color: Constants.errorColor);
                          return;
                        }
                      }
                    }

                    DialogUtils.showLoadingSpinner(dialogContext);

                    try {
                      Usuario usuarioActualizado = Usuario(
                        id: usuario.id,
                        trato: selectedTrato,
                        imagen:
                            imagenPath ?? ImageUtils.getDefaultImage(esAdmin),
                        edad: int.parse(edadController.text),
                        usuario: usuarioController.text,
                        contrasena: contrasenaController.text,
                        lugarNacimiento: lugarNacimiento,
                        bloqueado: bloqueado,
                        esAdmin: esAdmin,
                      );

                      int userId = 0;
                      try {
                        if (usuario.id != null && usuario.id!.isNotEmpty) {
                          userId = int.parse(usuario.id!);

                          if (userId <= 0) {
                            throw Exception('ID de usuario inválido');
                          }
                        } else {
                          throw Exception('ID de usuario es nulo o vacío');
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        DialogUtils.showSnackBar(context,
                            "Error: No se pudo identificar al usuario correctamente. ID inválido.",
                            color: Constants.errorColor);
                        return;
                      }

                      usuarioActualizado.id = userId.toString();

                      bool success = await UsuarioService.actualizarUsuario(
                          usuarioActualizado, userId);

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (success) {
                        Navigator.of(dialogContext).pop();

                        DialogUtils.showSnackBar(
                          context,
                          "Usuario actualizado correctamente",
                          color: Constants.successColor,
                        );

                        _cargarUsuarios();
                      } else {
                        DialogUtils.showSnackBar(
                          context,
                          "Error al actualizar el usuario. Por favor, verifique que el ID sea válido y que el nombre de usuario no esté duplicado.",
                          color: Constants.errorColor,
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      String errorMessage = "Error al actualizar usuario";

                      if (e.toString().contains('too long for column')) {
                        errorMessage =
                            "La imagen es demasiado grande para el servidor. Por favor, elija una imagen más pequeña o use la predeterminada.";
                      }

                      DialogUtils.showSnackBar(context, "$errorMessage: $e",
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
        future: UsuarioService.obtenerTodosUsuarios(),
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
                            try {
                              Usuario? usuarioActual =
                                  await UsuarioService.buscarUsuarioPorNombre(
                                      user.usuario);
                              if (usuarioActual != null) {
                                user.bloqueado = !user.bloqueado;
                                int userId =
                                    int.parse(usuarioActual.id.toString());

                                await UsuarioService.actualizarUsuario(
                                    user, userId);

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
                                Usuario? usuarioActual =
                                    await UsuarioService.buscarUsuarioPorNombre(
                                        user.usuario);
                                if (usuarioActual != null) {
                                  int userId =
                                      int.parse(usuarioActual.id.toString());

                                  await UsuarioService.eliminarUsuario(userId);

                                  Navigator.pop(context);

                                  _cargarUsuarios();

                                  DialogUtils.showSnackBar(context,
                                      "Usuario eliminado correctamente",
                                      color: Constants.successColor);
                                } else {
                                  Navigator.pop(context);
                                  throw Exception(
                                      "No se pudo encontrar el usuario para eliminar");
                                }
                              } catch (e) {
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
