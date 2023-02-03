// ignore_for_file: must_be_immutable, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/answer.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/views/profile_pages/profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnswerCard extends StatelessWidget {
  UserLocal? userLocal;
  Vet? vet;
  DocumentSnapshot answerDoc;

  Size? size;
  List<Widget> navPages = [];

  AnswerCard({super.key, required this.answerDoc});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size!.height * 0.01,
        horizontal: size!.width * 0.05,
      ),
      child: Container(
          height: size!.height * 0.085,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(20),
          ),
          // ignore: sort_child_properties_last
          child: _answerMainWidget(context)),
    );
  }

  _answerMainWidget(BuildContext context) {
    return Row(
      children: [
        _answerPublishedUser(context),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: size!.width * 0.05),
            child: Text(
              answerDoc.get('content'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: size!.width * 0.04),
            child: Text(
              timeago.format(answerDoc.get('createdTime').toDate(),
                  locale: "tr"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _answerPublishedUser(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserOrVet(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(left: size!.width * 0.05),
            child: InkWell(
              onTap: () {
                if (userLocal == null && vet == null) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userLocal: userLocal,
                      vet: vet,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(snapshot.data!),
              ),
            ),
          );
        }

        return const CircularProgressIndicator();
      },
    );
  }

  Future<String> getUserOrVet() async {
    String url;
    try {
      userLocal = await UserAndVetFirestoreServices()
          .getUserButNotNull(answerDoc.get('publishedUserId'));
      url = userLocal!.pphoto;
      return url;
    } catch (ex) {}
    try {
      vet = await UserAndVetFirestoreServices()
          .getVetButNotNull(answerDoc.get('publishedUserId'));
      url = vet!.pphoto;
      return url;
    } catch (ex) {}
    return "https://firebasestorage.googleapis.com/v0/b/patilefiredb.appspot.com/o/images%2FsystemImages%2Fnon_user.jpg?alt=media&token=16b877a1-1ac4-458b-b40a-463bccf22806";
  }
}
