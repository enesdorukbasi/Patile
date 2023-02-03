// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/details_page_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/list_cubits.dart';
import 'package:patile/blocs/widget_blocs/profile_page_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/adoption_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/cure_type_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/social_media_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/adoption.dart';
import 'package:patile/models/firebase_models/cure_types.dart';
import 'package:patile/models/firebase_models/post.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/views/auth_pages/user_auth_pages/user_edit_page.dart';
import 'package:patile/views/auth_pages/vet_auth_pages/vet_edit_page.dart';
import 'package:patile/views/vet_pages/cures_pages/create_cure_page.dart';
import 'package:patile/widgets/adoption_card.dart';
import 'package:patile/widgets/cure_type_card.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/mixin_future_builder.dart';
import 'package:patile/widgets/social_media_post.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  UserLocal? userLocal;
  Vet? vet;

  ProfilePage({Key? key, this.userLocal, this.vet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => isLoadingCubit()),
      BlocProvider(create: (context) => RefreshStateCubit()),
      BlocProvider(create: (context) => NavbarCubit()),
      BlocProvider(create: (context) => StatusControl()),
      BlocProvider(create: (context) => IsClickedFollowButton())
    ], child: ProfileView(userLocal: userLocal, vet: vet));
  }
}

class ProfileView extends StatelessWidget {
  String _activeUserId = "";
  String _currentUserId = "";
  UserLocal? userLocal;
  Vet? vet;
  Size? size;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ProfileView({Key? key, this.userLocal, this.vet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    _activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    _currentUserId = userLocal != null ? userLocal!.id : vet!.id;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBars().transparentBackgroundAppBar(
        context,
        '',
        [
          vet != null
              ? (_currentUserId == _activeUserId
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'Profili Düzenle':
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => VetEditPage(vet: vet!),
                              ),
                            );
                            break;
                          case 'Tedavi Ekle':
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const CureTypeCreatePage(),
                            ));
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Profili Düzenle', 'Tedavi Ekle'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    )
                  : _followButtons())
              : (_currentUserId == _activeUserId
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'Profili Düzenle':
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserEditPage(userLocal: userLocal!),
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {
                          'Profili Düzenle',
                        }.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    )
                  : _followButtons())
        ],
        true,
        true,
        null,
      ),
      body: _body(context),
    );

    // return RefreshIndicator(
    //   key: refreshIndicatorKey,
    //   color: Colors.white,
    //   backgroundColor: Theme.of(context).primaryColorDark,
    //   strokeWidth: 4.0,
    //   onRefresh: () async {
    //     context.read<RefreshStateCubit>().refreshState(true);
    //     return Future<void>.delayed(const Duration(seconds: 2));
    //   },
    //   // ignore: avoid_unnecessary_containers
    //   child: Container(
    //     child: Scaffold(
    //       backgroundColor: Theme.of(context).primaryColorDark,
    //       appBar: AppBars().transparentBackgroundAppBar(
    //         context,
    //         '',
    //         [
    //           vet != null
    //               ? (_currentUserId == _activeUserId
    //                   ? PopupMenuButton<String>(
    //                       onSelected: (value) {
    //                         switch (value) {
    //                           case 'Profili Düzenle':
    //                             Navigator.of(context).push(
    //                               MaterialPageRoute(
    //                                 builder: (context) =>
    //                                     VetEditPage(vet: vet!),
    //                               ),
    //                             );
    //                             break;
    //                           case 'Tedavi Ekle':
    //                             Navigator.of(context).push(MaterialPageRoute(
    //                               builder: (context) =>
    //                                   const CureTypeCreatePage(),
    //                             ));
    //                             break;
    //                         }
    //                       },
    //                       itemBuilder: (BuildContext context) {
    //                         return {'Profili Düzenle', 'Tedavi Ekle'}
    //                             .map((String choice) {
    //                           return PopupMenuItem<String>(
    //                             value: choice,
    //                             child: Text(choice),
    //                           );
    //                         }).toList();
    //                       },
    //                     )
    //                   : _followButtons())
    //               : (_currentUserId == _activeUserId
    //                   ? PopupMenuButton<String>(
    //                       onSelected: (value) {
    //                         switch (value) {
    //                           case 'Profili Düzenle':
    //                             Navigator.of(context).push(
    //                               MaterialPageRoute(
    //                                 builder: (context) =>
    //                                     UserEditPage(userLocal: userLocal!),
    //                               ),
    //                             );
    //                             break;
    //                         }
    //                       },
    //                       itemBuilder: (BuildContext context) {
    //                         return {
    //                           'Profili Düzenle',
    //                         }.map((String choice) {
    //                           return PopupMenuItem<String>(
    //                             value: choice,
    //                             child: Text(choice),
    //                           );
    //                         }).toList();
    //                       },
    //                     )
    //                   : _followButtons())
    //         ],
    //         true,
    //         true,
    //         null,
    //       ),
    //       body: _body(context),
    //     ),
    //   ),
    // );
  }

  Widget _followButtons() {
    return BlocBuilder<IsClickedFollowButton, bool?>(
      builder: (context, state) {
        return FutureBuilder<bool>(
            future: UserAndVetFirestoreServices().isFollowingUser(
                currentUserId: _currentUserId, followerUserId: _activeUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!) {
                return TextButton(
                  onPressed: () {
                    UserAndVetFirestoreServices().unfollowingUserOrVet(
                        currentUserId: _currentUserId,
                        followerUserId: _activeUserId);
                    context.read<IsClickedFollowButton>().isFollowing(false);
                  },
                  child: const Text(
                    'Takipten Çık',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return TextButton(
                onPressed: () {
                  UserAndVetFirestoreServices().followingUserOrVet(
                      currentUserId: _currentUserId,
                      followerUserId: _activeUserId);
                  context.read<IsClickedFollowButton>().isFollowing(true);
                },
                child: const Text(
                  'Takip Et',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            });
      },
    );
  }

  Stack _body(BuildContext context) {
    return Stack(
      children: [
        _selectedItemInformations(context),
        _userInformationWidget(context),
      ],
    );
  }

  Padding _selectedItemInformations(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: size!.height * 0.2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size!.height * 0.03),
            topRight: Radius.circular(size!.height * 0.03),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: BlocBuilder<NavbarCubit, int>(
          builder: (context, state) {
            if (vet != null) {
              if (state == 0) {
                return _cureTypeByVet();
              } else if (state == 1) {
                return _postsByUser();
              } else if (state == 2) {
                return _adoptionsByUser();
              }
            } else {
              if (state == 0) {
                return _postsByUser();
              } else if (state == 1) {
                return _adoptionsByUser();
              }
            }

            return const SizedBox(height: 0);
          },
        ),
      ),
    );
  }

  Widget _userInformationWidget(BuildContext context) {
    return BlocBuilder<RefreshStateCubit, bool>(
      builder: (context, state) {
        return FutureBuilder<String>(
            future: getUserOrVet(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CustomProgressIndicator();
              }
              context.read<RefreshStateCubit>().refreshState(false);

              return Padding(
                padding: EdgeInsets.only(
                  top: size!.height * 0.04,
                  left: size!.width * 0.1,
                  right: size!.width * 0.1,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size!.height * 0.08,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: size!.height * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(size!.height * 0.01),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: size!.height * 0.04),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        userLocal != null
                                            ? "${userLocal!.name} ${userLocal!.surname}"
                                            : vet!.clinicName,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: size!.height * 0.025,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: BlocBuilder<NavbarCubit, int>(
                                builder: (context, state) {
                                  return _navbar(state, context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                BlocBuilder<IsClickedFollowButton, bool?>(
                                  builder: (context, state) {
                                    return FutureBuilder<List<String>>(
                                      future: UserAndVetFirestoreServices()
                                          .getFollowersUserOrVet(
                                              currentUserId: _currentUserId),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox(height: 0);
                                        }
                                        return Text(
                                          snapshot.data!.length.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: size!.height * 0.03,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                Text(
                                  'Takipçi',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: size!.width * 0.3,
                              height: size!.width * 0.3,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userLocal != null
                                        ? userLocal!.pphoto
                                        : vet!.pphoto,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<List<String>>(
                                    future: UserAndVetFirestoreServices()
                                        .getFollowingUserOrVet(
                                            currentUserId: _currentUserId),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox(height: 0);
                                      }

                                      return Text(
                                        snapshot.data!.length.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: size!.height * 0.03,
                                        ),
                                      );
                                    }),
                                Text(
                                  'Takip',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  Future<String> getUserOrVet() async {
    String url;
    if (userLocal != null) {
      userLocal =
          await UserAndVetFirestoreServices().getUserButNotNull(userLocal!.id);
      url = userLocal!.pphoto;
    } else {
      vet = await UserAndVetFirestoreServices().getVetButNotNull(vet!.id);
      url = vet!.pphoto;
    }
    return url;
  }

  NavigationBar _navbar(int state, BuildContext context) {
    if (vet != null) {
      return NavigationBar(
        selectedIndex: state,
        height: size!.height * 0.05,
        destinations: [
          IconButton(
              onPressed: () {
                context.read<NavbarCubit>().changePage(0);
              },
              icon: FaIcon(
                FontAwesomeIcons.staffSnake,
                color: state == 0
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight,
              )),
          IconButton(
              onPressed: () {
                context.read<NavbarCubit>().changePage(1);
              },
              icon: FaIcon(
                FontAwesomeIcons.photoFilm,
                color: state == 1
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight,
              )),
          IconButton(
              onPressed: () {
                context.read<NavbarCubit>().changePage(2);
              },
              icon: FaIcon(
                FontAwesomeIcons.paw,
                color: state == 2
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight,
              )),
        ],
      );
    } else {
      return NavigationBar(
        selectedIndex: state,
        height: size!.height * 0.05,
        destinations: [
          IconButton(
              onPressed: () {
                context.read<NavbarCubit>().changePage(0);
              },
              icon: FaIcon(
                FontAwesomeIcons.photoFilm,
                color: state == 0
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight,
              )),
          IconButton(
              onPressed: () {
                context.read<NavbarCubit>().changePage(1);
              },
              icon: FaIcon(
                FontAwesomeIcons.paw,
                color: state == 1
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight,
              )),
        ],
      );
    }
  }

  _postsByUser() {
    return MixinFutureBuilder(
      future:
          SocialMediaFireStoreServices().getAllPostsByUserId(_currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CustomProgressIndicator();
        }
        List<Post> posts = snapshot.data!;

        context.read<RefreshStateCubit>().refreshState(false);

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(
                  top: size!.height * 0.125,
                  bottom: 0,
                  left: 0,
                  right: 0,
                ),
                child: SocialMediaPostPage(
                    post: posts[index], activeUserId: _activeUserId),
              );
            }
            return SocialMediaPostPage(
              post: posts[index],
              activeUserId: _activeUserId,
            );
          },
        );
      },
    );

    return BlocBuilder<RefreshStateCubit, bool>(
      builder: (context, state) {
        return MixinFutureBuilder(
          future: SocialMediaFireStoreServices()
              .getAllPostsByUserId(_currentUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CustomProgressIndicator();
            }
            List<Post> posts = snapshot.data!;

            context.read<RefreshStateCubit>().refreshState(false);

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: size!.height * 0.125,
                      bottom: 0,
                      left: 0,
                      right: 0,
                    ),
                    child: SocialMediaPostPage(
                        post: posts[index], activeUserId: _activeUserId),
                  );
                }
                return SocialMediaPostPage(
                  post: posts[index],
                  activeUserId: _activeUserId,
                );
              },
            );
          },
        );
      },
    );
  }

  _adoptionsByUser() {
    return BlocBuilder<RefreshStateCubit, bool>(
      builder: (context, state) {
        return FutureBuilder<List<Adoption>>(
          future: AdoptionFirestoreServices()
              .getAllAdoptionsByUserId(_currentUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CustomProgressIndicator();
            }
            List<Adoption> adoptions = snapshot.data!;

            context.read<RefreshStateCubit>().refreshState(true);

            return ListView.builder(
              itemCount: adoptions.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(top: size!.height * 0.125),
                    child: AdoptionCard(adoption: adoptions[index]),
                  );
                }
                return AdoptionCard(adoption: adoptions[index]);
              },
            );
          },
        );
      },
    );
  }

  _cureTypeByVet() {
    return BlocBuilder<RefreshStateCubit, bool>(
      builder: (context, state) {
        return FutureBuilder<List<CureType>>(
          future: CureTypeFirestoreServices().getCureTypes(_currentUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CustomProgressIndicator();
            }
            List<CureType> cureTypes = snapshot.data!;

            context.read<RefreshStateCubit>().refreshState(true);

            return ListView.builder(
              itemCount: cureTypes.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(top: size!.height * 0.125),
                    child: CureTypeCard(
                      cureType: cureTypes[index],
                      profileId: vet!.id,
                    ),
                  );
                }
                return CureTypeCard(
                  cureType: cureTypes[index],
                  profileId: vet!.id,
                );
              },
            );
          },
        );
      },
    );
  }
}
