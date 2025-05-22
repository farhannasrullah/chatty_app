
import 'package:chatty_app/Components/my_button.dart';
import 'package:chatty_app/Components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap}); 

  void login(){}

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
              "Welcome back, you've been missed!", 
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
              onTap: login,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member?",
                  style: 
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                  

                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Register now", 
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
