import 'package:chatty_app/Themes/Light_Mode.dart';
import 'package:flutter/material.dart';
import 'Pages/Login_Page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: lightmode,

    );
  }

}

