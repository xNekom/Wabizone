class Pedido {
  String id;
  int nPedido;
  String detallesPedido;
  String estadoPedido;
  double precioTotal;
  String? usuarioId; // Identificador del usuario que realizó el pedido
  String? nombreUsuario; // Nombre del usuario que realizó el pedido

  // Datos de envío
  String? nombreCompleto;
  String? direccion;
  String? ciudad;
  String? codigoPostal;
  String? telefono;
  String? email;
  String? comentarios;

  // Getter compatible con los widgets que usan 'estado'
  String get estado => estadoPedido;
  // Getter compatible con los widgets que usan 'total'
  double get total => precioTotal;
  // Getter compatible con los widgets que usan 'usuario'
  String? get usuario => nombreCompleto ?? nombreUsuario ?? usuarioId;
  // Lista vacía para compatibilidad con widgets que usan 'productos'
  List<dynamic> get productos => [];

  Pedido({
    required this.id,
    required this.nPedido,
    required this.detallesPedido,
    required this.estadoPedido,
    required this.precioTotal,
    this.usuarioId,
    this.nombreUsuario,
    this.nombreCompleto,
    this.direccion,
    this.ciudad,
    this.codigoPostal,
    this.telefono,
    this.email,
    this.comentarios,
  });

  // Getters
  String get getId => id;
  int get getNPedido => nPedido;
  String get getDetallesPedido => detallesPedido;
  String get getEstadoPedido => estadoPedido;
  double get getPrecioTotal => precioTotal;
  String? get getUsuarioId => usuarioId;
  String? get getNombreUsuario => nombreUsuario;
  String? get getNombreCompleto => nombreCompleto;
  String? get getDireccion => direccion;
  String? get getCiudad => ciudad;
  String? get getCodigoPostal => codigoPostal;
  String? get getTelefono => telefono;
  String? get getEmail => email;
  String? get getComentarios => comentarios;

  // Setters
  set setId(String id) => this.id = id;
  set setNPedido(int nPedido) => this.nPedido = nPedido;
  set setDetallesPedido(String detallesPedido) =>
      this.detallesPedido = detallesPedido;
  set setEstadoPedido(String estadoPedido) => this.estadoPedido = estadoPedido;
  set setPrecioTotal(double precioTotal) => this.precioTotal = precioTotal;
  set setUsuarioId(String? usuarioId) => this.usuarioId = usuarioId;
  set setNombreUsuario(String? nombreUsuario) =>
      this.nombreUsuario = nombreUsuario;
  set setNombreCompleto(String? nombreCompleto) =>
      this.nombreCompleto = nombreCompleto;
  set setDireccion(String? direccion) => this.direccion = direccion;
  set setCiudad(String? ciudad) => this.ciudad = ciudad;
  set setCodigoPostal(String? codigoPostal) => this.codigoPostal = codigoPostal;
  set setTelefono(String? telefono) => this.telefono = telefono;
  set setEmail(String? email) => this.email = email;
  set setComentarios(String? comentarios) => this.comentarios = comentarios;

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
      'usuarioId': usuarioId != null ? int.parse(usuarioId!) : null,
      'nombreUsuario': nombreUsuario,
      'nombreCompleto': nombreCompleto,
      'direccion': direccion,
      'ciudad': ciudad,
      'codigoPostal': codigoPostal,
      'telefono': telefono,
      'email': email,
      'comentarios': comentarios,
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
      nombreUsuario:
          json['nombreUsuario']?.toString() ?? json['usuario']?.toString(),
      nombreCompleto: json['nombreCompleto']?.toString(),
      direccion: json['direccion']?.toString(),
      ciudad: json['ciudad']?.toString(),
      codigoPostal: json['codigoPostal']?.toString(),
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      comentarios: json['comentarios']?.toString(),
    );
  }
}
