import 'package:flutter/material.dart';
import 'package:sc_beta1/Views/MainUI/Dashboard.dart';
import 'package:sc_beta1/Views/Register/register_email.dart';
import 'package:sc_beta1/constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import 'Overlays/overlays.dart';
import 'Views/Login/login.dart';
import 'Views/Register/register_done.dart';
import 'auth/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "Lexend"),
      debugShowCheckedModeBanner: false,
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatelessWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.Firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.Firebase().currentUser;

              if (user != null) {
                if (user.isEmailVerified) {
                  devtools.log("Email Verified");
                  return const DashboardScreen();
                } else {
                  devtools.log("Email not Verified");
                  return const MainScreen();
                }
              } else {
                return const MainScreen();
              }
            default:
              devtools.log("Connection status: ${snapshot.connectionState}");
              return Container(
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: double.infinity),
                decoration: const BoxDecoration(
                  gradient: backgroundGradient,
                ),
                child: Center(
                    child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                )),
              );
          }
        });
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        const SafeArea(
          child: Image(
            image: AssetImage("assets/back1.jpg"),
          ),
        ),
        Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.55),
          decoration: const BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey, blurRadius: 25.0, offset: Offset.zero)
            ],
          ),
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //!                             Login
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1),
                    backgroundColor: bottomSheetButtonColor,
                    shape: const StadiumBorder(),
                    fixedSize:
                        Size(MediaQuery.of(context).size.width / 1.4, 40),
                  ),
                  onPressed: () {
                    devtools.log("Pressed Login!");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Login",
                            style: TextStyle(
                                fontFamily: "Lexend",
                                fontSize: 20,
                                color: bottomSheetButtonTextColor),
                          ),
                        ],
                      ),
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Image(
                              image: AssetImage(LoginIconPath),
                              width: 25,
                            ),
                          ])
                    ],
                  )),
              //!Padding
              const Padding(padding: EdgeInsets.only(top: 10)),
              //!                             Register
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 1),
                      backgroundColor: bottomSheetButtonColor,
                      shape: const StadiumBorder(),
                      fixedSize:
                          Size(MediaQuery.of(context).size.width / 1.4, 40)
                      //padding: const EdgeInsets.only(top: 10, bottom: 10),
                      ),
                  onPressed: () {
                    devtools.log("Pressed Register");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RegisterEmailScreen()));
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Register",
                            style: TextStyle(
                              fontFamily: "Lexend",
                              fontSize: 20,
                              color: bottomSheetButtonTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),

              //!Padding
              const Padding(padding: EdgeInsets.only(top: 10)),
              //!                             Anonymous User

              TextButton(
                  onPressed: () async {
                    OverLayScreen()
                        .showLoading(context: context, text: "Loading...");
                    await AuthService.Firebase().anonymousLogIn();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DashboardScreen()));
                    OverLayScreen().hide();
                  },
                  child: const Text(
                    "Anonymous User",
                    style: TextStyle(
                        fontSize: 20, color: bottomSheetButtonTextColor),
                  ))
            ],
          ),
        ),
      ]),
    );
  }
}
