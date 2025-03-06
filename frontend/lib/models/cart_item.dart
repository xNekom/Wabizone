class CartItem {
  final int productoId;
  final String nombre;
  int cantidad;
  final double precio;
  final String? opciones;

  CartItem({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precio,
    this.opciones,
  });

  double get subtotal => precio * cantidad;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productoId: json['productoId'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      precio: json['precio'].toDouble(),
      opciones: json['opciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'cantidad': cantidad,
      'precio': precio,
      'opciones': opciones,
    };
  }

  CartItem copyWith({
    int? productoId,
    String? nombre,
    int? cantidad,
    double? precio,
    String? opciones,
  }) {
    return CartItem(
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      opciones: opciones ?? this.opciones,
    );
  }
}
