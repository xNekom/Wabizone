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
                  print('Botón Crear presionado');
                  // Validar el formulario
                  final isValid =
                      dialogFormKey.currentState?.validate() ?? false;
                  print('Formulario válido: $isValid');

                  if (isValid) {
                    String? errorUsuario = ValidationUtils.validateRequired(
                        usuarioController.text);
                    String? errorContrasena = ValidationUtils.validatePassword(
                        contrasenaController.text);
                    String? errorEdad =
                        ValidationUtils.validateAge(edadController.text);

                    if (errorUsuario != null) {
                      print('Error de usuario: $errorUsuario');
                      DialogUtils.showSnackBar(dialogContext, errorUsuario,
                          color: Constants.errorColor);
                      return;
                    }
                    if (errorContrasena != null) {
                      print('Error de contraseña: $errorContrasena');
                      DialogUtils.showSnackBar(dialogContext, errorContrasena,
                          color: Constants.errorColor);
                      return;
                    }
                    if (errorEdad != null) {
                      print('Error de edad: $errorEdad');
                      DialogUtils.showSnackBar(dialogContext, errorEdad,
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
                        lugarNacimiento: selectedLugarNacimiento,
                        esAdmin: esAdmin,
                        bloqueado: bloqueado,
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

    // Almacenar el nombre de usuario original para verificar si cambia
    final String usuarioOriginal = usuario.usuario;

    // Asignar valores predeterminados si son nulos o vacíos
    String selectedTrato = usuario.trato.isEmpty ? "Sr." : usuario.trato;
    String? imagenPath = usuario.imagen;
    bool esAdmin = usuario.esAdmin;
    bool bloqueado = usuario.bloqueado;
    String lugarNacimiento =
        usuario.lugarNacimiento.isEmpty ? "Madrid" : usuario.lugarNacimiento;

    print('Editando usuario: ${usuario.usuario}');
    print('Trato original: "${usuario.trato}", usando: "$selectedTrato"');
    print(
        'Lugar nacimiento original: "${usuario.lugarNacimiento}", usando: "$lugarNacimiento"');

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
                    debugPrint('Nueva imagen seleccionada: $value');
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

                    // Verificar si hay errores de validación
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

                    // Verificar si el nombre de usuario ha cambiado y si ya existe
                    if (usuarioController.text != usuarioOriginal) {
                      print(
                          'El nombre de usuario ha cambiado de "$usuarioOriginal" a "${usuarioController.text}"');

                      // Mostrar spinner de carga para la verificación
                      DialogUtils.showLoadingSpinner(dialogContext);

                      try {
                        // Verificar si el nuevo nombre ya existe
                        Usuario? usuarioExistente =
                            await UsuarioService.buscarUsuarioPorNombre(
                                usuarioController.text);

                        // Cerrar el spinner de verificación
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
                        // Si es un 404, significa que el usuario no existe (lo que queremos)
                        if (e.toString().contains('404') ||
                            e.toString().contains('not_found')) {
                          print(
                              'Usuario no encontrado (404), lo cual es bueno para la edición');
                          // Cerrar el spinner para el caso 404 (usuario no existe)
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } else {
                          // Error de otro tipo
                          print(
                              'Error al verificar disponibilidad del nombre: $e');
                          // Cerrar el spinner en caso de error
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

                    // Mostrar spinner de carga para la actualización
                    DialogUtils.showLoadingSpinner(dialogContext);

                    try {
                      // Crear un nuevo objeto Usuario con los valores actualizados
                      Usuario usuarioActualizado = Usuario(
                        id: usuario.id,
                        trato: selectedTrato,
                        imagen:
                            imagenPath ?? ImageUtils.getDefaultImage(esAdmin),
                        edad: int.parse(edadController.text),
                        usuario: usuarioController.text, // Ahora puede cambiar
                        contrasena: contrasenaController.text,
                        lugarNacimiento: lugarNacimiento,
                        bloqueado: bloqueado,
                        esAdmin: esAdmin,
                      );

                      // Obtener y convertir el ID a entero para la API
                      int userId = 0;
                      if (usuario.id != null && usuario.id!.isNotEmpty) {
                        try {
                          userId = int.parse(usuario.id!);
                          print('ID obtenido del objeto usuario: $userId');
                        } catch (e) {
                          print('Error al parsear ID "${usuario.id}": $e');

                          // Si el ID no es válido, intentamos encontrarlo en la caché por nombre de usuario
                          final usuariosCache =
                              await UsuarioService.obtenerTodosUsuarios();
                          final usuarioEncontrado = usuariosCache.firstWhere(
                              (u) =>
                                  u.usuario.toLowerCase() ==
                                  usuario.usuario.toLowerCase(),
                              orElse: () => usuario);

                          if (usuarioEncontrado.id != null &&
                              usuarioEncontrado.id != usuario.id) {
                            try {
                              userId = int.parse(usuarioEncontrado.id!);
                              print('ID encontrado en caché: $userId');
                            } catch (e) {
                              print('Error al parsear ID de caché: $e');
                            }
                          }

                          // Si aún no tenemos un ID válido, buscaremos el usuario por nombre
                          if (userId <= 0) {
                            try {
                              final usuarioBuscado =
                                  await UsuarioService.buscarUsuarioPorNombre(
                                      usuario.usuario);
                              if (usuarioBuscado != null &&
                                  usuarioBuscado.id != null) {
                                userId = int.parse(usuarioBuscado.id!);
                                print(
                                    'ID obtenido desde buscarUsuarioPorNombre: $userId');
                              }
                            } catch (searchError) {
                              print(
                                  'Error al buscar usuario por nombre: $searchError');
                            }
                          }
                        }
                      } else {
                        print(
                            'ID no disponible en el objeto usuario, buscando alternativas...');
                        try {
                          // Intentar obtener el usuario de la caché por nombre
                          final usuariosCache =
                              await UsuarioService.obtenerTodosUsuarios();
                          final usuarioEncontrado = usuariosCache.firstWhere(
                              (u) =>
                                  u.usuario.toLowerCase() ==
                                  usuario.usuario.toLowerCase(),
                              orElse: () => Usuario(
                                  id: "0",
                                  trato: "",
                                  imagen: "",
                                  edad: 0,
                                  usuario: "",
                                  contrasena: "",
                                  lugarNacimiento: ""));

                          if (usuarioEncontrado.id != null) {
                            userId = int.parse(usuarioEncontrado.id!);
                            print('ID encontrado en caché: $userId');
                          }
                        } catch (e) {
                          print('Error al buscar usuario en caché: $e');
                        }
                      }

                      // Validar que tenemos un ID válido
                      if (userId <= 0) {
                        print(
                            'ERROR: No se pudo obtener un ID válido para el usuario ${usuario.usuario}');
                        DialogUtils.showSnackBar(context,
                            "No se pudo actualizar el usuario: ID inválido",
                            color: Constants.errorColor);
                        Navigator.of(dialogContext).pop(); // Cierra el spinner
                        return;
                      }

                      print('ID final para actualización: $userId');

                      bool success = await UsuarioService.actualizarUsuario(
                          usuarioActualizado, userId);

                      // Cerrar diálogo de edición
                      Navigator.of(dialogContext).pop(); // Cierra el spinner
                      Navigator.of(dialogContext)
                          .pop(); // Cierra el diálogo de edición

                      // Recargar los usuarios
                      _cargarUsuarios();

                      if (success) {
                        DialogUtils.showSnackBar(
                            context, "Usuario actualizado correctamente",
                            color: Constants.successColor);
                      } else {
                        DialogUtils.showSnackBar(
                            context, "No se pudo actualizar el usuario",
                            color: Constants.errorColor);
                      }
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
