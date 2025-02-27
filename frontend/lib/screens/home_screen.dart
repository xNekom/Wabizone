import 'dart:io';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/drawer_general.dart';
import '../utils/constants_utils.dart';
import 'compras_page.dart';
import 'pedidos_page.dart';
import 'yo_page.dart';
import 'perfil_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ComprasPage(usuario: widget.usuario),
      PedidosPage(usuario: widget.usuario),
      YoPage(usuario: widget.usuario, onTabChange: _onItemTapped),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _salir() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido ${widget.usuario.usuario}", style: const TextStyle(color: Colors.white)),
        backgroundColor: Constants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: DrawerGeneral(
        onCerrarSesion: _cerrarSesion,
        onSalir: _salir,
        onPerfil: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerfilScreen(usuario: widget.usuario),
            ),
          );
        },
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Constants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Compras"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pedidos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Yo"),
        ],
      ),
    );
  }
}
