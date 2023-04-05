import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';
import 'dart:developer' as devtools show log;

import '../../../constants/ui_consts.dart';
import 'advice_template.dart';
import 'anonymous_advice_ask.dart';
import 'anonymous_advice_others.dart';

class AnonymousAdviceNavigation extends StatefulWidget {
  const AnonymousAdviceNavigation({super.key});

  @override
  State<AnonymousAdviceNavigation> createState() =>
      _AnonymousAdviceNavigationState();
}

class _AnonymousAdviceNavigationState extends State<AnonymousAdviceNavigation> {
  List<Advice> adviceList = [];
  bool _isLoading = true;
  Image? helpOthers;
  Image? askForHelp;

  void LoadImages() {
    helpOthers = Image.asset(helpOthersImagePath, fit: BoxFit.cover);
    askForHelp = Image.asset(requestHelpImagePath, fit: BoxFit.cover);
    setState(() {
      _isLoading = false;
    });
  }

  Widget BuildLoading(BuildContext ctx) {
    return Container(
      constraints:
          BoxConstraints(minWidth: double.infinity, minHeight: double.infinity),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(width: 150, height: 150, child: CircularProgressIndicator()),
          SizedBox(
            height: 10,
          ),
          Text(
            "Loading...",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    LoadImages();
    super.initState();
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
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Anonymous Advice",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? BuildLoading(context)
          : Container(
              constraints: BoxConstraints(
                  minWidth: double.infinity, minHeight: double.infinity),
              decoration: const BoxDecoration(
                gradient: backgroundGradient,
              ),
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (index == 0) {
                        //*Help Others
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const AnonymousAdviceOthers()));
                      } else {
                        //*Ask for help
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const AnonymousAdviceAskNavigation()));
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 7,
                      margin: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  child: index == 0 ? helpOthers : askForHelp)
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Text(
                            index == 0 ? "Help others" : "Ask for help",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

Widget pendingAdviceCard(BuildContext context, Advice advice) {
  return Card(
    elevation: 7,
    margin: const EdgeInsets.all(15),
    //you can use an InkWell
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 100,
            child: Text(
              advice.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  devtools.log("Clicked on ${advice.id}");
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: registerLoginButtonColor,
                    shape: const StadiumBorder(),
                    side: BorderSide(width: 1)),
                child: const Text("Reply",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    )),
              ),
            ],
          ),
        )
      ],
    ),
  );
}
