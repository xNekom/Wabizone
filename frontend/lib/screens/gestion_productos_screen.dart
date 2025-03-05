import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/producto_provider.dart';
import '../models/producto.dart';
import '../widgets/producto_card.dart';
import '../utils/validation_utils.dart';
import '../utils/dialog_utils.dart';
import '../utils/image_utils.dart';
import '../utils/constants_utils.dart';

class GestionProductosScreen extends StatefulWidget {
  const GestionProductosScreen({super.key});

  @override
  _GestionProductosScreenState createState() => _GestionProductosScreenState();
}

class _GestionProductosScreenState extends State<GestionProductosScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductoProvider>(context, listen: false)
          .obtenerTodosProductos();
    });
  }

  void _crearProducto() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController descripcionController = TextEditingController();
    TextEditingController precioController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    String? imagenPath;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Producto"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                    validator: ValidationUtils.validateRequired,
                  ),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: "Descripción"),
                  ),
                  TextFormField(
                    controller: precioController,
                    decoration: const InputDecoration(labelText: "Precio"),
                    keyboardType: TextInputType.number,
                    validator: ValidationUtils.validatePrice,
                  ),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: "Stock"),
                    keyboardType: TextInputType.number,
                    validator: ValidationUtils.validateStock,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final nuevaImagen = await ImageUtils.pickImage();
                      if (nuevaImagen != null) {
                        setDialogState(() {
                          imagenPath = nuevaImagen;
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: (imagenPath == null || imagenPath!.isEmpty)
                              ? Icon(Icons.image,
                                  size: 80, color: Constants.primaryColor)
                              : ClipOval(
                                  child: Image(
                                    image: ImageUtils.getImageProvider(
                                        imagenPath!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                          'Error al cargar imagen en diálogo de producto: $error');
                                      return Icon(Icons.broken_image,
                                          size: 80,
                                          color: Constants.primaryColor);
                                    },
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Constants.primaryColor,
                            radius: 18,
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    imagenPath != null && imagenPath!.isNotEmpty
                        ? "Imagen seleccionada"
                        : "Selecciona una imagen para el producto",
                    style: TextStyle(
                      color: imagenPath != null && imagenPath!.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  if (ValidationUtils.validateRequired(nombreController.text) !=
                          null ||
                      ValidationUtils.validatePrice(precioController.text) !=
                          null ||
                      ValidationUtils.validateStock(stockController.text) !=
                          null) {
                    DialogUtils.showSnackBar(context,
                        "Por favor, complete todos los campos correctamente",
                        color: Constants.errorColor);
                    return;
                  }

                  // Mostrar spinner de carga
                  DialogUtils.showLoadingSpinner(dialogContext);

                  try {
                    // Generar un ID único para el producto
                    String customId = "p${Random().nextInt(10000)}";
                    Producto nuevoProducto = Producto(
                      id: customId,
                      nombre: nombreController.text,
                      descripcion: descripcionController.text,
                      precio: double.parse(
                          precioController.text.replaceAll(',', '.')),
                      stock: int.parse(stockController.text),
                      imagen:
                          imagenPath ?? 'assets/imagenes/producto_default.png',
                    );

                    final productoProvider =
                        Provider.of<ProductoProvider>(context, listen: false);

                    bool success =
                        await productoProvider.crearProducto(nuevoProducto);

                    // Cerrar diálogo de carga y creación
                    Navigator.of(dialogContext).pop(); // Cerrar el spinner
                    Navigator.of(dialogContext)
                        .pop(); // Cerrar el diálogo de creación

                    if (success) {
                      DialogUtils.showSnackBar(
                          context, "Producto creado correctamente",
                          color: Constants.successColor);
                    } else {
                      DialogUtils.showSnackBar(context, productoProvider.error,
                          color: Constants.errorColor);
                    }
                  } catch (e) {
                    // Cerrar diálogo de carga en caso de error
                    Navigator.of(dialogContext).pop();
                    DialogUtils.showSnackBar(
                        context, "Error al crear el producto: $e",
                        color: Constants.errorColor);
                  }
                },
                child: const Text("Crear"),
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
        title: const Text("Gestión de Productos",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ProductoProvider>(
        builder: (context, productoProvider, child) {
          if (productoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productoProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${productoProvider.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => productoProvider.obtenerTodosProductos(),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            );
          }

          final productos = productoProvider.productos;

          if (productos.isEmpty) {
            return const Center(
              child: Text("No hay productos disponibles."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return ProductoCard(
                producto: producto,
                onEdit: () => _editarProducto(producto),
                onDelete: () => _eliminarProducto(producto),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearProducto,
        backgroundColor: Constants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _editarProducto(Producto producto) {
    // Primero verificamos si el producto existe
    final productoProvider =
        Provider.of<ProductoProvider>(context, listen: false);

    DialogUtils.showLoadingSpinner(context);

    productoProvider
        .obtenerProductoPorId(producto.id)
        .then((productoExistente) {
      Navigator.of(context).pop(); // Cerrar spinner

      if (productoExistente == null) {
        // El producto no existe
        DialogUtils.showSnackBar(context,
            "No se encontró el producto con ID ${producto.id}. No se puede editar.",
            color: Constants.errorColor);
        return;
      }

      // Si el producto existe, continuamos con la edición
      _mostrarDialogoEdicion(producto);
    }).catchError((error) {
      Navigator.of(context).pop(); // Cerrar spinner
      DialogUtils.showSnackBar(
          context, "Error al verificar si el producto existe: $error",
          color: Constants.errorColor);
    });
  }

  void _mostrarDialogoEdicion(Producto producto) {
    TextEditingController nombreController =
        TextEditingController(text: producto.nombre);
    TextEditingController descripcionController =
        TextEditingController(text: producto.descripcion);
    TextEditingController precioController =
        TextEditingController(text: producto.precio.toString());
    TextEditingController stockController =
        TextEditingController(text: producto.stock.toString());
    String? imagenPath = producto.imagen;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Editar Producto"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                    validator: ValidationUtils.validateRequired,
                  ),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: "Descripción"),
                  ),
                  TextFormField(
                    controller: precioController,
                    decoration: const InputDecoration(labelText: "Precio"),
                    keyboardType: TextInputType.number,
                    validator: ValidationUtils.validatePrice,
                  ),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: "Stock"),
                    keyboardType: TextInputType.number,
                    validator: ValidationUtils.validateStock,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final nuevaImagen = await ImageUtils.pickImage();
                      if (nuevaImagen != null) {
                        setDialogState(() {
                          imagenPath = nuevaImagen;
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: (imagenPath == null || imagenPath!.isEmpty)
                              ? Icon(Icons.image,
                                  size: 80, color: Constants.primaryColor)
                              : ClipOval(
                                  child: Image(
                                    image: ImageUtils.getImageProvider(
                                        imagenPath!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                          'Error al cargar imagen en diálogo de producto: $error');
                                      return Icon(Icons.broken_image,
                                          size: 80,
                                          color: Constants.primaryColor);
                                    },
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Constants.primaryColor,
                            radius: 18,
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    imagenPath != null && imagenPath!.isNotEmpty
                        ? "Imagen seleccionada"
                        : "Selecciona una imagen para el producto",
                    style: TextStyle(
                      color: imagenPath != null && imagenPath!.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  if (ValidationUtils.validateRequired(nombreController.text) !=
                          null ||
                      ValidationUtils.validatePrice(precioController.text) !=
                          null ||
                      ValidationUtils.validateStock(stockController.text) !=
                          null) {
                    DialogUtils.showSnackBar(context,
                        "Por favor, complete todos los campos correctamente",
                        color: Constants.errorColor);
                    return;
                  }

                  // Mostrar spinner de carga
                  DialogUtils.showLoadingSpinner(dialogContext);

                  try {
                    Producto productoActualizado = Producto(
                      id: producto.id,
                      nombre: nombreController.text,
                      descripcion: descripcionController.text,
                      precio: double.parse(
                          precioController.text.replaceAll(',', '.')),
                      stock: int.parse(stockController.text),
                      imagen: imagenPath ?? producto.imagen,
                    );

                    final productoProvider =
                        Provider.of<ProductoProvider>(context, listen: false);

                    // Extraer el ID numérico del producto
                    int productId = 0;
                    try {
                      print(
                          'Extrayendo ID numérico para producto: ${producto.id}');
                      if (producto.id.startsWith("p")) {
                        // Intenta extraer un número de la parte "p1234" del ID
                        String numberPart =
                            producto.id.replaceAll(RegExp(r'[^0-9]'), '');
                        print('Parte numérica extraída: $numberPart');

                        if (numberPart.isNotEmpty) {
                          productId = int.parse(numberPart);
                        } else {
                          print(
                              'No se pudo extraer parte numérica del ID ${producto.id}');
                          productId = 0;
                        }
                      } else {
                        // Intenta convertir todo el ID a entero
                        try {
                          productId = int.parse(producto.id);
                        } catch (parseError) {
                          print(
                              'No se pudo convertir ${producto.id} a entero: $parseError');
                          productId = 0;
                        }
                      }
                      print('ID numérico extraído: $productId');
                    } catch (e) {
                      // En caso de error, usa 0 como fallback
                      print('Error al extraer ID numérico: $e');
                      productId = 0;
                    }

                    bool success = await productoProvider.actualizarProducto(
                        productoActualizado, productId);

                    // Cerrar diálogo de carga y edición
                    Navigator.of(dialogContext).pop(); // Cerrar el spinner
                    Navigator.of(dialogContext)
                        .pop(); // Cerrar el diálogo de edición

                    if (success) {
                      DialogUtils.showSnackBar(
                          context, "Producto actualizado correctamente",
                          color: Constants.successColor);
                    } else {
                      // Mensaje más descriptivo basado en el error
                      String errorMsg = productoProvider.error;
                      if (errorMsg.contains('producto_no_encontrado')) {
                        errorMsg =
                            "No se encontró el producto con ID ${producto.id}";
                      } else if (errorMsg.isEmpty) {
                        errorMsg =
                            "Error al actualizar el producto. Verifique la conexión con el servidor.";
                      }

                      DialogUtils.showSnackBar(context, errorMsg,
                          color: Constants.errorColor);
                    }
                  } catch (e) {
                    // Cerrar diálogo de carga en caso de error
                    Navigator.of(dialogContext).pop();
                    DialogUtils.showSnackBar(
                        context, "Error al actualizar el producto: $e",
                        color: Constants.errorColor);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _eliminarProducto(Producto producto) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirmar Eliminación"),
          content: Text(
              "¿Está seguro que desea eliminar el producto '${producto.nombre}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                // Mostrar spinner de carga
                DialogUtils.showLoadingSpinner(dialogContext);

                try {
                  final productoProvider =
                      Provider.of<ProductoProvider>(context, listen: false);

                  bool success =
                      await productoProvider.eliminarProducto(producto.id);

                  // Cerrar diálogos
                  Navigator.of(dialogContext).pop(); // Cerrar el spinner
                  Navigator.of(dialogContext)
                      .pop(); // Cerrar el diálogo de confirmación

                  if (success) {
                    DialogUtils.showSnackBar(
                        context, "Producto eliminado correctamente",
                        color: Constants.successColor);
                  } else {
                    DialogUtils.showSnackBar(context, productoProvider.error,
                        color: Constants.errorColor);
                  }
                } catch (e) {
                  // Cerrar diálogo de carga en caso de error
                  Navigator.of(dialogContext).pop();
                  DialogUtils.showSnackBar(
                      context, "Error al eliminar el producto: $e",
                      color: Constants.errorColor);
                }
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}
