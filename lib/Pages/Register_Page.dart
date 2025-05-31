import 'package:chatty_app/Components/my_button.dart';
import 'package:chatty_app/Components/my_textfield.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final AuthService _auth = AuthService();

  void _showAlertDialog(String title, String content, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onOk != null) onOk();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _pwController.text.trim();
    final confirmPassword = _confirmpwController.text.trim();
    final name = _nameController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showAlertDialog("Gagal", "Semua field harus diisi");
      return;
    }

    if (password != confirmPassword) {
      _showAlertDialog("Gagal", "Password tidak cocok");
      return;
    }

    try {
      await _auth.signUpWithEmailPassword(email, password, name);
      _showAlertDialog("Berhasil", "Registrasi berhasil", onOk: widget.onTap);
    } catch (e) {
      _showAlertDialog("Registrasi Gagal", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 160, width: 160),
              const SizedBox(height: 50),
              Text(
                "Buat Akun",
                style: TextStyle(fontSize: 16, color: theme.primary),
              ),
              const SizedBox(height: 25),
              MyTextfield(
                hintText: "Nama Lengkap",
                obscureText: false,
                controller: _nameController,
              ),
              const SizedBox(height: 10),

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
              const SizedBox(height: 10),
              MyTextfield(
                hintText: "Konfirmasi Password",
                obscureText: true,
                controller: _confirmpwController,
              ),
              const SizedBox(height: 25),
              MyButton(text: "Register", onTap: _register),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun?",
                    style: TextStyle(color: theme.primary),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      " Login sekarang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
