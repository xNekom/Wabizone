import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/constants_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const LoginScreen(),
    );
  }
}
