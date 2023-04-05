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

class AnonymousAdviceOthersReply extends StatefulWidget {
  final Advice advice;
  final Function myParentFunction;
  const AnonymousAdviceOthersReply(
      {super.key, required this.advice, required this.myParentFunction});

  @override
  State<AnonymousAdviceOthersReply> createState() =>
      _AnonymousAdviceOthersReplyState();
}

class _AnonymousAdviceOthersReplyState
    extends State<AnonymousAdviceOthersReply> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;
  @override
  void initState() {
    _textController = TextEditingController();
    readCloud();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 10,
            ),
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
                    widget.advice.text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
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
                    "${widget.advice.gender}, ${widget.advice.age}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            //! User Reply
            Form(
              key: formKey,
              child: TextFormField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                validator: (String? text) {
                  if (text != null && text.isNotEmpty) {
                    return null;
                  } else {
                    return "*Required Field";
                  }
                },
                onFieldSubmitted: (value) {
                  formKey.currentState!.validate();
                },
                minLines: 7,
                maxLines: 7,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: aiTextForegroundColor,
                    contentPadding: const EdgeInsets.all(15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Write your reply here...",
                    hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            BorderSide(width: 3, color: Color(0xFF33272a))),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    )),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              //!   Cancel
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const StadiumBorder(),
                    side: BorderSide(width: 1)),
                child: const Text("Cancel",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    )),
              ),
              //!   Send
              ElevatedButton(
                onPressed: () {
                  sendButtonPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: const StadiumBorder(),
                  side: BorderSide(width: 1),
                ),
                child: const Text("Send",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    )),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> sendButtonPressed() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    OverLayScreen().showLoading(context: context, text: "Loading...");
    Reply reply = Reply(
        replyTo: widget.advice.id,
        adviceText: widget.advice.text,
        id: const Uuid().v1(),
        text: _textController.text,
        age: -1,
        gender: "");

    await CloudStorage(user: AuthService.Firebase().currentUser!)
        .sendReply(reply);
    OverLayScreen().hide();
    widget.myParentFunction(); //Refresh
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Message was sent'),
    ));
    Navigator.of(context).pop();
  }
}
