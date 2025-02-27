class Producto {
  String id;
  String nombre;
  String descripcion;
  String imagen;
  int stock;
  double precio;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.stock,
    required this.precio,
  });

  // Getters
  String get getId => id;
  String get getNombre => nombre;
  String get getDescripcion => descripcion;
  String get getImagen => imagen;
  int get getStock => stock;
  double get getPrecio => precio;

  // Setters
  set setId(String id) => this.id = id;
  set setNombre(String nombre) => this.nombre = nombre;
  set setDescripcion(String descripcion) => this.descripcion = descripcion;
  set setImagen(String imagen) => this.imagen = imagen;
  set setStock(int stock) => this.stock = stock;
  set setPrecio(double precio) => this.precio = precio;
}
