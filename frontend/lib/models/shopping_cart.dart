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

  factory ShoppingCart.empty() {
    return ShoppingCart(
      items: [],
      ultimaActualizacion: DateTime.now(),
      total: 0.0,
    );
  }

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

  ShoppingCart addItem(CartItem newItem) {
    List<CartItem> updatedItems = List.from(items);

    int existingIndex = updatedItems
        .indexWhere((item) => item.productoId == newItem.productoId);

    if (existingIndex >= 0) {
      CartItem existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
          cantidad: existingItem.cantidad + newItem.cantidad);
    } else {
      updatedItems.add(newItem);
    }

    double newTotal = 0;
    for (var item in updatedItems) {
      newTotal += item.subtotal;
    }

    return ShoppingCart(
      id: id,
      sessionId: sessionId,
      usuarioId: usuarioId,
      items: updatedItems,
      ultimaActualizacion: DateTime.now(),
      total: newTotal,
    );
  }

  ShoppingCart removeItem(int productoId) {
    List<CartItem> updatedItems =
        items.where((item) => item.productoId != productoId).toList();

    double newTotal = 0;
    for (var item in updatedItems) {
      newTotal += item.subtotal;
    }

    return ShoppingCart(
      id: id,
      sessionId: sessionId,
      usuarioId: usuarioId,
      items: updatedItems,
      ultimaActualizacion: DateTime.now(),
      total: newTotal,
    );
  }

  ShoppingCart updateItemQuantity(int productoId, int cantidad) {
    List<CartItem> updatedItems = List.from(items);

    int itemIndex =
        updatedItems.indexWhere((item) => item.productoId == productoId);

    if (itemIndex >= 0) {
      CartItem item = updatedItems[itemIndex];
      updatedItems[itemIndex] = item.copyWith(cantidad: cantidad);
    }

    double newTotal = 0;
    for (var item in updatedItems) {
      newTotal += item.subtotal;
    }

    return ShoppingCart(
      id: id,
      sessionId: sessionId,
      usuarioId: usuarioId,
      items: updatedItems,
      ultimaActualizacion: DateTime.now(),
      total: newTotal,
    );
  }

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
