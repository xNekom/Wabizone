import 'cart_item.dart';

class ShoppingCart {
  final String? id;
  final String? sessionId;
  final int? usuarioId;
  final List<CartItem> items;
  final DateTime ultimaActualizacion;
  final double total;

  ShoppingCart({
    this.id,
    this.sessionId,
    this.usuarioId,
    required this.items,
    required this.ultimaActualizacion,
    required this.total,
  });

  // Factory method para crear un ShoppingCart vacío
  factory ShoppingCart.empty() {
    return ShoppingCart(
      items: [],
      ultimaActualizacion: DateTime.now(),
      total: 0.0,
    );
  }

  // Factory method para crear un ShoppingCart desde JSON
  factory ShoppingCart.fromJson(Map<String, dynamic> json) {
    return ShoppingCart(
      id: json['id'],
      sessionId: json['sessionId'],
      usuarioId: json['usuarioId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      ultimaActualizacion: DateTime.parse(json['ultimaActualizacion']),
      total: json['total'].toDouble(),
    );
  }

  // Método para convertir ShoppingCart a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'usuarioId': usuarioId,
      'items': items.map((item) => item.toJson()).toList(),
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
      'total': total,
    };
  }

  // Método para agregar un ítem al carrito
  ShoppingCart addItem(CartItem newItem) {
    List<CartItem> updatedItems = List.from(items);

    // Verificar si el producto ya existe en el carrito
    int existingIndex = updatedItems
        .indexWhere((item) => item.productoId == newItem.productoId);

    if (existingIndex >= 0) {
      // Si el producto ya existe, actualizar la cantidad
      CartItem existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
          cantidad: existingItem.cantidad + newItem.cantidad);
    } else {
      // Si no existe, añadirlo al carrito
      updatedItems.add(newItem);
    }

    // Calcular el nuevo total
    double newTotal = 0;
    for (var item in updatedItems) {
      newTotal += item.subtotal;
    }

    // Retornar un nuevo ShoppingCart con los ítems actualizados
    return ShoppingCart(
      id: id,
      sessionId: sessionId,
      usuarioId: usuarioId,
      items: updatedItems,
      ultimaActualizacion: DateTime.now(),
      total: newTotal,
    );
  }

  // Método para eliminar un ítem del carrito
  ShoppingCart removeItem(int productoId) {
    List<CartItem> updatedItems =
        items.where((item) => item.productoId != productoId).toList();

    // Calcular el nuevo total
    double newTotal = 0;
    for (var item in updatedItems) {
      newTotal += item.subtotal;
    }

    // Retornar un nuevo ShoppingCart con los ítems actualizados
    return ShoppingCart(
      id: id,
      sessionId: sessionId,
      usuarioId: usuarioId,
      items: updatedItems,
      ultimaActualizacion: DateTime.now(),
      total: newTotal,
    );
  }

  // Método para actualizar la cantidad de un ítem
  ShoppingCart updateItemQuantity(int productoId, int cantidad) {
    List<CartItem> updatedItems = List.from(items);

    int itemIndex =
        updatedItems.indexWhere((item) => item.productoId == productoId);

    if (itemIndex >= 0) {
      CartItem item = updatedItems[itemIndex];
      updatedItems[itemIndex] = item.copyWith(cantidad: cantidad);
    }

    // Calcular el nuevo total
    double newTotal = 0;
    for (var item in updatedItems) {
      newTotal += item.subtotal;
    }

    // Retornar un nuevo ShoppingCart con los ítems actualizados
    return ShoppingCart(
      id: id,
      sessionId: sessionId,
      usuarioId: usuarioId,
      items: updatedItems,
      ultimaActualizacion: DateTime.now(),
      total: newTotal,
    );
  }

  // Método para vaciar el carrito
  ShoppingCart clearCart() {
    return ShoppingCart(
      id: id,
      sessionId: sessionId,
      usuarioId: usuarioId,
      items: [],
      ultimaActualizacion: DateTime.now(),
      total: 0.0,
    );
  }
}
