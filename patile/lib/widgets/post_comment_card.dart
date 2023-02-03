// ignore_for_file: must_be_immutable, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patile/blocs/widget_blocs/comment_text_cubits.dart';
import 'package:patile/cores/firebase_services/firestore_services/social_media_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/local_storage_services/secure_local_storage.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCommentCardPage extends StatelessWidget {
  DocumentSnapshot doc;
  TextEditingController textEditingController;
  PostCommentCardPage(
      {Key? key, required this.doc, required this.textEditingController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ParentCommentIdCubit()),
        BlocProvider(create: (context) => ShowAllChildCommentsCubit()),
      ],
      child: PostCommentCard(
          doc: doc, textEditingController: textEditingController),
    );
  }
}

class PostCommentCard extends StatelessWidget {
  DocumentSnapshot doc;
  TextEditingController textEditingController;
  PostCommentCard(
      {Key? key, required this.doc, required this.textEditingController})
      : super(key: key);

  UserLocal? userLocal;
  Vet? vet;

  String username = "";
  String comment = "";
  String time = "";

  @override
  Widget build(BuildContext context) {
    return commentItem(context, doc);
  }

  commentItem(BuildContext context, DocumentSnapshot doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 0,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColorLight.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: commentBody(3, doc),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: SocialMediaFireStoreServices()
                  .getAllChildCommentsByPostAndParentId(
                      doc.get('postId'), doc.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  );
                }

                if (snapshot.data!.size == 0) {
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  );
                }

                return BlocBuilder<ShowAllChildCommentsCubit, bool>(
                  builder: (context, state) {
                    if (!state) {
                      return InkWell(
                        onTap: () {
                          context
                              .read<ShowAllChildCommentsCubit>()
                              .changeShowState(!state);
                        },
                        child: Center(
                          child: Text(
                              '${snapshot.data!.size} yorumun tamamını göster'),
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.size,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 15.0, top: 5),
                                child: Container(
                                  width: double.infinity,
                                  height: 80,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColorDark),
                                  child: Container(
                                    width: double.infinity,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColorLight
                                              .withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: commentBody(
                                        10, snapshot.data!.docs[index]),
                                  ),
                                ),
                              );
                            },
                          ),
                          InkWell(
                            onTap: () {
                              context
                                  .read<ShowAllChildCommentsCubit>()
                                  .changeShowState(!state);
                            },
                            child: const Center(
                              child: Text('Yorumları gizle'),
                            ),
                          )
                        ],
                      );
                    }
                  },
                );
              }),
        ],
      ),
    );
  }

  FutureBuilder<dynamic> commentBody(double leftPadding, DocumentSnapshot doc) {
    return FutureBuilder<String>(
      future: getUserOrVet(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox();
        }
        if (snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(left: leftPadding),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  radius: 30,
                  child: !snapshot.hasData
                      ? const CircularProgressIndicator()
                      : CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage: NetworkImage(snapshot.data!),
                          radius: 27,
                        ),
                ),
                !snapshot.hasData
                    ? const SizedBox()
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Text(
                                username,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(doc.get('content')),
                              ),
                            ),
                            leftPadding == 3
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        BlocBuilder<ParentCommentIdCubit,
                                            String>(
                                          builder: (context, state) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (state == doc.id) {
                                                  context
                                                      .read<
                                                          ParentCommentIdCubit>()
                                                      .changeParentCommentId(
                                                          "");
                                                  SecureLocalStorage()
                                                      .setParentCommentId("");
                                                } else {
                                                  context
                                                      .read<
                                                          ParentCommentIdCubit>()
                                                      .changeParentCommentId(
                                                          doc.id);
                                                  SecureLocalStorage()
                                                      .setParentCommentId(
                                                          doc.id);
                                                }
                                              },
                                              child: Text(
                                                state == doc.id
                                                    ? 'Yanıtlama'
                                                    : 'Yanıtla',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            );
                                          },
                                        ),
                                        Text(
                                          timeago.format(
                                              doc.get('createdTime').toDate(),
                                              locale: "tr"),
                                        )
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    height: 0,
                                    width: 0,
                                  )
                          ],
                        ),
                      ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<String> getUserOrVet() async {
    String url =
        "https://firebasestorage.googleapis.com/v0/b/patilefiredb.appspot.com/o/images%2FsystemImages%2Fnon_user.jpg?alt=media&token=16b877a1-1ac4-458b-b40a-463bccf22806";

    try {
      userLocal = await UserAndVetFirestoreServices()
          .getUserButNotNull(doc.get('publishedUserId'));
      url = userLocal!.pphoto;
      username = userLocal!.username;
    } catch (ex) {}
    try {
      vet = await UserAndVetFirestoreServices()
          .getVetButNotNull(doc.get('publishedUserId'));
      url = vet!.pphoto;
      username = vet!.clinicName;
    } catch (ex) {}
    return url;
  }
}
