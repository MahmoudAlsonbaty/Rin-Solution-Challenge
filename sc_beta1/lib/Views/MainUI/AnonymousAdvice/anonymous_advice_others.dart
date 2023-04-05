import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/MainUI/AnonymousAdvice/anonymous_advice_others%20reply.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';
import 'dart:developer' as devtools show log;

import '../../../constants/ui_consts.dart';
import 'advice_template.dart';

class AnonymousAdviceOthers extends StatefulWidget {
  const AnonymousAdviceOthers({super.key});

  @override
  State<AnonymousAdviceOthers> createState() => _AnonymousAdviceOthersState();
}

class _AnonymousAdviceOthersState extends State<AnonymousAdviceOthers> {
  List<Advice> adviceList = [];
  bool _isLoading = true;
  final containerKey = GlobalKey();

  @override
  void initState() {
    readCloud();
    super.initState();
  }

  Future<void> refresh() async {
    setState(() {
      _isLoading = true;
    });
    await readCloud();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> readCloud() async {
    adviceList = [];
    devtools.log("Reading Cloud");
    //*Grab User Advices from firestore
    final user = AuthService.Firebase().currentUser!;
    final sentAdviceList = await CloudStorage(user: user).getSentAdviceIDs();
    final sentRepliesList = await CloudStorage(user: user).getSentReplyIDs();
    (await CloudStorage(user: user).getAdviceList()).forEach((advice) {
      if (sentAdviceList.contains(advice.id) ||
          sentRepliesList.contains(advice.id)) {
      } else {
        adviceList.add(advice);
      }
    });

    //devtools.log(adviceList[0].toString());
    //*Grab Advices from firestore
    setState(() {
      _isLoading = false;
    });
  }

  Widget BuildListView(BuildContext ctx) {
    return ListView.builder(
      itemCount: adviceList.length,
      itemBuilder: ((context, index) {
        return pendingAdviceCard(context, adviceList[index]);
      }),
    );
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
            "Help Others",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Container(
          constraints: BoxConstraints(
              minWidth: double.infinity, minHeight: double.infinity),
          decoration: const BoxDecoration(
            gradient: backgroundGradient,
          ),
          child: _isLoading ? BuildLoading(context) : BuildListView(context),
        ));
  }

  Widget pendingAdviceCard(BuildContext context, Advice advice) {
    final containerKey = GlobalKey();
    return Card(
      color: messageBackgroundColor,
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
          Container(
            key: containerKey,
            color: messageForegroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        devtools.log("Clicked on ${advice.id}");
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => AnonymousAdviceOthersReply(
                                    advice: advice,
                                    myParentFunction: refresh,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: messageButtonColor,
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
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.person),
                      Text("${advice.gender}, ${advice.age}"),
                    ],
                  ),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
