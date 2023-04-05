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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  final formKey = GlobalKey<FormState>();
  bool buttonClickable = true;
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
      appBar: AppBar(
        backgroundColor: messageBackgroundColor,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            //Todo change to the correct Navigation
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Password reset",
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
                devtools.log("Pressed Home");
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            //Enter Email Text
            const Text(
              "Enter Your Email-Address: ",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                  nextPressed();
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
            const Padding(padding: EdgeInsets.only(top: 25)),
            Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width / 1.5,
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (buttonClickable) {
                    nextPressed();
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: registerLoginButtonColor,
                    shape: const StadiumBorder(),
                    side: const BorderSide(width: 1)),
                child: Text("Send reset mail",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: buttonClickable ? Colors.black : Colors.black45,
                    )),
              ),
            ),

            //! Error message
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
    );
  }

  void nextPressed() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      //Display Loading Message
      OverLayScreen().showLoading(context: context, text: "Loading...");

      await AuthService.Firebase().sendPasswordReset(_emailController.text);

      //Show email is sent snackbar
      OverLayScreen().hide();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reset mail sent to ${_emailController.text}'),
      ));

      setState(() {
        buttonClickable = false;
      });
      await Future.delayed(const Duration(seconds: 3));

      //Move User to next Screen
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (val) => (false));
    } catch (E) {
      setState(() {
        _ErrorText = E.toString();
        formKey.currentState!.validate();
        devtools.log("Couldn't send reset to: ${_emailController.text}");
        _emailController.text = "";
      });
    } finally {
      OverLayScreen().hide();
    }
  }
}
