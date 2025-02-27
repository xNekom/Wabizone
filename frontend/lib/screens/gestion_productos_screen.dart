import 'dart:math' show Random;
import 'package:flutter/material.dart';
import '../services/producto_service.dart';
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
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _productosFuture = ProductoService.obtenerTodosProductos();
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          imagenPath ?? "No se ha seleccionado imagen",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String? newPath = await ImageUtils.pickImage();
                          if (newPath != null) {
                            setDialogState(() => imagenPath = newPath);
                          }
                        },
                        icon: const Icon(Icons.image),
                      ),
                    ],
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
                      imagen: imagenPath ?? ImageUtils.getDefaultImage(false),
                    );

                    bool success =
                        await ProductoService.agregarProducto(nuevoProducto);

                    // Cerrar diálogo de carga y creación
                    Navigator.of(dialogContext).pop(); // Cerrar el spinner
                    Navigator.of(dialogContext)
                        .pop(); // Cerrar el diálogo de creación

                    // Recargar los productos
                    _cargarProductos();

                    if (success) {
                      DialogUtils.showSnackBar(
                          context, "Producto creado correctamente",
                          color: Constants.successColor);
                    } else {
                      DialogUtils.showSnackBar(
                          context, "Error al crear el producto",
                          color: Constants.errorColor);
                    }
                  } catch (e) {
                    // Cerrar diálogo de carga en caso de error
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    DialogUtils.showSnackBar(
                        context, "Error al crear producto: $e",
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

  void _editarProducto(Producto producto) {
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          imagenPath ?? "No se ha seleccionado imagen",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String? newPath = await ImageUtils.pickImage();
                          if (newPath != null) {
                            setDialogState(() => imagenPath = newPath);
                          }
                        },
                        icon: const Icon(Icons.image),
                      ),
                    ],
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
                    producto.nombre = nombreController.text;
                    producto.descripcion = descripcionController.text;
                    producto.precio = double.parse(
                        precioController.text.replaceAll(',', '.'));
                    producto.stock = int.parse(stockController.text);
                    producto.imagen =
                        imagenPath ?? ImageUtils.getDefaultImage(false);

                    // Extraer el ID numérico del producto para enviarlo al backend
                    int productId = 0;
                    try {
                      if (producto.id.startsWith("p")) {
                        // Intenta extraer un número de la parte "p1234" del ID
                        productId = int.parse(
                            producto.id.replaceAll(RegExp(r'[^0-9]'), ''));
                      } else {
                        // Intenta convertir todo el ID a entero
                        productId = int.parse(producto.id);
                      }
                    } catch (e) {
                      // En caso de error, usa 0 como fallback
                      productId = 0;
                    }

                    bool success = await ProductoService.actualizarProducto(
                        producto, productId);

                    // Cerrar diálogo de carga y edición
                    Navigator.of(dialogContext).pop(); // Cerrar el spinner
                    Navigator.of(dialogContext)
                        .pop(); // Cerrar el diálogo de edición

                    // Recargar los productos
                    _cargarProductos();

                    if (success) {
                      DialogUtils.showSnackBar(
                          context, "Producto actualizado correctamente",
                          color: Constants.successColor);
                    } else {
                      DialogUtils.showSnackBar(
                          context, "Error al actualizar el producto",
                          color: Constants.errorColor);
                    }
                  } catch (e) {
                    // Cerrar diálogo de carga en caso de error
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    DialogUtils.showSnackBar(
                        context, "Error al actualizar producto: $e",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Productos",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Producto>>(
            future: _productosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error al cargar los productos: ${snapshot.error}",
                        style: const TextStyle(color: Constants.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarProductos,
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No hay productos disponibles"),
                );
              } else {
                final productos = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _cargarProductos,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      Producto producto = productos[index];
                      return ProductoCard(
                        producto: producto,
                        onEdit: () => _editarProducto(producto),
                        onDelete: () async {
                          bool? confirmar = await DialogUtils.showConfirmDialog(
                              context: context,
                              title: "Confirmar eliminación",
                              content:
                                  "¿Está seguro de eliminar ${producto.nombre}?");

                          if (confirmar == true) {
                            try {
                              await DialogUtils.showLoadingSpinner(context);
                              await ProductoService.eliminarProducto(
                                  producto.id);

                              // Cerrar el spinner
                              Navigator.pop(context);

                              // Recargar los productos
                              _cargarProductos();

                              DialogUtils.showSnackBar(
                                  context, "Producto eliminado correctamente",
                                  color: Constants.successColor);
                            } catch (e) {
                              // Cerrar el spinner en caso de error
                              Navigator.pop(context);
                              DialogUtils.showSnackBar(
                                  context, "Error al eliminar el producto: $e",
                                  color: Constants.errorColor);
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              }
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Constants.primaryColor,
              onPressed: () {
                _crearProducto();
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
