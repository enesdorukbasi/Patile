// ignore_for_file: must_be_immutable, empty_catches

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/comment_text_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/cores/firebase_services/firestore_services/social_media_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/local_storage_services/secure_local_storage.dart';
import 'package:patile/models/firebase_models/post.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/carousel_images.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/views/profile_pages/profile_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/post_comment_card.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;

class SocialMediaPostPage extends StatelessWidget {
  Post post;
  String activeUserId;

  SocialMediaPostPage(
      {Key? key, required this.post, required this.activeUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ParentCommentIdCubit()),
        BlocProvider(create: (context) => CarouselIndexChangeCubits()),
      ],
      child: SocialMediaPost(post: post, activeUserId: activeUserId),
    );
  }
}

class SocialMediaPost extends StatelessWidget {
  Post post;
  Size? size;
  bool isNotOk = true;
  UserLocal? userLocal;
  Vet? vet;
  SolidController solidController = SolidController();
  TextEditingController textEditingController = TextEditingController();

  String username = "", nameSurname = "";

  String activeUserId;

  SocialMediaPost({Key? key, required this.post, required this.activeUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size!.height * 0.02,
        vertical: size!.height * 0.015,
      ),
      child: Container(
        width: size!.width,
        height: !isNotOk ? size!.height * 0.4 : size!.height * 0.46,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: size!.height * 0.01,
            bottom: size!.height * 0.01,
          ),
          child: _postBody(context),
        ),
      ),
    );
  }

  Widget _postBody(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: getUserOrVet(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
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
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!),
                        backgroundColor: Colors.grey,
                        radius: 27,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        nameSurname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  post.publishedUserId == activeUserId
                      ? PopupMenuButton<String>(
                          padding: const EdgeInsets.all(0),
                          icon: const FaIcon(
                            FontAwesomeIcons.ellipsisVertical,
                            color: Colors.white,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'Gönderiyi Sil':
                                SocialMediaFireStoreServices()
                                    .deletePost(post.id);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Gönderiyi Sil'}.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        )
                      : Text(
                          timeago.format(post.createdTime.toDate(),
                              locale: "tr"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
        Divider(
          color: Colors.white.withOpacity(0.7),
          thickness: 1.5,
        ),
        _postMiddleLine(context),
        _postBottomLine(context),
      ],
    );
  }

  Padding _postBottomLine(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: size!.height * 0.015),
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                        stream: SocialMediaFireStoreServices().userIsLikePost(
                            postId: post.id, userId: activeUserId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 0,
                              width: 0,
                            );
                          }

                          bool isLiked = snapshot.data!.exists;
                          return IconButton(
                            onPressed: () {
                              if (isLiked) {
                                SocialMediaFireStoreServices().unlikePost(
                                    postId: post.id, userId: activeUserId);
                              } else {
                                SocialMediaFireStoreServices().likePost(
                                    postId: post.id, userId: activeUserId);
                              }
                            },
                            icon: isLiked
                                ? Icon(
                                    Icons.favorite,
                                    color: Theme.of(context).primaryColorDark,
                                  )
                                : const FaIcon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                          );
                        }),
                    SizedBox(width: size!.width * 0.05),
                    StreamBuilder<QuerySnapshot>(
                        stream: SocialMediaFireStoreServices()
                            .getLikesCountByPostId(post.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 0,
                              width: 0,
                            );
                          }

                          return Text(
                            '${snapshot.data!.size} Beğeni',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          );
                        }),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    bottomSheet(context);
                  },
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.comment,
                        color: Colors.white,
                      ),
                      SizedBox(width: size!.width * 0.05),
                      const Text(
                        'Yorumlar',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          !isNotOk
              ? const SizedBox(height: 0)
              : SizedBox(height: size!.height * 0.01),
          !isNotOk
              ? const SizedBox(height: 0)
              : Text(
                  post.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }

  Container _postMiddleLine(BuildContext buildContext) {
    List<String> images = [];
    images.add(post.imageOneUrl);
    images.add(post.imageTwoUrl);
    images.add(post.imageThreeUrl);
    int imageIndex = 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: size!.height * 0),
      width: double.infinity,
      height: size!.height * 0.23,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(buildContext).primaryColor,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CarouselImages().AdvertImagesCarousel(
                    buildContext, images, size!.height * 0.2171),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0.5,
                  child: BlocBuilder<CarouselIndexChangeCubits, int>(
                    builder: (context, state) {
                      return CarouselImages().PostCarouselIndexControl(
                        images,
                        state,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row _postTopLine(BuildContext context, String url) {
    // String clinicnameOrUsername =
    //     vet != null ? vet!.clinicName : userLocal!.username;
    // String nameSurname =
    //     vet != null ? "" : "${userLocal!.name} ${userLocal!.surname}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
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
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: CircleAvatar(
              backgroundImage: NetworkImage(url),
              backgroundColor: Colors.grey,
              radius: 27,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vet != null ? vet!.clinicName : userLocal!.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Text(
            //   nameSurname,
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold,
            //   ),
            // )
          ],
        ),
        post.publishedUserId == activeUserId
            ? PopupMenuButton<String>(
                padding: const EdgeInsets.all(0),
                icon: const FaIcon(
                  FontAwesomeIcons.ellipsisVertical,
                  color: Colors.white,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'Gönderiyi Sil':
                      SocialMediaFireStoreServices().deletePost(post.id);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Gönderiyi Sil'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )
            : Text(
                timeago.format(post.createdTime.toDate(), locale: "tr"),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }

  Future<String> getUserOrVet() async {
    String url =
        "https://firebasestorage.googleapis.com/v0/b/patilefiredb.appspot.com/o/images%2FsystemImages%2Fnon_user.jpg?alt=media&token=16b877a1-1ac4-458b-b40a-463bccf22806";
    try {
      userLocal = await UserAndVetFirestoreServices()
          .getUserButNotNull(post.publishedUserId);
      url = userLocal!.pphoto;
      username = userLocal!.username;
      nameSurname = "${userLocal!.name} ${userLocal!.surname}";
    } catch (ex) {}
    try {
      vet = await UserAndVetFirestoreServices()
          .getVetButNotNull(post.publishedUserId);
      url = vet!.pphoto;
      username = vet!.clinicName;
      nameSurname = "";
    } catch (ex) {}
    return url;
  }

  bottomSheet(BuildContext context) {
    context.read<ParentCommentIdCubit>().changeParentCommentId("");
    SecureLocalStorage().setParentCommentId("");
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              padding: EdgeInsets.symmetric(
                vertical: size!.height * 0.01,
                horizontal: size!.width * 0.0,
              ),
              child: _bottomSheetBody(context)),
        );
      },
    );
  }

  Widget _bottomSheetBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: size!.height * 0.01),
        // IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: FaIcon(
        //     Icons.arrow_drop_down_circle_sharp,
        //     color: Theme.of(context).primaryColorDark,
        //   ),
        // ),
        SizedBox(
          height: size!.height * 0.525,
          child: StreamBuilder<QuerySnapshot>(
              stream:
                  SocialMediaFireStoreServices().getAllCommentByPostId(post.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CustomProgressIndicator();
                }

                if (snapshot.data!.size == 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Center(
                        child: Text(
                          'Bu göderiye henüz yorum yapılmamış.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.size,
                  itemBuilder: (context, index) {
                    return PostCommentCardPage(
                        doc: snapshot.data!.docs[index],
                        textEditingController: textEditingController);
                  },
                );
              }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: commentBody(context),
        )
      ],
    );
  }

  Align commentBody(BuildContext buildContext) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          TextFormField(
            controller: textEditingController,
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(55),
            ],
            decoration: CustomInputDecorations().inputDecoration2(
                buildContext,
                'Yorum Yap',
                null,
                IconButton(
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: 1,
                  ),
                  onPressed: () async {
                    if (textEditingController.text != "") {
                      String? parentCommentId =
                          await SecureLocalStorage().getParentCommentId();

                      if (parentCommentId!.isEmpty) {
                        SocialMediaFireStoreServices().createCommentPost(
                          post.id,
                          textEditingController.text,
                          activeUserId,
                        );
                      } else {
                        SocialMediaFireStoreServices().createChildCommentPost(
                          post.id,
                          textEditingController.text,
                          activeUserId,
                          parentCommentId,
                        );
                      }
                      textEditingController.text = "";
                    }
                  },
                  icon: FaIcon(
                    Icons.send,
                    color: Theme.of(buildContext).primaryColorDark,
                    size: size!.height * 0.06,
                  ),
                )),
          )
        ],
      ),
    );
  }
}
