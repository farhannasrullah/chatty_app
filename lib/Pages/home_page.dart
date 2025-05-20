import 'package:CHATTY_APP/lib/auth_service.dart';
import 'package:flutter/material.dart';
import '../Components/my_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout() {
    // get auth service
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")), // AppBar
      drawer: MyDrawer(),
    ); // Scaffold
  }
}
