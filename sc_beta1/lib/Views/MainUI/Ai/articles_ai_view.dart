import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sc_beta1/Overlays/overlays.dart';
import 'package:sc_beta1/Views/MainUI/Articles/article_template.dart';
import 'package:sc_beta1/Views/MainUI/Articles/read_article.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/cloud_storage/firebase_cloud_storage.dart';
import 'dart:developer' as devtools show log;

import '../../../constants/ui_consts.dart';

class BrowseArticleAiScreen extends StatefulWidget {
  final List<String> searchFilters;
  const BrowseArticleAiScreen({super.key, required this.searchFilters});

  @override
  State<BrowseArticleAiScreen> createState() => _BrowseArticleAiScreenState();
}

class _BrowseArticleAiScreenState extends State<BrowseArticleAiScreen> {
  List<Article> cloudArticleList = [];
  List<Article> articleList = [];
  bool _isLoading = true;
  final containerKey = GlobalKey();

  void filterList() {
    List<String> searchFilters = widget.searchFilters;
    //Add the chip filter values to search filters
    final List<Article> newArticleList = [];
    cloudArticleList.forEach((currentArticle) {
      bool accepted = false;
      searchFilters.forEach((filterTag) {
        filterTag = filterTag.toLowerCase();
        if (currentArticle.Title.toLowerCase().contains(filterTag)) {
          if (!accepted) {
            newArticleList.add(currentArticle);
            accepted = true;
          }
        }
        if (currentArticle.tags.toLowerCase().contains(filterTag)) {
          if (!accepted) {
            newArticleList.add(currentArticle);
            accepted = true;
          }
        }
        if (currentArticle.Author.toLowerCase().contains(filterTag)) {
          if (!accepted) {
            newArticleList.add(currentArticle);
            accepted = true;
          }
        }
      });
    });
    setState(() {
      articleList = newArticleList;
    });
  }

  @override
  void initState() {
    readCloud();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> readCloud() async {
    //*Grab Articles from firestore
    final user = AuthService.Firebase().currentUser!;
    cloudArticleList = await CloudStorage(user: user).getArticleList();
    filterList();
    setState(() {
      _isLoading = false;
    });
  }

  Widget BuildListView(BuildContext ctx) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: articleList.length,
      itemBuilder: ((context, index) {
        return ArticleCard(context, articleList[index]);
      }),
    );
  }

  Widget BuildLoading(BuildContext ctx) {
    return Container(
      constraints: const BoxConstraints(
          minWidth: double.infinity, minHeight: double.infinity),
      decoration: const BoxDecoration(
        gradient: backgroundGradient,
      ),
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
            "Browse Articles",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Container(
          constraints: const BoxConstraints(
              minWidth: double.infinity, minHeight: double.infinity),
          decoration: const BoxDecoration(
            gradient: backgroundGradient,
          ),
          child: _isLoading
              ? BuildLoading(context)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //!Actual Article list
                    BuildListView(context),
                  ],
                ),
        ));
  }

  /* void pressedReply() {
    String title = "gd";
    String Author = " f";
    String text = " ";
    String image = " ";
    bool verified = true;
    final user = AuthService.Firebase().currentUser!;

    CloudStorage(user: user).addArticle(
        text: text,
        Title: title,
        Author: Author,
        verified: verified,
        image_url: image);

    setState(() {});
  } */

  Widget ArticleCard(BuildContext context, Article article) {
    final containerKey = GlobalKey();
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => readArticle(
                  article: article,
                )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: messageBackgroundColor,
        elevation: 7,
        margin: const EdgeInsets.all(15),
        //you can use an InkWell
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: Image.network(article.image_url))
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Text(
                article.Title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(article.Author),
                  const Icon(
                    Icons.verified,
                    size: 15,
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
          ],
        ),
      ),
    );
  }
}
