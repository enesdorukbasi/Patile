// ignore_for_file: library_prefixes, must_be_immutable

import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart' as mapLauncher;
import 'package:patile/blocs/widget_blocs/map_main_page_cubits.dart';
import 'package:patile/cores/firebase_services/firestore_services/emergency_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/json_services/json_map_style_services.dart';
import 'package:patile/cores/location_services/location_services.dart';
import 'package:patile/models/firebase_models/emergency.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';
import 'package:patile/views/emergency_alert_pages/emergency_details_page.dart';
import 'package:patile/views/profile_pages/profile_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class VetsMapsPage extends StatelessWidget {
  List<Vet> vets;

  VetsMapsPage({Key? key, required this.vets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => IconInfoStateCubit()),
      ],
      child: VetsMapsView(vets: vets),
    );
  }
}

class VetsMapsView extends StatefulWidget {
  List<Vet> vets;

  VetsMapsView({
    Key? key,
    required this.vets,
  }) : super(key: key);
  @override
  State<VetsMapsView> createState() => VetsMapsViewState();
}

class VetsMapsViewState extends State<VetsMapsView> {
  final Completer<GoogleMapController> _controller = Completer();
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  Size? size;
  List address = [];
  List<Marker> markers = [];
  bool isSelectedShowPoly = false;
  bool isFloatActionButtonShow = true;

  static const CameraPosition _initialCameraPosition = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(40.9806, 29.2527),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  LatLng currentLocation = _initialCameraPosition.target;

  @override
  void initState() {
    super.initState();

    _getMyLocation();
  }

  List<Emergency> emergencies = [];
  List<Vet> vets = [];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      extendBodyBehindAppBar: true,
      appBar: AppBars().colorBackgroundAppbar(context, 'Harita', []),
      // ignore: avoid_unnecessary_containers
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder<List<Emergency>>(
              future: EmergencyAndAlertFirestoreServices().getEmergenciesMap(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CustomProgressIndicator(),
                      Text(
                        'Yükleniyor. Bu işlem internet hızınıza bağlı olarak zaman alabilir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  );
                }

                emergencies = snapshot.data!;

                return FutureBuilder<List<Vet>>(
                  future: UserAndVetFirestoreServices().getAllVet(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CustomProgressIndicator(),
                          Text(
                            'Yükleniyor. Bu işlem internet hızınıza bağlı olarak zaman alabilir.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      );
                    }

                    vets = snapshot.data!;

                    return FutureBuilder<bool>(
                      future: _lastProcess(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GoogleMap(
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            mapType: MapType.normal,
                            markers: Set<Marker>.of(markers),
                            onTap: (position) {
                              _customInfoWindowController.hideInfoWindow!();
                              setState(() {
                                isFloatActionButtonShow = true;
                              });
                            },
                            initialCameraPosition: _initialCameraPosition,
                            onMapCreated: (GoogleMapController controller) {
                              MapStyles().changeMapMode(controller);
                              _customInfoWindowController.googleMapController =
                                  controller;
                              _controller.complete(controller);
                            },
                            onCameraMove: (position) {
                              _customInfoWindowController.hideInfoWindow!();
                              setState(
                                () {
                                  currentLocation = position.target;
                                  isFloatActionButtonShow = true;
                                },
                              );
                            },
                          );
                        }
                        if (snapshot.data == false) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'İşlem başarısız. Lütfen daha sonra tekrar deneyin.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          );
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CustomProgressIndicator(),
                            Text(
                              'Çok az kaldı.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              }),
          BlocBuilder<IconInfoStateCubit, bool>(
            builder: (context, state) {
              return Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: state ? size!.height * 0.3 : size!.height * 0.065,
                  width: size!.width * 0.2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            context
                                .read<IconInfoStateCubit>()
                                .changeStatus(!state);
                          },
                          icon: FaIcon(
                            state
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: state,
                        child: Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      FlashMessages().flasMessages1(
                                    title: "Veterinerler",
                                    message:
                                        "Bu ikon sayesinde veterinerleri harita üzerinde görebilirsiniz.",
                                    type: FlashMessageTypes.info,
                                    svgPath: "assets/svgs/vet_svg.svg",
                                  ));
                                },
                                child: Container(
                                  width: size!.width * 0.15,
                                  height: size!.width * 0.15,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/vet_map_icon.png'),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      FlashMessages().flasMessages1(
                                    title: "Acil Durumlar",
                                    message:
                                        "Bu ikon sayesinde acil durumları harita üzerinde görebilirsiniz.",
                                    type: FlashMessageTypes.info,
                                    svgPath:
                                        "assets/svgs/emergency_alert_svg.svg",
                                  ));
                                },
                                child: Container(
                                  width: size!.width * 0.15,
                                  height: size!.width * 0.15,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/emergency_map_icon.png'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          CustomInfoWindow(
            height: size!.height * 0.3,
            width: size!.width * 0.9,
            controller: _customInfoWindowController,
          ),
        ],
      ),
      floatingActionButton: isFloatActionButtonShow
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColorDark,
              onPressed: () => _getMyLocation(),
              child: const FaIcon(Icons.gps_fixed),
            )
          : null,
    );
  }

  Future<void> getMarkersVet(List<Vet> mapVets1) async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 3.2),
        'assets/images/vet_map_icon.png');
    for (Vet vet in mapVets1) {
      LatLng currentLatLng =
          LatLng(double.parse(vet.latitude), double.parse(vet.longitude));
      Uri callNumber = Uri.parse('tel:${vet.phoneNumber}');
      Uri wpNumber = Uri.parse('https://wa.me/${vet.phoneNumber}');

      markers.add(Marker(
        markerId: MarkerId(vet.id.toString()),
        position: currentLatLng,
        icon: icon,
        onTap: () {
          setState(() {
            isFloatActionButtonShow = false;
          });

          _customInfoWindowController.addInfoWindow!(
            Container(
              height: size!.height * 0.3,
              width: size!.width * 0.9,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(size!.width * 0.07),
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
                  SizedBox(height: size!.height * 0.03),
                  Text(
                    vet.clinicName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size!.width * 0.06,
                    ),
                  ),
                  SizedBox(height: size!.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfilePage(vet: vet),
                          ));
                        },
                        child: Container(
                          width: size!.width * 0.3,
                          height: size!.width * 0.3,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(vet.pphoto),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: size!.height * 0.02),
                          Container(
                            width: size!.width * 0.5,
                            height: size!.height * 0.1,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () => _callNumber(callNumber),
                                  icon: const FaIcon(
                                    FontAwesomeIcons.phone,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _messageUseByWhatsapp(wpNumber),
                                  icon: const FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    mapLauncher.Coords coords =
                                        mapLauncher.Coords(
                                            double.parse(vet.latitude),
                                            double.parse(vet.longitude));

                                    _getMapLauncher(coords, vet, null);
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.route,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            currentLatLng,
          );
        },
      ));
    }
  }

  Future<void> getMarkersEmergenies(List<Emergency> mapVets1) async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 3.2),
        'assets/images/emergency_map_icon.png');
    for (Emergency emergency in mapVets1) {
      LatLng currentLatLng = LatLng(
          double.parse(emergency.latitude), double.parse(emergency.longitude));
      markers.add(Marker(
        markerId: MarkerId(emergency.id.toString()),
        position: currentLatLng,
        icon: icon,
        onTap: () {
          setState(() {
            isFloatActionButtonShow = false;
          });

          _customInfoWindowController.addInfoWindow!(
            Container(
              height: size!.height * 0.3,
              width: size!.width * 0.9,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(size!.width * 0.07),
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
                  SizedBox(height: size!.height * 0.03),
                  Text(
                    emergency.title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size!.width * 0.04,
                    ),
                  ),
                  SizedBox(height: size!.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                EmergencyDetailsPage(emergency: emergency),
                          ));
                        },
                        child: Container(
                          width: size!.width * 0.3,
                          height: size!.width * 0.3,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(emergency.imageUrl),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: size!.height * 0.02),
                          Container(
                            width: size!.width * 0.4,
                            height: size!.height * 0.1,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    mapLauncher.Coords coords =
                                        mapLauncher.Coords(
                                            double.parse(emergency.latitude),
                                            double.parse(emergency.longitude));

                                    _getMapLauncher(coords, null, emergency);
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.route,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // child: Column(
              //   children: [
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.of(context).push(MaterialPageRoute(
              //           builder: (context) =>
              //               EmergencyDetailsPage(emergency: emergency),
              //         ));
              //       },
              //       child: Container(
              //         width: size!.width * 1,
              //         height: size!.height * 0.05,
              //         decoration: BoxDecoration(
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.grey.withOpacity(0.5),
              //               spreadRadius: 5,
              //               blurRadius: 7,
              //               offset: const Offset(0, 3),
              //             ),
              //           ],
              //           borderRadius: BorderRadius.only(
              //             topLeft: Radius.circular(size!.width * 1),
              //             topRight: Radius.circular(size!.width * 1),
              //           ),
              //           image: DecorationImage(
              //             image: NetworkImage(emergency.imageUrl),
              //             fit: BoxFit.fill,
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(height: size!.height * 0.03),
              //     Text(
              //       emergency.title.toUpperCase(),
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //         fontSize: size!.width * 0.06,
              //       ),
              //     ),
              //     SizedBox(height: size!.height * 0.02),
              //     Container(
              //       width: size!.width * 0.8,
              //       height: size!.height * 0.1,
              //       decoration: BoxDecoration(
              //         color: Theme.of(context).primaryColorDark,
              //         borderRadius: BorderRadius.circular(40),
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceAround,
              //         children: [
              //           IconButton(
              //             onPressed: () {
              //               mapLauncher.Coords coords = mapLauncher.Coords(
              //                   double.parse(emergency.latitude),
              //                   double.parse(emergency.longitude));

              //               _getMapLauncher(coords, null, emergency);
              //             },
              //             icon: const FaIcon(
              //               FontAwesomeIcons.route,
              //               color: Colors.white,
              //             ),
              //           ),
              //         ],
              //       ),
              //     )
              //   ],
              // ),
            ),
            currentLatLng,
          );
        },
      ));
    }
  }

  Container infoWindow(Vet vet, Uri callNumber, Uri wpNumber) {
    return Container(
      width: size!.width * 0.45,
      height: size!.height * 0.3,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfilePage(vet: vet, userLocal: null),
                ));
              },
              child: Container(
                width: size!.width * 0.4,
                height: size!.height * 0.15,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(vet.pphoto),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: size!.height * 0.02),
          Text(
            vet.clinicName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size!.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => _callNumber(callNumber),
                icon: const FaIcon(
                  FontAwesomeIcons.phone,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _messageUseByWhatsapp(wpNumber),
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _getMyLocation() async {
    LocationData myLocationDouble = await LocationServices().getLocation();

    _animateCamera(myLocationDouble);
  }

  Future<void> _animateCamera(LocationData location) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(location.latitude!, location.longitude!),
      zoom: 16.4746,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  _callNumber(Uri phoneNumber) {
    launchUrl(phoneNumber);
  }

  _messageUseByWhatsapp(Uri whatsapp) {
    launchUrl(whatsapp);
  }

  _getMapLauncher(
      mapLauncher.Coords coords, Vet? vet, Emergency? emergency) async {
    // final availableMaps = await MapLauncher.installedMaps;
    // print(availableMaps);

    if (vet != null) {
      if (await mapLauncher.MapLauncher.isMapAvailable(
              mapLauncher.MapType.google) !=
          null) {
        await mapLauncher.MapLauncher.showMarker(
          mapType: mapLauncher.MapType.google,
          coords: coords,
          title: vet.clinicName,
          description: "Konuma gitmek için yol tarifi isteyin.",
        );
      }
    } else {
      if (await mapLauncher.MapLauncher.isMapAvailable(
              mapLauncher.MapType.google) !=
          null) {
        await mapLauncher.MapLauncher.showMarker(
          mapType: mapLauncher.MapType.google,
          coords: coords,
          title: emergency!.title,
          description: "Konuma gitmek için yol tarifi isteyin.",
        );
      }
    }
  }

  Future<bool> _lastProcess() async {
    await getMarkersVet(vets);
    await getMarkersEmergenies(emergencies);
    return true;
  }
}
