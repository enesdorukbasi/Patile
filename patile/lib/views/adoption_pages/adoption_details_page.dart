// ignore_for_file: must_be_immutable, use_build_context_synchronously, empty_catches

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/details_page_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/adoption_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/adoption.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/carousel_images.dart';
import 'package:patile/views/adoption_pages/adoption_edit_page.dart';
import 'package:patile/views/profile_pages/profile_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdoptionDetailsPage extends StatelessWidget {
  Adoption adoption;
  UserLocal? userLocal;
  Vet? vet;
  String activeUserId = "";

  AdoptionDetailsPage({Key? key, required this.adoption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CarouselIndexChangeCubits()),
        BlocProvider(create: (context) => NavPagesDetailsCubit()),
        BlocProvider(create: (context) => DetailsOk()),
        BlocProvider(create: (context) => UserInfoOk()),
      ],
      child: AdoptionDetailsView(
        adoption: adoption,
        userLocal: userLocal,
        vet: vet,
      ),
    );
  }
}

class AdoptionDetailsView extends StatelessWidget {
  Size? size;
  List<Widget> navPages = [];
  Adoption adoption;
  UserLocal? userLocal;
  Vet? vet;
  String activeUserId = "", username = "", phoneNo = "";

  AdoptionDetailsView(
      {Key? key, required this.adoption, this.userLocal, this.vet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    size = MediaQuery.of(context).size;
    List<Widget> actions = [
      IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AdoptionEditPage(
                adoption: adoption,
              ),
            ));
          },
          icon: const FaIcon(Icons.edit)),
      IconButton(
          onPressed: () async {
            await AdoptionFirestoreServices().deleteAdvert(adoption.id);
            Navigator.pop(context);
          },
          icon: const FaIcon(Icons.delete)),
    ];
    List<String> imageList = [];
    adoption.photoOneUrl != "" ? imageList.add(adoption.photoOneUrl) : null;
    adoption.photoTwoUrl != "" ? imageList.add(adoption.photoTwoUrl) : null;
    adoption.photoThreeUrl != "" ? imageList.add(adoption.photoThreeUrl) : null;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBars().transparentBackgroundAppBar(
        context,
        '',
        actions,
        true,
        false,
        null,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: size!.height * 0.0),
        children: [
          Container(
            height: size!.height * 0.45,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
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
            child: Column(
              children: [
                CarouselImages().AdvertImagesCarousel(
                    context, imageList, size!.height * 0.4),
                BlocBuilder<CarouselIndexChangeCubits, int>(
                  builder: (context, state) {
                    return CarouselImages()
                        .CarouselIndexControl(imageList, state);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: size!.height * 0.01),
          Center(
            child: Text(
              adoption.title.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: size!.height * 0.03,
                shadows: <Shadow>[
                  Shadow(
                    offset: const Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  Shadow(
                    offset: const Offset(1.0, 1.0),
                    blurRadius: 8.0,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: size!.height * 0.01),
          Container(
            height: size!.height * 0.495,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView(
              padding: EdgeInsets.only(top: size!.height * 0.02),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Yuva Arayan Bilgileri',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size!.height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        BlocBuilder<DetailsOk, bool>(
                          builder: (context, state) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () {
                                  context.read<DetailsOk>().isOkChange(!state);
                                },
                                icon: FaIcon(
                                  state
                                      ? Icons.arrow_drop_up_sharp
                                      : Icons.arrow_drop_down_sharp,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    SizedBox(height: size!.height * 0.01),
                    const Divider(
                      color: Colors.white,
                      thickness: 1.5,
                    ),
                    SizedBox(height: size!.height * 0.01),
                    Column(
                      children: [
                        BlocBuilder<DetailsOk, bool>(
                          builder: (context, state) {
                            return Visibility(
                              visible: state,
                              child: Column(
                                children: [
                                  _bodyInContent(),
                                  SizedBox(height: size!.height * 0.01),
                                  _bodyInMiddle(context),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: size!.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Paylaşan Kişi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size!.height * 0.02,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            BlocBuilder<UserInfoOk, bool>(
                              builder: (context, state) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      context
                                          .read<UserInfoOk>()
                                          .isOkChange(!state);
                                    },
                                    icon: FaIcon(
                                      state
                                          ? Icons.arrow_drop_up_sharp
                                          : Icons.arrow_drop_down_sharp,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        SizedBox(height: size!.height * 0.01),
                        const Divider(
                          color: Colors.white,
                          thickness: 1.5,
                        ),
                        SizedBox(height: size!.height * 0.01),
                        BlocBuilder<UserInfoOk, bool>(
                          builder: (context, state) {
                            return Visibility(
                                visible: state, child: _bodyInBottom(context));
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AutoSizeText _bodyInContent() {
    return AutoSizeText(
      adoption.content,
      style: TextStyle(
        color: Colors.white,
        fontSize: size!.height * 0.018,
      ),
    );
  }

  Container _bodyInMiddle(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size!.height * 0.03),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            spreadRadius: 2,
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.locationPin,
                    color: Colors.white,
                  ),
                  SizedBox(width: size!.width * 0.02),
                  Text(
                    '${adoption.il}/${adoption.ilce}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FaIcon(
                    Icons.account_tree_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(width: size!.width * 0.02),
                  Text(
                    '${adoption.petType}/${adoption.petBreed}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: size!.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.cakeCandles,
                    color: Colors.white,
                  ),
                  SizedBox(width: size!.width * 0.02),
                  Text(
                    'Yaş : ${adoption.old}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bodyInBottom(BuildContext context) {
    // Uri callNumber = Uri.parse(
    //     'tel:${vet != null ? vet!.phoneNumber : phoneNumber}');
    // Uri wpNumber = Uri.parse(
    //     'https://wa.me/${vet != null ? vet!.phoneNumber : userLocal!.phoneNumber}');
    return FutureBuilder<String>(
      future: getUserOrVet(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            userLocal: userLocal,
                            vet: vet,
                          )));
                },
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 50,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 45,
                    backgroundImage: NetworkImage(snapshot.data!),
                  ),
                ),
              ),
              Text(
                username,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size!.height * 0.02,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _callNumber(Uri.parse('tel:${phoneNo}')),
                    child: Container(
                      padding: EdgeInsets.all(size!.height * 0.01),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: size!.height * 0.01),
                  GestureDetector(
                    onTap: () => _messageUseByWhatsapp(
                        Uri.parse('https://wa.me/${phoneNo}')),
                    child: Container(
                      padding: EdgeInsets.all(size!.height * 0.01),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  _callNumber(Uri phoneNumber) {
    launchUrl(phoneNumber);
  }

  _messageUseByWhatsapp(Uri whatsapp) {
    launchUrl(whatsapp);
  }

  Future<String> getUserOrVet() async {
    // String url =
    //     "https://firebasestorage.googleapis.com/v0/b/patilefiredb.appspot.com/o/images%2FsystemImages%2Fnon_user.jpg?alt=media&token=16b877a1-1ac4-458b-b40a-463bccf22806";

    try {
      UserLocal userLocalDeneme = await UserAndVetFirestoreServices()
          .getUserButNotNull(adoption.publishedUserId);
      userLocal = userLocalDeneme;
      // url = userLocalDeneme.pphoto;
      username = userLocalDeneme.username;
      phoneNo = userLocalDeneme.phoneNumber;
      return userLocalDeneme.pphoto;
    } catch (ex) {
      Vet vetDeneme = await UserAndVetFirestoreServices()
          .getVetButNotNull(adoption.publishedUserId);
      vet = vetDeneme;
      // url = vetDeneme.pphoto;
      username = vetDeneme.clinicName;
      phoneNo = vetDeneme.phoneNumber;
      return vetDeneme.pphoto;
    }
    // return url;
  }
}
