import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sc_beta1/Views/MainUI/AnonymousAdvice/ask_read.dart';
import 'package:sc_beta1/Views/MainUI/AnonymousAdvice/ask_write.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';
import 'dart:developer' as devtools show log;

import '../../../constants/ui_consts.dart';
import 'advice_template.dart';
import 'anonymous_advice_others.dart';

class AnonymousAdviceAskNavigation extends StatefulWidget {
  const AnonymousAdviceAskNavigation({super.key});

  @override
  State<AnonymousAdviceAskNavigation> createState() =>
      _AnonymousAdviceAskNavigationState();
}

class _AnonymousAdviceAskNavigationState
    extends State<AnonymousAdviceAskNavigation> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
      body: Container(
        constraints: const BoxConstraints(
            minWidth: double.infinity, minHeight: double.infinity),
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: ListView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                switch (index) {
                  case 0:
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const AnonymousAdviceAskWrite();
                    }));
                    break;
                  case 1:
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const AnonymousAdviceAskRead();
                    }));
                    break;
                }
              },
              child: Card(
                margin: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: aiTextMinimalColor),
                    borderRadius: BorderRadius.circular(30)),
                semanticContainer: true,
                elevation: 7,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          bottomSheetButtonColor.withAlpha(150),
                          bottomSheetColor,
                        ],
                      )),
                  height: 100,
                  width: 150,
                  child: Center(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Icon(
                          index == 0 ? Icons.edit_note : Icons.library_books,
                          size: 50,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          index == 0 ? "Ask for advice" : "Read Replies",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: textHeaderColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
