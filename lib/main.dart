import 'package:chatty_app/Themes/theme_provider.dart';
import 'package:chatty_app/services/auth/login_or_register.dart';
import 'package:chatty_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatty_app/services/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // ⬅ Ganti dari LoginOrRegister ke AuthGate
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
