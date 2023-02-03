// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/list_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/social_media_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/post.dart';
import 'package:patile/views/social_media_pages/post_pages/post_create_page.dart';
import 'package:patile/widgets/custom_drawer.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/mixin_future_builder.dart';
import 'package:patile/widgets/social_media_post.dart';
import 'package:provider/provider.dart';

class SocialMediaMainPage extends StatelessWidget {
  const SocialMediaMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RefreshStateCubit()),
      ],
      child: SocialMediaMainView(),
    );
  }
}

class SocialMediaMainView extends StatelessWidget {
  Size? size;
  String activeUserId = "";

  SocialMediaMainView({Key? key}) : super(key: key);

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    size = MediaQuery.of(context).size;
    final GlobalKey<ScaffoldState> key = GlobalKey();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: key,
      drawer: CustomDrawer(),
      appBar: _appBar(context, key),
      body: _socialMediaMainBody(context),
    );
  }

  AppBar _appBar(BuildContext context, GlobalKey<ScaffoldState> key) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Sosyal Ağ',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: FaIcon(
            Icons.camera_enhance,
            color: Theme.of(context).primaryColor,
            size: size!.height * 0.035,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PostCreatePage()));
          },
        ),
      ],
      leading: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.bars,
          color: Theme.of(context).primaryColor,
          size: size!.height * 0.035,
        ),
        onPressed: () {
          key.currentState!.openDrawer();
        },
      ),
    );
  }

  Widget _socialMediaMainBody(BuildContext context) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      color: Colors.white,
      backgroundColor: Theme.of(context).primaryColorDark,
      strokeWidth: 4.0,
      onRefresh: () async {
        context.read<RefreshStateCubit>().refreshState(true);
        return Future<void>.delayed(const Duration(seconds: 2));
      },
      child: BlocBuilder<RefreshStateCubit, bool>(
        builder: (context, state) {
          return FutureBuilder<List<String>>(
            future: UserAndVetFirestoreServices()
                .getFollowingUserOrVet(currentUserId: activeUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CustomProgressIndicator();
              }

              List<String> followingUsers = snapshot.data!;

              if (followingUsers.isEmpty) {
                return Center(
                  child: Text(
                    "Kullanıcılarla takipleşerek anasayfanızı doldurabilirsiniz.",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return MixinFutureBuilder(
                future: UserAndVetFirestoreServices()
                    .getFollowingUserOrVet(currentUserId: activeUserId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CustomProgressIndicator();
                  }

                  List<String> followingUsers = snapshot.data!;

                  if (followingUsers.isEmpty) {
                    return Center(
                      child: Text(
                        "Kullanıcılarla takipleşerek anasayfanızı doldurabilirsiniz.",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return FutureBuilder<List<Post>>(
                    future: SocialMediaFireStoreServices()
                        .getAllPostsByFilterUsers(followingUsers),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Birşeyler ters gitti.');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CustomProgressIndicator();
                      }
                      List<Post> posts = [];
                      posts = snapshot.data!;
                      context.read<RefreshStateCubit>().refreshState(false);
                      if (posts.isNotEmpty) {
                        return SizedBox(
                          height: size!.height * 0.9,
                          width: double.infinity,
                          child: ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              Post post = posts[index];
                              if (followingUsers
                                  .contains(post.publishedUserId)) {
                                return SocialMediaPostPage(
                                  post: post,
                                  activeUserId: activeUserId,
                                );
                              } else {
                                return const SizedBox(height: 0);
                              }
                            },
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            "Gönderi bulunamadı.",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
