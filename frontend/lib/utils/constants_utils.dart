import 'package:flutter/material.dart';

class Constants {
  // Colores
  static const Color primaryColor = Colors.orange;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;

  static const Icon adminBadge = Icon(
    Icons.verified,
    color: Colors.blue,
    size: 16,
  );

  // Estados de pedido
  static const Map<String, IconData> estadoIconos = {
    "Pedido": Icons.shopping_cart,
    "En Producción": Icons.engineering,
    "En Reparto": Icons.local_shipping,
    "Entregado": Icons.check_circle,
  };

  static const Map<String, Color> estadoColores = {
    "Pedido": Colors.blue,
    "En Producción": Colors.orange,
    "En Reparto": Colors.purple,
    "Entregado": Colors.green,
  };

  // Capitales
  static const List<String> capitales = [
    "A Coruña",
    "Albacete",
    "Alicante",
    "Almería",
    "Ávila",
    "Badajoz",
    "Barcelona",
    "Bilbao",
    "Burgos",
    "Cáceres",
    "Cádiz",
    "Castellón de la Plana",
    "Ciudad Real",
    "Córdoba",
    "Cuenca",
    "Girona",
    "Granada",
    "Guadalajara",
    "Huelva",
    "Huesca",
    "Jaén",
    "Las Palmas",
    "León",
    "Lleida",
    "Logroño",
    "Lugo",
    "Madrid",
    "Málaga",
    "Murcia",
    "Ourense",
    "Palencia",
    "Palma",
    "Pamplona",
    "Pontevedra",
    "Salamanca",
    "San Sebastián",
    "Santa Cruz de Tenerife",
    "Santander",
    "Segovia",
    "Sevilla",
    "Soria",
    "Tarragona",
    "Teruel",
    "Toledo",
    "Valencia",
    "Valladolid",
    "Vitoria-Gasteiz",
    "Zamora",
    "Zaragoza"
  ];

  // Textos comunes
  static const String appName = "Mi Aplicación";
  static const String errorGenerico = "Ha ocurrido un error";
  static const String confirmacionGuardar = "¿Desea guardar los cambios?";
  static const String confirmacionEliminar = "¿Está seguro de eliminar?";
}
