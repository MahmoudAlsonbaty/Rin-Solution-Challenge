import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../../constants/ui_consts.dart';
import 'article_template.dart';
import 'dart:developer' as devtools show log;

class readArticle extends StatefulWidget {
  final Article article;
  const readArticle({super.key, required this.article});

  @override
  State<readArticle> createState() => _readArticleState();
}

class _readArticleState extends State<readArticle> {
  late final articleText;
  @override
  void initState() {
    articleText = widget.article.text.replaceAll("\\n", "\n");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.article.Title,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Image.network(
              widget.article.image_url,
              fit: BoxFit.fill,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 10)),
              Text(
                widget.article.Title,
                style: TextStyle(
                    color: textHeaderColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 10)),
              Icon(Icons.person),
              SizedBox(
                width: 2,
              ),
              Text(widget.article.Author),
              Icon(
                Icons.verified,
                size: 15,
              ),
            ],
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(10.0),
            child: SingleChildScrollView(child: Text(articleText)),
          )),
        ],
      ),
    );
  }
}
