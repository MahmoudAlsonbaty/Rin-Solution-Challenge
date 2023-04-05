import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';
import 'dart:developer' as devtools show log;

import '../../../constants/ui_consts.dart';
import 'advice_template.dart';

class AnonymousAdviceSend extends StatefulWidget {
  const AnonymousAdviceSend({super.key});

  @override
  State<AnonymousAdviceSend> createState() => _AnonymousAdviceSendState();
}

class _AnonymousAdviceSendState extends State<AnonymousAdviceSend> {
  List<Advice> adviceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    readCloud();
    super.initState();
  }

  Future<void> readCloud() async {
    //*Grab User Advices from firestore
    final user = AuthService.Firebase().currentUser!;
    //Todo remove this
    final sentAdviceList = await CloudStorage(user: user).getSentAdviceIDs();
    (await CloudStorage(user: user).getAdviceList()).forEach((advice) {
      if (sentAdviceList.contains(advice.id)) {
      } else {
        adviceList.add(advice);
      }
    });

    devtools.log(adviceList[0].toString());
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
        title: Text("Anonymous Advice"),
      ),
      body: _isLoading ? BuildLoading(context) : BuildListView(context),
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
