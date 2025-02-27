import 'package:flutter/material.dart';

class ClienteBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const ClienteBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: "Compras"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pedidos"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Yo"),
      ],
    );
  }
}
