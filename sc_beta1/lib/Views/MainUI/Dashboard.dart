import 'package:flutter/material.dart';
import 'package:sc_beta1/Views/MainUI/Ai/ai_assistant.dart';
import 'package:sc_beta1/Views/Register/register_email.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import '../../Overlays/overlays.dart';
import '../../main.dart';
import 'AnonymousAdvice/anonymous_advice_main.dart';
import 'Articles/articles_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<DashboardScreen> {
  List<dynamic> myIcons = const [
    AssetImage("assets/icons/ai.png"),
    AssetImage("assets/icons/anonymous.png"),
    Icons.newspaper_rounded
  ];
  List<dynamic> myTitles = const [
    "Ai Assistant",
    "Anonymous Advice",
    "Browse Articles"
  ];
  List<dynamic> myRedirects = const [
    AiAssistantScreen(),
    AnonymousAdviceNavigation(),
    BrowseArticleScreen()
  ];
  BuildContext? Buildcontext;
  @override
  Widget build(BuildContext context) {
    Buildcontext = context;
    return Scaffold(
      body: Stack(fit: StackFit.passthrough, children: [
        //!   Image
        SafeArea(
          child: Container(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: Image(
              alignment: Alignment.topCenter,
              image: const AssetImage(mainScreenBackGroundPath),
              height: MediaQuery.of(context).size.height * 0.35,
            ),
          ),
        ),
        //!   User button
        SafeArea(
            child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton(
              icon: Icon(Icons.person, size: 40),
              onSelected: (value) async {
                switch (value) {
                  case "logout":
                    await AuthService.Firebase().logOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return const MainScreen();
                    }), (route) => false);
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: "logout",
                    child: Text('Log out'),
                  ),
                ];
              },
            ),
          ),
        )),
        Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.40),
          decoration: const BoxDecoration(
            //color: bottomSheetColor,
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
              SizedBox(
                height: 20,
              ),
              Flexible(
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (BuildContext context, index) {
                      return Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            final user = AuthService.Firebase().currentUser;
                            if (index == 1 &&
                                !user!.isEmailVerified /*Anonymous */) {
                              //User Clicked on Anonymous Advice
                              //Shows the ErrorOverlay
                              OverLayScreen().show(
                                  context: Buildcontext!,
                                  display: Column(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.red,
                                        size:
                                            MediaQuery.of(context).size.width /
                                                4,
                                      ),
                                      Text(
                                        "You must sign up first!",
                                        textAlign: TextAlign.center,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            OverLayScreen().hide();
                                          },
                                          child: const Text("Ok"))
                                    ],
                                  ));
                              return;
                            }
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => myRedirects[index]));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 2, color: aiTextMinimalColor),
                                borderRadius: BorderRadius.circular(40)),
                            semanticContainer: true,
                            color: dashboardButtonColor,
                            elevation: 7,
                            child: Container(
                              height: 200,
                              width: 200,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox.square(
                                    dimension: 70,
                                    child: index <= 1
                                        ? Image(image: myIcons[index])
                                        : Icon(
                                            myIcons[index],
                                            size: 70,
                                          ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    myTitles[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: textHeaderColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
