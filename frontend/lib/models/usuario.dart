class Usuario {
  String? id;
  String trato;
  String imagen;
  int edad;
  String usuario;
  String contrasena;
  String lugarNacimiento;
  bool bloqueado;
  bool esAdmin;

  Usuario({
    this.id,
    required this.trato,
    required this.imagen,
    required this.edad,
    required this.usuario,
    required this.contrasena,
    required this.lugarNacimiento,
    this.bloqueado = false,
    this.esAdmin = false,
  });

  // Getters
  String? get getId => id;
  String get getTrato => trato;
  String get getImagen => imagen;
  int get getEdad => edad;
  String get getUsuario => usuario;
  String get getContrasena => contrasena;
  String get getLugarNacimiento => lugarNacimiento;
  bool get getBloqueado => bloqueado;
  bool get getEsAdmin => esAdmin;

  // Setters
  set setId(String? newId) => id = newId;
  set setTrato(String trato) => this.trato = trato;
  set setImagen(String imagen) => this.imagen = imagen;
  set setEdad(int edad) => this.edad = edad;
  set setUsuario(String usuario) => this.usuario = usuario;
  set setContrasena(String contrasena) => this.contrasena = contrasena;
  set setLugarNacimiento(String lugarNacimiento) =>
      this.lugarNacimiento = lugarNacimiento;
  set setBloqueado(bool bloqueado) => this.bloqueado = bloqueado;
  set setEsAdmin(bool esAdmin) => this.esAdmin = esAdmin;
}
