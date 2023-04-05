import 'package:flutter/material.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/Register/register_confirm_email.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';

import '../../auth/auth_exception.dart';
import '../../constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import '../../main.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  late final TextEditingController _emailController;
  final formKey = GlobalKey<FormState>();
  String _ErrorText = "";

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {
          nextPressed();
        },
        style: ElevatedButton.styleFrom(
            elevation: 10,
            backgroundColor: registerLoginButtonColor,
            shape: const StadiumBorder(),
            side: const BorderSide(width: 1)),
        child: const Text("Next",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
      appBar: AppBar(
        backgroundColor: messageBackgroundColor,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Register",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
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
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              //Enter Email Text
              const Text(
                "Enter Your Email-Address: ",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              //you will need to confirm... Text
              const Text(
                "you will need to confirm it in the next step so make sure you have access to it!",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: registerFadedTextColor),
              ),
              const Padding(padding: EdgeInsets.only(top: 25)),
              //Text Field
              Form(
                key: formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? text) {
                    if (text != null && EmailValidator.validate(text)) {
                      return null;
                    } else {
                      return "Enter a valid email!";
                    }
                  },
                  onFieldSubmitted: (value) {
                    formKey.currentState!.validate();
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 15),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      //isDense: true,
                      labelText: "E-mail",
                      hintText: "Example: myemail@gmail.com",
                      suffixIcon: const Icon(Icons.email),
                      hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      )),
                ),
              ),
              //
              const Padding(padding: EdgeInsets.only(top: 25)),
              Visibility(
                  visible: _ErrorText.isNotEmpty,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 30,
                      ),
                      const Padding(padding: EdgeInsets.only(left: 15)),
                      Expanded(
                        child: Text(
                          _ErrorText,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void nextPressed() async {
    try {
      //Display Loading Message
      OverLayScreen().showLoading(context: context, text: "Loading...");

      //Create User and send Verification
      final userCredit = await AuthService.Firebase().createUser(
        email: _emailController.text,
        password: "dummyPasswordData",
      );
      devtools.log("Created User with ID :${userCredit.id}");
      await AuthService.Firebase().sendEmailVerification();
      OverLayScreen().hide();

      //Move User to next Screen
      //Todo
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RegisterConfirmScreen(
                sentToEmail: _emailController.text,
              )));
    } on EmailInUseAuthException {
      try {
        //Checking if the account exists but the info doesn't exist! (Didn't Complete Registration)
        final user = await AuthService.Firebase()
            .logIn(email: _emailController.text, password: "dummyPasswordData");

        if (await CloudStorage(user: user).hasInfo()) {
          throw EmailInUseAuthException();
        } else {
          //The account exists but the info doesn't exist! (Didn't Complete Registration)

          await AuthService.Firebase().sendEmailVerification();
          OverLayScreen().hide();

          //Show email is sent snackbar

          //Move User to next Screen
          //Todo
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RegisterConfirmScreen(
                    sentToEmail: _emailController.text,
                  )));
          return;
        }
      } catch (_) {}

      OverLayScreen().hide();
      setState(() {
        _ErrorText = "Email Already Registered!";
        _emailController.text = "";
        formKey.currentState!.validate();
        devtools.log("ERROR HAPPENED");
      });
    } catch (E) {
      OverLayScreen().hide();
      setState(() {
        _ErrorText = E.toString();
        _emailController.text = "";
        formKey.currentState!.validate();
        devtools.log("ERROR HAPPENED");
      });
    }
  }
}
