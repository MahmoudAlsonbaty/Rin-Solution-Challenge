import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/MainUI/Articles/articles_view.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';

import '../../../constants/ui_consts.dart';
import 'dart:developer' as devtools show log;

import 'articles_ai_view.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  late final TextEditingController _textController;
  final formKey = GlobalKey<FormState>();

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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              //!Title
              Text(
                "Write down how you feel",
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
                      hintText: "Don't worry this is a safe zone",
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
                    SubmitButtonPressed(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: messageButtonColor,
                      shape: const StadiumBorder(),
                      side: BorderSide(width: 1)),
                  child: const Text("Submit",
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
                  "We use a simple text analysis algorithm to analyze your text and show relevant articles, No data is collected and your input is processed locally i.e. no data is uploaded to the cloud",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textHeaderColor,
                  )),
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

  List<String> depressionKeywords = [
    "Sad",
    "Hopeless",
    "Worthless",
    "Helpless",
    "Empty",
    "Fatigued",
    "Tired",
    "Sleep problems",
    "Insomnia",
    "Oversleeping",
    "Loss of interest",
    "Anhedonia",
    "Guilt",
    "Irritability",
    "Restlessness",
    "Anxiety",
    "Suicidal thoughts",
    "Self-harm",
    "Crying",
    "Appetite changes",
    "Weight gain",
    "Weight loss",
    "Concentration problems",
    "Indecision",
    "Lack of motivation",
    "Low self-esteem",
    "Social withdrawal",
    "Isolation",
    "Pessimism",
  ];
  List<String> PTSDKeywords = [
    "Flashbacks",
    "Nightmares",
    "Avoidance",
    "Hypervigilance",
    "Triggers",
    "Panic attacks",
    "Intrusive thoughts",
    "Emotional numbing",
    "Irritability",
    "Sleep disturbances",
    "Fear",
    "Anxiety",
    "Guilt",
    "Shame",
    "Isolation",
    "Difficulty concentrating",
    "Loss of interest in activities",
    "Feeling disconnected from others",
    "Self-blame",
    "Anger",
  ];
  List<String> anxietyKeywords = [
    "Worry",
    "Panic attacks",
    "Nervousness",
    "Fear",
    "Restlessness",
    "Irritability",
    "Avoidance",
    "Obsessive thoughts",
    "Compulsive behaviors",
    "Excessive sweating",
    "Trembling or shaking",
    "Rapid heartbeat",
    "Shortness of breath",
    "Chest pain or tightness",
    "Dizziness or lightheadedness",
    "Headaches",
    "Difficulty concentrating",
    "Sleep disturbances",
    "Fatigue",
    "Muscle tension",
    "stiffness",
  ];

  void SubmitButtonPressed(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final userInput = _textController.text.toLowerCase();
    List<String> filters = [];
    depressionKeywords.forEach((word) {
      if (userInput.contains(word.toLowerCase())) {
        if (!filters.contains("Depression")) {
          filters.add("Depression");
        }
      }
    });
    PTSDKeywords.forEach((word) {
      if (userInput.contains(word.toLowerCase())) {
        if (!filters.contains("PTSD")) {
          filters.add("PTSD");
        }
      }
    });
    anxietyKeywords.forEach((word) {
      if (userInput.contains(word.toLowerCase())) {
        if (!filters.contains("anxiety")) {
          filters.add("anxiety");
        }
      }
    });
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => BrowseArticleAiScreen(
                searchFilters: filters,
              )),
    );
  }
}
