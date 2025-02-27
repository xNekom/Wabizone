class Pedido {
  String id;
  int nPedido;
  String detallesPedido;
  String estadoPedido;
  double precioTotal;
  String? usuarioId; // Identificador del usuario que realizó el pedido

  // Getter compatible con los widgets que usan 'estado'
  String get estado => estadoPedido;
  // Getter compatible con los widgets que usan 'total'
  double get total => precioTotal;
  // Getter compatible con los widgets que usan 'usuario'
  String? get usuario => usuarioId;
  // Lista vacía para compatibilidad con widgets que usan 'productos'
  List<dynamic> get productos => [];

  Pedido({
    required this.id,
    required this.nPedido,
    required this.detallesPedido,
    required this.estadoPedido,
    required this.precioTotal,
    this.usuarioId,
  });

  // Getters
  String get getId => id;
  int get getNPedido => nPedido;
  String get getDetallesPedido => detallesPedido;
  String get getEstadoPedido => estadoPedido;
  double get getPrecioTotal => precioTotal;

  // Setters
  set setId(String id) => this.id = id;
  set setNPedido(int nPedido) => this.nPedido = nPedido;
  set setDetallesPedido(String detallesPedido) =>
      this.detallesPedido = detallesPedido;
  set setEstadoPedido(String estadoPedido) => this.estadoPedido = estadoPedido;
  set setPrecioTotal(double precioTotal) => this.precioTotal = precioTotal;
  // Setter compatible con los widgets que usan 'estado'
  set estado(String value) => estadoPedido = value;

  // Método para convertir los datos del usuario a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nPedido': nPedido,
      'detallesPedido': detallesPedido,
      'estadoPedido': estadoPedido,
      'precioTotal': precioTotal,
      'usuarioId': usuarioId,
    };
  }

  // Factory constructor para crear una instancia desde JSON
  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'].toString(),
      nPedido: json['nPedido'] ?? 0,
      detallesPedido: json['detallesPedido'] ?? '',
      estadoPedido: json['estadoPedido'] ?? '',
      precioTotal: json['precioTotal'] ?? 0.0,
      usuarioId: json['usuarioId']?.toString(),
    );
  }
}
