import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/Register/register_info.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:email_validator/email_validator.dart';

import '../../auth/auth_exception.dart';
import '../../constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import '../../main.dart';

class RegisterConfirmScreen extends StatefulWidget {
  final String sentToEmail;
  const RegisterConfirmScreen({super.key, required this.sentToEmail});

  @override
  State<RegisterConfirmScreen> createState() => _RegisterConfirmScreenState();
}

var _ErrorText = "";

class _RegisterConfirmScreenState extends State<RegisterConfirmScreen> {
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
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                      (route) => false);
                  devtools.log("Pressed Home");
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: registerLoginButtonColor,
                    shape: const StadiumBorder(),
                    side: BorderSide(width: 1)),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Image
                const Image(image: AssetImage("assets/SentEmail.png")),
                //Please click on the link sent to the email : Text
                const Text(
                  "Please click on the link sent to the email :",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                //Icon And Email
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //Email Icon
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.black,
                      ),
                      //Email
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Flexible(
                        child: Text(
                          "${widget.sentToEmail}",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              color: registerFadedTextColor),
                        ),
                      ),
                    ]),
                //And then press next
                const Padding(padding: EdgeInsets.only(top: 10)),
                const Text(
                  "And then press next",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                //Error Message
                const Padding(padding: EdgeInsets.only(top: 10)),
                Visibility(
                    visible: _ErrorText.isNotEmpty,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            color: Colors.red,
                            size: 30,
                          ),
                          const Padding(padding: EdgeInsets.only(left: 15)),
                          Flexible(
                            child: Text(
                              _ErrorText,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          )
                        ])),
              ],
            ),
          ),
        ));
  }

  Future<void> nextPressed() async {
    OverLayScreen().showLoading(context: context, text: "Loading...");
    if (AuthService.Firebase().currentUser != null) {
      await AuthService.Firebase().logOut();
    }
    final user = await AuthService.Firebase()
        .logIn(email: widget.sentToEmail, password: "dummyPasswordData");

    if (user.isEmailVerified) {
      devtools.log("Email Verified");
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RegisterInfoScreen(
                Email: widget.sentToEmail,
              )));

      OverLayScreen().hide();
    } else {
      setState(() {
        _ErrorText = "Please verify before continuing!";
        devtools.log("Please Verify");
        OverLayScreen().hide();
      });
    }
  }
}
