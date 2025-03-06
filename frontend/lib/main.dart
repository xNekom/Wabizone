import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants_utils.dart';
import 'providers/usuario_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/pedido_provider.dart';
import 'providers/carrito_provider.dart';
import 'providers/auth_provider.dart';
import 'services/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>(
          create: (_) => UsuarioProvider(),
        ),
        ChangeNotifierProvider<ProductoProvider>(
          create: (_) => ProductoProvider(),
        ),
        ChangeNotifierProvider<PedidoProvider>(
          create: (_) => PedidoProvider(),
        ),
        ChangeNotifierProvider<CarritoProvider>(
          create: (_) => CarritoProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Wabizone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Constants.primaryColor,
            primary: Constants.primaryColor,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Constants.primaryColor),
            ),
            focusColor: Constants.primaryColor,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/home': (context) {
            final usuarioProvider =
                Provider.of<UsuarioProvider>(context, listen: false);
            if (usuarioProvider.usuarioActual != null) {
              if (usuarioProvider.isAdmin) {
                return AdminHomeScreen(usuario: usuarioProvider.usuarioActual!);
              } else {
                return HomeScreen(usuario: usuarioProvider.usuarioActual!);
              }
            } else {
              return const LoginScreen();
            }
          },
        },
      ),
    );
  }
}
