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

class filterItem {
  String label;
  Color color;
  bool isSelected;
  String filterVal;

  filterItem(
      {required this.label,
      required this.color,
      required this.isSelected,
      required this.filterVal});
}

class BrowseArticleScreen extends StatefulWidget {
  const BrowseArticleScreen({super.key});

  @override
  State<BrowseArticleScreen> createState() => _BrowseArticleScreenState();
}

class _BrowseArticleScreenState extends State<BrowseArticleScreen> {
  List<Article> cloudArticleList = [];
  List<Article> articleList = [];
  bool _isLoading = true;
  final containerKey = GlobalKey();
  late final TextEditingController _searchController;

  final List<filterItem> _chipsList = [
    filterItem(
        label: "Anxiety",
        color: Colors.lightBlueAccent,
        isSelected: false,
        filterVal: "Anxiety"),
    filterItem(
        label: "Depression",
        color: Colors.blue,
        isSelected: false,
        filterVal: "Depression"),
    filterItem(
        label: "PTSD",
        color: Colors.lightBlue,
        isSelected: false,
        filterVal: "PTSD"),
    filterItem(
        label: "WHO",
        color: Colors.yellow,
        isSelected: false,
        filterVal: "World Health Organization"),
    filterItem(
        label: "APA",
        color: Colors.yellow,
        isSelected: false,
        filterVal: "American Psychological Association"),
  ];
  List<String> searchFilters = [];

  void filterList() {
    final String searchVal = _searchController.text.toLowerCase();

    //Add the chip filter values to search filters
    _chipsList.forEach((element) {
      if (element.isSelected) {
        if (!searchFilters.contains(element.label)) {
          searchFilters.add(element.filterVal);
        }
      } else {
        searchFilters.remove(element.filterVal);
      }
    });
    if (searchFilters.isEmpty && searchVal.isEmpty) {
      setState(() {
        articleList = cloudArticleList;
      });
      return;
    }
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
        if (searchVal.isNotEmpty) {
          if (currentArticle.Title.toLowerCase().contains(searchVal)) {
            if (!accepted) {
              newArticleList.add(currentArticle);
              accepted = true;
            }
          }

          if (currentArticle.tags.toLowerCase().contains(searchVal)) {
            if (!accepted) {
              newArticleList.add(currentArticle);
              accepted = true;
            }
          }

          if (currentArticle.Author.toLowerCase().contains(searchVal)) {
            if (!accepted) {
              newArticleList.add(currentArticle);
              accepted = true;
            }
          }
        }
      });
    });
    setState(() {
      articleList = newArticleList;
    });
  }

  List<Widget> filterChipsList() {
    List<Widget> chips = [];
    _chipsList.forEach((element) {
      Widget item = Padding(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: FilterChip(
          label: Text(element.label),
          labelStyle: const TextStyle(color: Colors.white, fontSize: 16),
          backgroundColor: element.color,
          selectedColor: element.color,
          elevation: 2,
          selected: element.isSelected,
          onSelected: (bool value) {
            setState(() {
              element.isSelected = value;

              filterList();
            });
          },
        ),
      );
      chips.add(item);
    });

    return chips;
  }

  @override
  void initState() {
    readCloud();
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> readCloud() async {
    //*Grab Articles from firestore
    final user = AuthService.Firebase().currentUser!;
    cloudArticleList = await CloudStorage(user: user).getArticleList();
    articleList = cloudArticleList;
    setState(() {
      _isLoading = false;
    });
  }

  Widget BuildListView(BuildContext ctx) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
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
                : SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //!Search Bar
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              devtools.log("Val changed, New : $value");
                              filterList();
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 15),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintText: "Search",
                                prefixIcon: Icon(Icons.search),
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w300),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                )),
                          ),
                        ),
                        //!Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 0,
                            direction: Axis.horizontal,
                            children: filterChipsList(),
                          ),
                        ),
                        //!Actual Article list
                        BuildListView(context),
                      ],
                    ),
                  )));
  }

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
