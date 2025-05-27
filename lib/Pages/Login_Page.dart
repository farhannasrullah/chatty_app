
import 'package:chatty_app/Components/my_button.dart';
import 'package:chatty_app/Components/my_textfield.dart';
import 'package:chatty_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../Pages/home_page.dart';

class LoginPage extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap}); 

  void login(BuildContext context) async{
    final authService = AuthService();
    try {
      await authService.signInwithEmailPassword(_emailController.text, _pwController.text,);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          );
    }
    catch (e){
      showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          title: Text(e.toString()),
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
            //logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 50),

            Text(
              "Selamat datanng kembali", 
              style: TextStyle(color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            MyTextfield(
              hintText: "Email",
              obscureText: false,
              controller: _emailController ,
            ),

            const SizedBox(height: 10),

            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),

            const SizedBox(height: 25),

            MyButton(
              text: "Login",
              onTap: () => login (context),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Belum punya akun?",
                  style: 
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                  

                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Buat sekarang", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
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
