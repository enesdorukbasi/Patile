// ignore_for_file: must_be_immutable, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/list_cubits.dart';
import 'package:patile/blocs/widget_blocs/map_main_page_cubits.dart';
import 'package:patile/cores/firebase_services/firestore_services/emergency_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/json_services/json_location_services.dart';
import 'package:patile/models/firebase_models/emergency.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/views/emergency_alert_pages/emergency_alert_create_page.dart';
import 'package:patile/views/emergency_alert_pages/emergency_marker_create_page.dart';
import 'package:patile/views/vet_pages/vets_maps_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/emergency_card.dart';
import 'package:patile/widgets/vet_card.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class MapsMainPage extends StatelessWidget {
  const MapsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MapMainNavbarCubit()),
        BlocProvider(create: (context) => IsFilterListCubit()),
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => RefreshStateCubit()),
      ],
      child: MapsMainView(),
    );
  }
}

class MapsMainView extends StatelessWidget {
  Size? size;
  double widthSize = 0;
  List<Vet> mapVets = [];
  String? il = "", ilce = "";

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  MapsMainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    widthSize = MediaQuery.of(context).size.width / 1;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size!.height * 0.12),
          child: BlocBuilder<MapMainNavbarCubit, int>(
            builder: (context, state) {
              String title = "";

              if (state == 0) {
                title = "Acil Durumlar";
              } else if (state == 1) {
                title = "Veterinerler";
              }

              if (state == 0) {
                return AppBars().transparentBackgroundAppBar(
                    context,
                    title,
                    [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const EmergencyMarkerCreatePage()));
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.solidBell,
                          color: Theme.of(context).primaryColor,
                          size: size!.height * 0.035,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const EmergencyAlertCreatePage()));
                        },
                        icon: FaIcon(
                          Icons.emergency_share,
                          color: Theme.of(context).primaryColor,
                          size: size!.height * 0.035,
                        ),
                      ),
                    ],
                    false,
                    false,
                    _tabbar(context));
              } else {
                return AppBars().transparentBackgroundAppBar(
                    context,
                    title,
                    [
                      BlocBuilder<IsFilterListCubit, bool>(
                        builder: (context, state) {
                          if (state) {
                            return IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.filterCircleXmark,
                                color: Theme.of(context).primaryColor,
                                size: size!.height * 0.035,
                              ),
                              onPressed: () {
                                context
                                    .read<IsFilterListCubit>()
                                    .changeFilterState(false);
                              },
                            );
                          }
                          return IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.filter,
                              color: Theme.of(context).primaryColor,
                              size: size!.height * 0.035,
                            ),
                            onPressed: () {
                              openDialogVet(context);
                            },
                          );
                        },
                      ),
                    ],
                    false,
                    false,
                    _tabbar(context));
              }
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 800),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return ScaleTransition(
                      alignment: Alignment.bottomRight,
                      scale: animation,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return VetsMapsPage(
                      vets: mapVets,
                    );
                  },
                ),
              );
            },
            child: const FaIcon(FontAwesomeIcons.locationDot),
          ),
        ),
        body: BlocBuilder<MapMainNavbarCubit, int>(
          builder: (context, state) {
            if (state == 0) {
              return bodyEmergencyAlerts(context);
            } else {
              return bodyVets();
            }
          },
        ),
      ),
    );
  }

  TabBar _tabbar(BuildContext buildContext) {
    return TabBar(
      labelColor: Theme.of(buildContext).primaryColor,
      indicatorColor: Theme.of(buildContext).primaryColorDark,
      onTap: (value) {
        buildContext.read<MapMainNavbarCubit>().changeNavbarIndex(value);
      },
      tabs: const [
        Tab(icon: FaIcon(FontAwesomeIcons.truckMedical)),
        Tab(icon: FaIcon(FontAwesomeIcons.shieldCat)),
      ],
    );
  }

  SolidBottomSheet bottomsheet(BuildContext context) {
    return SolidBottomSheet(
      maxHeight: size!.height * 0.8,
      headerBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        height: 50,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const FaIcon(
                FontAwesomeIcons.mapLocation,
                color: Colors.white,
              ),
              SizedBox(width: size!.width * 0.01),
              Text(
                'Harita',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size!.width * 0.07,
                ),
              )
            ],
          ),
        ),
      ),
      body: VetsMapsPage(vets: mapVets),
    );
  }

  Future openDialogVet(BuildContext context) {
    return Alert(
        style: AlertStyle(
          backgroundColor: Theme.of(context).primaryColor,
          titleStyle: const TextStyle(color: Colors.white),
          isCloseButton: false,
        ),
        context: context,
        title: "Veteriner Filtreleri",
        content: FutureBuilder<Widget>(
          future: _filterBodyVet(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CustomProgressIndicator();
            }
            return snapshot.data!;
          },
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              context.read<IsFilterListCubit>().changeFilterState(true);
              Navigator.pop(context);
            },
            color: Theme.of(context).primaryColor,
            border: Border.all(color: Colors.white, width: 1.5),
            child: const Text(
              "Uygula",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]).show();
  }

  Future<Widget> _filterBodyVet() async {
    List<String> iller = await JsonLocationService().ilIsimleriniGetir();
    List<String> ilceler = [];
    ilce = null;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            decoration: CustomInputDecorations()
                                .inputDecoration1(context, 'İl Seçiniz', null),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black),
                            hint: const Text("İl Seçiniz"),
                            items: iller.map((String e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),
                            onChanged: (String? selectedValue) async {
                              setState(() {
                                ilceler = [];
                                ilce = null;
                              });
                              il = selectedValue.toString();
                              ilceler = await JsonLocationService()
                                  .secilenIlinIlceleriniGetir(il!);
                              setState(
                                () {
                                  il = il;
                                  ilceler = ilceler;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            value: ilce,
                            decoration: CustomInputDecorations()
                                .inputDecoration1(
                                    context, 'İlçe Seçiniz', null),
                            items: ilceler.map((String e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),
                            onChanged: (String? selectedValue) {
                              setState(
                                () {
                                  ilce = selectedValue.toString();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

//Bodies
  Column bodyVets() {
    return Column(
      children: [
        BlocBuilder<IsFilterListCubit, bool>(
          builder: (context, state) {
            if (state) {
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
                    return FutureBuilder<List<Vet>>(
                      future: UserAndVetFirestoreServices()
                          .getFilteringVet(il, ilce),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CustomProgressIndicator();
                        }

                        List<Vet> vets = snapshot.data!;
                        mapVets = snapshot.data!;
                        context.read<RefreshStateCubit>().refreshState(false);

                        if (vets.isEmpty) {
                          return Center(
                            child: Text(
                              'Aradığınız kritelere uygun bir veteriner bulunmamaktadır.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: size!.height * 0.745,
                          width: double.infinity,
                          child: GridView.builder(
                            itemCount: vets.length,
                            // ignore: unnecessary_new
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: widthSize / (widthSize * 1.1),
                            ),
                            itemBuilder: (context, index) {
                              Vet vet = vets[index];
                              return VetCard(vet: vet);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            } else {
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
                    return FutureBuilder<List<Vet>>(
                      future: UserAndVetFirestoreServices().getAllVet(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CustomProgressIndicator();
                        }

                        List<Vet> vets = snapshot.data!;
                        mapVets = snapshot.data!;

                        context.read<RefreshStateCubit>().refreshState(false);

                        return SizedBox(
                          height: size!.height * 0.745,
                          width: double.infinity,
                          child: GridView.builder(
                            itemCount: vets.length,
                            // ignore: unnecessary_new
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: widthSize / (widthSize * 1.1),
                            ),
                            itemBuilder: (context, index) {
                              Vet vet = vets[index];
                              return VetCard(vet: vet);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
          },
        )
      ],
    );
  }

  ListView bodyEmergencyAlerts(BuildContext context) {
    return ListView(
      children: [
        RefreshIndicator(
          key: refreshIndicatorKey,
          color: Colors.white,
          backgroundColor: Theme.of(context).primaryColorDark,
          strokeWidth: 4.0,
          onRefresh: () async {
            context.read<RefreshStateCubit>().refreshState(true);
            return Future<void>.delayed(const Duration(seconds: 2));
          },
          child: StreamBuilder<QuerySnapshot>(
            stream: EmergencyAndAlertFirestoreServices().getEmergencies(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Birşeyler ters gitti.");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const CustomProgressIndicator(),
                  ],
                );
              }

              List<DocumentSnapshot> docs = snapshot.data!.docs;

              docs = docs
                  .where((element) => element.get('isActive') == true)
                  .toList();

              if (docs.isEmpty) {
                return Center(
                    child: Text(
                  "Henüz paylaşım yapılmamış.",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ));
              }

              return SizedBox(
                height: size!.height * 0.7939,
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Emergency emergency =
                        Emergency.createEmergencyByDoc(docs[index]);

                    return EmergencyCard(emergency: emergency);
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
