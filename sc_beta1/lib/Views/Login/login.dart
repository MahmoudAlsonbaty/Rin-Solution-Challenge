import 'package:flutter/material.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/auth/auth_exception.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:email_validator/email_validator.dart';

import '../../constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import '../../main.dart';
import '../MainUI/Dashboard.dart';
import 'forgotPassword.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final formKey = GlobalKey<FormState>();
  String _ErrorText = "";
  final String _wrongCredentialsMessage = "Incorrect Email or Password!";

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false);
          },
        ),
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        constraints: BoxConstraints(
            minHeight: double.infinity, minWidth: double.infinity),
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                //!Welcome Text
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Welcome!",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: textHeaderColor),
                    textAlign: TextAlign.center,
                  ),
                ),

                //!All Fields
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height -
                        (MediaQuery.of(context).padding.top * 4),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Form(
                            key: formKey,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (String? text) {
                                if (text != null &&
                                    EmailValidator.validate(text)) {
                                  return null;
                                } else {
                                  return "Enter a valid email!";
                                }
                              },
                              onFieldSubmitted: (value) {
                                formKey.currentState!.validate();
                              },
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 15),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  //isDense: true,
                                  labelText: "E-mail",
                                  hintText: "Example: myemail@gmail.com",
                                  suffixIcon: Icon(Icons.email),
                                  hintStyle: const TextStyle(
                                      fontWeight: FontWeight.w300),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                  )),
                            ),
                          ),
                          //! Password Field
                          const Padding(padding: EdgeInsets.only(top: 25)),
                          TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            onFieldSubmitted: (value) {
                              nextPressed();
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 15),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                //isDense: true,
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                )),
                          ),
                          //! Login Button
                          const Padding(padding: EdgeInsets.only(top: 25)),
                          Container(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width / 1.5,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                nextPressed();
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 10,
                                  backgroundColor: bottomSheetButtonColor,
                                  shape: const StadiumBorder(),
                                  side: const BorderSide(width: 1)),
                              child: const Text("Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                          //! Reset Password button
                          const Padding(padding: EdgeInsets.only(top: 10)),
                          Container(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width / 1.5,
                            ),
                            child: TextButton(
                              onPressed: () {
                                //*Send user to the forgot password screen
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()));
                              },
                              child: const Text("Forgot your password?",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueAccent,
                                  )),
                            ),
                          ),
                          //! ERROR Message
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
                                  const Padding(
                                      padding: EdgeInsets.only(left: 15)),
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
                              )),
                        ]))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void nextPressed() async {
    devtools.log("");
    try {
      if (!formKey.currentState!.validate()) {
        throw InvalidEmailOrPasswordException();
      }
      OverLayScreen().showLoading(context: context, text: "Loading...");
      if (AuthService.Firebase().currentUser != null) {
        await AuthService.Firebase().logOut();
      }
      await AuthService.Firebase().logIn(
          email: _emailController.text, password: _passwordController.text);

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false);
    } catch (e) {
      if (e is InvalidEmailOrPasswordException) {
      } else if (e is UserNotFoundException || e is WrongPasswordException) {
        setState(() {
          _ErrorText = "Invalid E-mail or Password";
        });
      } else {
        setState(() {
          _ErrorText = "Something went wrong \n$e";
        });
      }
    } finally {
      OverLayScreen().hide();
    }
  }
}
