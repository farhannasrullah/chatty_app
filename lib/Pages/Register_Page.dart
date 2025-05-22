import 'package:chatty_app/Components/my_button.dart';
import 'package:chatty_app/Components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final void Function()? onTap;

  
  RegisterPage ({super.key, required this.onTap});

  void register (){}

  @override
  Widget build(BuildContext context){
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
              "Create an account", 
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

            const SizedBox(height: 10),

            MyTextfield(
              hintText: "Confirm Password",
              obscureText: true,
              controller: _confirmpwController,
            ),

            const SizedBox(height: 25),

            MyButton(
              text: "Register",
              onTap: register,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: 
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                  

                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login now", 
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