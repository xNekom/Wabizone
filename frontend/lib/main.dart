import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';

// Utils
import 'utils/constants_utils.dart';

// Providers
import 'providers/usuario_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/pedido_provider.dart';
import 'providers/carrito_provider.dart';

// Services
import 'services/service_locator.dart';

void main() {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el service locator (crea las dependencias)
  ServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar MultiProvider para inyectar todos los providers
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
        },
      ),
    );
  }
}
