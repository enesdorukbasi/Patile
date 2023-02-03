// ignore_for_file: must_be_immutable, empty_catches

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:patile/blocs/widget_blocs/details_page_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/emergency_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/emergency.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/views/profile_pages/profile_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyDetailsPage extends StatelessWidget {
  Emergency emergency;

  EmergencyDetailsPage({Key? key, required this.emergency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => DetailsOk()),
        BlocProvider(create: (context) => UserInfoOk()),
        BlocProvider(create: (context) => StatusControl()),
      ],
      child: EmergencyDetailsWidget(
        emergency: emergency,
      ),
    );
  }
}

class EmergencyDetailsWidget extends StatelessWidget {
  EmergencyDetailsWidget({Key? key, required this.emergency}) : super(key: key);
  Emergency emergency;
  Size? size;
  UserLocal? userLocal;
  Vet? vet;
  String activeUserId = "", username = "", phoneNo = "";

  @override
  Widget build(BuildContext context) {
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    size = MediaQuery.of(context).size;
    context.read<StatusControl>().changeString(
        emergency.isActive ? "Pasif Hale Getir" : "Aktif Hale Getir");

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBars().transparentBackgroundAppBar(
        context,
        '',
        [
          emergency.publishedUserId == activeUserId
              ? BlocBuilder<StatusControl, String?>(
                  builder: (context, state) {
                    return PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'Pasif Hale Getir':
                            _clickedChangeStatusButton(
                                context, "Aktif Hale Getir");
                            break;
                          case 'Aktif Hale Getir':
                            _clickedChangeStatusButton(
                                context, "Pasif Hale Getir");
                            break;
                          case 'Sil':
                            _clickedDeleteButton(context);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {state.toString(), 'Sil'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    );
                  },
                )
              : const SizedBox(width: 0)
        ],
        true,
        false,
        null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          _imageWidget(context),
          Column(
            children: [
              SizedBox(height: size!.height * 0.01),
              Text(
                emergency.title.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size!.height * 0.03,
                ),
              ),
              SizedBox(height: size!.height * 0.01),
              Container(
                padding: EdgeInsets.all(size!.width * 0.04),
                constraints: BoxConstraints(
                    maxHeight: double.infinity, minHeight: size!.height * 0.45),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.35),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Acil İlanı Bilgileri',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bodyInBottom(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserOrVet(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Uri callNumber = Uri.parse('tel:${snapshot.data![2]}');
          // Uri wpNumber = Uri.parse('https://wa.me/${snapshot.data![2]}');
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

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        return const CircularProgressIndicator();
      },
    );
  }

  AutoSizeText _bodyInContent() {
    return AutoSizeText(
      emergency.content,
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
      child: Row(
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
                '${emergency.il}/${emergency.ilce}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
          GestureDetector(
            onTap: () {
              Coords coords = Coords(double.parse(emergency.latitude),
                  double.parse(emergency.longitude));
              _getMapLauncher(coords);
            },
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
                Icons.map,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _imageWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: size!.height * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.35),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(emergency.imageUrl),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Future<String> getUserOrVet() async {
    // String url =
    //     "https://firebasestorage.googleapis.com/v0/b/patilefiredb.appspot.com/o/images%2FsystemImages%2Fnon_user.jpg?alt=media&token=16b877a1-1ac4-458b-b40a-463bccf22806";

    try {
      UserLocal userLocalDeneme = await UserAndVetFirestoreServices()
          .getUserButNotNull(emergency.publishedUserId);
      userLocal = userLocalDeneme;
      // url = userLocalDeneme.pphoto;
      username = userLocalDeneme.username;
      phoneNo = userLocalDeneme.phoneNumber;
      return userLocalDeneme.pphoto;
    } catch (ex) {
      Vet vetDeneme = await UserAndVetFirestoreServices()
          .getVetButNotNull(emergency.publishedUserId);
      vet = vetDeneme;
      // url = vetDeneme.pphoto;
      username = vetDeneme.clinicName;
      phoneNo = vetDeneme.phoneNumber;
      return vetDeneme.pphoto;
    }
    // return url;
  }

  _getMapLauncher(Coords coords) async {
    // final availableMaps = await MapLauncher.installedMaps;
    // print(availableMaps);

    if (await MapLauncher.isMapAvailable(MapType.google) != null) {
      await MapLauncher.showMarker(
        mapType: MapType.google,
        coords: coords,
        title: "Buradasınız",
        description: "Eklenecek olan konum.",
      );
    }
  }

  _clickedChangeStatusButton(BuildContext context, value) async {
    await EmergencyAndAlertFirestoreServices().editEmergency(emergency.id);
    // ignore: use_build_context_synchronously
    context.read<StatusControl>().changeString(value);
  }

  _clickedDeleteButton(BuildContext context) async {
    await EmergencyAndAlertFirestoreServices().deleteEmergency(emergency.id);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  _callNumber(Uri phoneNumber) {
    launchUrl(phoneNumber);
  }

  _messageUseByWhatsapp(Uri whatsapp) {
    launchUrl(whatsapp);
  }
}
