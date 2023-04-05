import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/MainUI/AnonymousAdvice/anonymous_advice_others.dart';
import 'package:sc_beta1/Views/MainUI/AnonymousAdvice/reply_template.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as devtools show log;

import '../../../constants/ui_consts.dart';
import 'advice_template.dart';

class AnonymousAdviceAskReadReply extends StatefulWidget {
  final Reply reply;
  const AnonymousAdviceAskReadReply({super.key, required this.reply});

  @override
  State<AnonymousAdviceAskReadReply> createState() =>
      _AnonymousAdviceAskReadReplyState();
}

class _AnonymousAdviceAskReadReplyState
    extends State<AnonymousAdviceAskReadReply> {
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    readCloud();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> readCloud() async {}

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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(children: [
              //! User's Original Advice Box
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Your question:",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: textHeaderColor)),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                constraints: BoxConstraints(
                    minHeight: 100, maxHeight: 100, minWidth: double.infinity),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(20),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  border: const Border.fromBorderSide(
                      BorderSide(width: 3, color: Color(0xFF33272a))),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.reply.adviceText,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Someone replied:",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: textHeaderColor)),
              ),
              const SizedBox(
                height: 10,
              ),
              //! Other User ReplyBox
              //! User's Original Advice Box
              Container(
                constraints: BoxConstraints(
                    minHeight: 250, maxHeight: 250, minWidth: double.infinity),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(20),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  border: const Border.fromBorderSide(
                      BorderSide(width: 3, color: Color(0xFF33272a))),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.reply.text,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 25,
                    ),
                    Text(
                      "${widget.reply.gender}, ${widget.reply.age}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> sendButtonPressed() async {}
}
