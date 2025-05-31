import 'package:chatty_app/Components/my_button.dart';
import 'package:chatty_app/Components/my_textfield.dart';
import 'package:chatty_app/Pages/home_page.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  void login(BuildContext context) async {
    final authService = AuthService();
    final email = _emailController.text.trim();
    final password = _pwController.text.trim();

    try {
      await authService.signInwithEmailPassword(email, password);

      // Ambil UID dan load displayName dari Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('Users').doc(uid).get();
        final data = doc.data();
        if (data != null && data['displayName'] != null) {
          await FirebaseAuth.instance.currentUser?.updateDisplayName(
            data['displayName'],
          );
        }
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Berhasil Login"),
              content: const Text("Selamat! Anda berhasil login."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'Maaf, akun Anda belum terdaftar.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Maaf, password atau email Anda salah.';
      } else {
        errorMessage = 'Terjadi kesalahan: ${e.message}';
      }

      // Kosongkan field
      _emailController.clear();
      _pwController.clear();

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Login Gagal"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      // Kosongkan field
      _emailController.clear();
      _pwController.clear();

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Terjadi Kesalahan"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 160, width: 160),
            const SizedBox(height: 50),
            Text(
              "Selamat datang kembali",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            MyTextfield(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),
            const SizedBox(height: 25),
            MyButton(text: "Login", onTap: () => login(context)),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Belum punya akun?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    " Buat sekarang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
