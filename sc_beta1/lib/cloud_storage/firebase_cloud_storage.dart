import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sc_beta1/Views/MainUI/AnonymousAdvice/advice_template.dart';
import 'package:sc_beta1/auth/auth_service.dart';
import 'package:sc_beta1/auth/auth_user.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as devtools show log;

import '../Views/MainUI/AnonymousAdvice/reply_template.dart';
import '../Views/MainUI/Articles/article_template.dart';
import '../auth/firebase_auth_provider.dart';
import 'cloud_constants.dart';

class CloudStorage {
  final AuthUser user;

  CloudStorage({required this.user});

  Future<bool> hasInfo() async {
    try {
      final info = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.id)
          .collection(dataCollection)
          .doc(basicInfoDocument)
          .get();
      devtools.log(
          "Checking path :$usersCollection / ${user.id} / $dataCollection / $basicInfoDocument");
      return info.exists;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateCreateInfo(
      {String? firstName,
      String? lastName,
      DateTime? birthDate,
      String? gender,
      String? password}) async {
    try {
      if (await hasInfo()) {
        //User has Info (Updating it)
        final info = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(basicInfoDocument);
        if (firstName != null) info.update({firstNameField: firstName});
        if (lastName != null) info.update({lastNameField: lastName});
        if (gender != null) info.update({genderField: gender});
        if (birthDate != null) info.update({birthDateField: birthDate});

        devtools.log("Cloud Storage: user had data and was updated");
      } else {
        //User Doesn't have info (Registering)
        final info = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(basicInfoDocument)
            .set({
          firstNameField: firstName ?? "",
          lastNameField: lastName ?? "",
          genderField: gender ?? "",
          birthDateField: birthDate ?? DateTime(0, 0),
        });

        devtools
            .log("Cloud Storage: user didn't have data, and it was uploaded");
      }

      if (password != null) {
        bool success =
            await AuthService.Firebase().setPassword(password: password);
        devtools.log("Cloud Storage: password update succefully? : $success");
        return false;
      }
      return true;
    } catch (e) {
      //Todo implement a fail safe
      rethrow;
    }
  }

  Future<List> getSentAdviceIDs() async {
    try {
      final info = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.id)
          .collection(dataCollection)
          .doc(sentAdvicesDocument)
          .get();

      if (info.exists) {
        return info.data()![adviceIdField];
      } else {
        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(sentAdvicesDocument)
            .set({adviceIdField: []});
        return [];
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<List> getSentReplyIDs() async {
    try {
      final info = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.id)
          .collection(dataCollection)
          .doc(sentRepliesDocument)
          .get();

      if (info.exists) {
        return info.data()![adviceIdField];
      } else {
        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(sentAdvicesDocument)
            .set({adviceIdField: [], userRepliesIdField: []});
        return [];
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Advice>> getAdviceList() async {
    try {
      final info = await FirebaseFirestore.instance
          .collection(adviceCollection)
          .doc(dataDocument)
          .collection(pendingAdvicesCollection)
          .get();

      List<Advice> currentAdviceList = [];
      final allData = info.docs.map((doc) => doc.data()).toList();
      allData.forEach(
        (data) {
          currentAdviceList.add(Advice(
              id: data[pendingAdviceIdField],
              text: data[pendingAdviceTextField],
              age: data[pendingAdviceAgeField],
              gender: data[pendingAdviceGenderField]));
        },
      );

      return currentAdviceList.reversed.toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Reply>> getRepliesList() async {
    try {
      List<Reply> currentRepliesList = [];
      var sentIDs = await getSentAdviceIDs();
      bool thereIsMore = true;
      int begin = 0, end = sentIDs.length;
      while (thereIsMore) {
        int stop = (begin + 10) > end ? end : begin + 10;
        final info = await FirebaseFirestore.instance
            .collection(adviceCollection)
            .doc(dataDocument)
            .collection(repliesCollection)
            .where(replyToField, whereIn: sentIDs.getRange(begin, stop))
            .get();

        final allData = info.docs.map((doc) => doc.data()).toList();
        allData.forEach(
          (data) {
            currentRepliesList.add(Reply(
                adviceText: data[replyAdviceTextField],
                replyTo: data[replyToField],
                id: data[replyIDField],
                text: data[replyTextField],
                age: data[replyAgeField],
                gender: data[replyGenderField]));
          },
        );

        begin += 10;
        if (stop == end) {
          thereIsMore = false;
        }
      }

      return currentRepliesList;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendReply(Reply reply) async {
    try {
      final info = await FirebaseFirestore.instance
          .collection(adviceCollection)
          .doc(dataDocument)
          .collection(repliesCollection)
          .doc();

      final userInfo = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.id)
          .collection(dataCollection)
          .doc(basicInfoDocument)
          .get();
      var userData = userInfo.data();
      Timestamp birthDate = userData![birthDateField];
      var gender = userData[genderField];
      int ageResult =
          DateTime.now().difference(birthDate.toDate()).inDays ~/ 365;

      info.set({
        replyAgeField: ageResult,
        replyAdviceTextField: reply.adviceText,
        replyToField: reply.replyTo,
        replyGenderField: gender,
        replyTextField: reply.text,
        replyIDField: reply.id
      });

      try {
        final userSentReply = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(sentRepliesDocument)
            .update({
          userRepliesIdField: FieldValue.arrayUnion([reply.id]),
          adviceIdField: FieldValue.arrayUnion([reply.replyTo])
        });
      } catch (_) {
        final userSentReply = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(sentRepliesDocument)
            .set({
          userRepliesIdField: FieldValue.arrayUnion([reply.id]),
          adviceIdField: FieldValue.arrayUnion([reply.replyTo])
        });
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Article>> getArticleList() async {
    try {
      final info =
          await FirebaseFirestore.instance.collection(articleCollection).get();

      List<Article> currentArticleList = [];
      final allData = info.docs.map((doc) => doc.data()).toList();
      allData.forEach(
        (data) {
          currentArticleList.add(Article(
              text: data[articleTextField],
              Author: data[articleAuthorField],
              Title: data[articleTitleField],
              verified: data[articleVerifiedField],
              image_url: data[articleImageURLField],
              tags: data[articleTagsField]));
        },
      );

      return currentArticleList;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> addArticle(
      {required String text,
      required String Title,
      required String Author,
      required bool verified,
      required String image_url,
      required String tags}) async {
    try {
      final info =
          await FirebaseFirestore.instance.collection(articleCollection).doc();

      info.set({
        articleImageURLField: image_url,
        articleTextField: text,
        articleTitleField: Title,
        articleVerifiedField: verified,
        articleAuthorField: Author,
        articleTagsField: tags
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<void> addAdvice({required String text}) async {
    //Todo remove the logs
    try {
      final userInfo = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.id)
          .collection(dataCollection)
          .doc(basicInfoDocument)
          .get();
      var userData = userInfo.data();
      Timestamp birthDate = userData![birthDateField];
      var gender = userData[genderField];
      int ageResult =
          DateTime.now().difference(birthDate.toDate()).inDays ~/ 365;

      var ID = Uuid().v1();

      devtools.log(" ID : ${ID}");

      final mainDoc = await FirebaseFirestore.instance
          .collection(adviceCollection)
          .doc(dataDocument)
          .collection(pendingAdvicesCollection)
          .doc();

      mainDoc.set({
        pendingAdviceIdField: ID,
        pendingAdviceAgeField: ageResult,
        pendingAdviceTextField: text,
        pendingAdviceGenderField: gender
      });

      //* Add the advice to the user sent advice list
      try {
        final userSentAdvice = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(sentAdvicesDocument)
            .update({
          adviceIdField: FieldValue.arrayUnion([ID])
        });
      } catch (_) {
        //user doesn't have sent Advice document
        final userSentAdvice = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(user.id)
            .collection(dataCollection)
            .doc(sentAdvicesDocument)
            .set({
          adviceIdField: FieldValue.arrayUnion([ID])
        });
      }
    } catch (_) {
      rethrow;
    }
  }
}
