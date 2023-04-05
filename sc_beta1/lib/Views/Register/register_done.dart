import 'package:flutter/material.dart';
import 'package:sc_beta1/Views/Login/login.dart';

import '../../constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import '../../main.dart';

class RegisterDoneScreen extends StatefulWidget {
  const RegisterDoneScreen({super.key});

  @override
  State<RegisterDoneScreen> createState() => _RegisterDoneScreenState();
}

class _RegisterDoneScreenState extends State<RegisterDoneScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: registerLoginButtonColor,
            shape: const StadiumBorder(),
            side: const BorderSide(width: 1)),
        child: const Text("Login",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
      appBar: AppBar(
        backgroundColor: messageBackgroundColor,
        elevation: 5,
        automaticallyImplyLeading: false,
        title: const Text(
          "Register",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: registerLoginButtonColor,
                  shape: const StadiumBorder(),
                  side: const BorderSide(width: 1)),
              child: const Text("Home",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  )),
            ),
          )
        ],
      ),
      body: Container(
        constraints: BoxConstraints(
            minHeight: double.infinity, minWidth: double.infinity),
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Thanks for Registering!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Icon(
                Icons.favorite,
                size: MediaQuery.of(context).size.width / 3,
                color: Colors.red,
              ),
              const Text(
                "You can now login!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
