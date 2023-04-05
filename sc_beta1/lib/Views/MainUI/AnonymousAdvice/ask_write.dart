import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/MainUI/Articles/articles_view.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';

import '../../../constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

class AnonymousAdviceAskWrite extends StatefulWidget {
  const AnonymousAdviceAskWrite({super.key});

  @override
  State<AnonymousAdviceAskWrite> createState() =>
      _AnonymousAdviceAskWriteState();
}

class _AnonymousAdviceAskWriteState extends State<AnonymousAdviceAskWrite> {
  late final TextEditingController _textController;
  final formKey = GlobalKey<FormState>();
  bool sendButtonClickable = true;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
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
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Ai Assistant",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          //color: bottomSheetColor,
          gradient: backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                //!Title
                Text(
                  "Write your message",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      color: textHeaderColor,
                      fontWeight: FontWeight.bold),
                ),
                //!Field
                Padding(padding: EdgeInsets.only(top: 17)),
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
                        hintText: "Type here...",
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
                //! How does it work
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          howDoesThisWorkButtonPressed(context);
                        },
                        child: Text(
                          "How does this work?",
                          style: TextStyle(
                              fontSize: 15,
                              color: aiTextMinimalColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (sendButtonClickable) {
                        SubmitButtonPressed(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: messageButtonColor,
                        shape: const StadiumBorder(),
                        side: BorderSide(width: 1)),
                    child: const Text("Send",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textHeaderColor,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void howDoesThisWorkButtonPressed(BuildContext context) {
    OverLayScreen().show(
        context: context,
        display: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                "Your message will be shown to random people using the app \nWe don't show who wrote the message but we show the gender and age for context\nWhen people reply to your message you will be able to see their age and gender too",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textHeaderColor,
                ),
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () {
                  OverLayScreen().hide();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: registerLoginButtonColor,
                    shape: const StadiumBorder(),
                    side: BorderSide(width: 1)),
                child: const Text("OK",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    )),
              ),
            ],
          ),
        ));
  }

  Future<void> SubmitButtonPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    OverLayScreen().showLoading(context: context, text: "Loading");
    final user = AuthService.Firebase().currentUser!;
    CloudStorage(user: user).addAdvice(text: _textController.text);
    OverLayScreen().hide();
    sendButtonClickable = false;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Message was sent'),
    ));
    Navigator.of(context).pop();
  }
}
