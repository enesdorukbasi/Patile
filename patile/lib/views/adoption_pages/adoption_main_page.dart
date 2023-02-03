// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/json_blocs/il_ilce_cubits.dart';
import 'package:patile/blocs/json_blocs/pet_type_breed_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/list_cubits.dart';
import 'package:patile/cores/firebase_services/firestore_services/adoption_services.dart';
import 'package:patile/cores/json_services/json_location_services.dart';
import 'package:patile/cores/json_services/json_pet_type_breed_services.dart';
import 'package:patile/models/firebase_models/adoption.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/views/adoption_pages/adoption_create_page.dart';
import 'package:patile/widgets/adoption_card.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AdoptionMainPage extends StatelessWidget {
  const AdoptionMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => isLoadingCubit()),
      BlocProvider(create: (context) => RefreshStateCubit()),
      BlocProvider(create: (context) => getIlNamesCubit()),
      BlocProvider(create: (context) => getIlceNamesCubit()),
      BlocProvider(create: (context) => getTypeNameListCubit()),
      BlocProvider(create: (context) => getBreedNameListCubit()),
      BlocProvider(create: (context) => IsFilterListCubit()),
    ], child: AdoptionMainView());
  }
}

class AdoptionMainView extends StatelessWidget {
  Size? size;
  String? il = "", ilce = "", petType = "", petBreed = "";

  AdoptionMainView({Key? key}) : super(key: key);

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _appBar(context),
      body: _body(),
    );
  }

  Column _body() {
    return Column(
      children: [
        BlocBuilder<IsFilterListCubit, bool>(
          builder: (context, state) {
            il ??= "";
            ilce ??= "";
            petType ??= "";
            petBreed ??= "";

            if (!state) {
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
                    return FutureBuilder<List<Adoption>>(
                        future: AdoptionFirestoreServices().getAllAdverts(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                    child: Text(
                                  'Birşeyler ters gitti.',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                              ],
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CustomProgressIndicator();
                          }
                          List<Adoption> adoptions = [];
                          adoptions = snapshot.data!;
                          context.read<RefreshStateCubit>().refreshState(false);

                          if (adoptions.isNotEmpty) {
                            return SizedBox(
                              height: size!.height * 0.88,
                              width: double.infinity,
                              child: ListView.builder(
                                itemCount: adoptions.length,
                                itemBuilder: (context, index) {
                                  Adoption adoption = adoptions[index];

                                  return AdoptionCard(adoption: adoption);
                                },
                              ),
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    "İlan bulunamadı. Henüz bir ilan paylaşılmamış.",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        });
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
                    return FutureBuilder<List<Adoption>>(
                        future: AdoptionFirestoreServices()
                            .getFilterAdverts(il, ilce, petType, petBreed),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                    child: Text(
                                  'Birşeyler ters gitti.',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                              ],
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CustomProgressIndicator();
                          }
                          List<Adoption> adoptions = [];
                          adoptions = snapshot.data!;
                          context.read<RefreshStateCubit>().refreshState(true);

                          if (adoptions.isNotEmpty) {
                            return SizedBox(
                              height: size!.height * 0.88,
                              width: double.infinity,
                              child: ListView.builder(
                                itemCount: adoptions.length,
                                itemBuilder: (context, index) {
                                  Adoption adoption = adoptions[index];

                                  return AdoptionCard(adoption: adoption);
                                },
                              ),
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                    child: Expanded(
                                  child: Text(
                                    "İlan bulunamadı. Henüz bu kriterlerlerde bir ilan paylaşılmamış.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                              ],
                            );
                          }
                        });
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Yuva Arayanlar',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.plus,
          color: Theme.of(context).primaryColor,
          size: size!.height * 0.035,
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AdoptionCreatePage(),
          ));
        },
      ),
      actions: [
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
                  context.read<IsFilterListCubit>().changeFilterState(false);
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
                openDialog(context);
              },
            );
          },
        ),
      ],
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  Future openDialog(BuildContext context) {
    return Alert(
        context: context,
        title: "İlan Filtreleri",
        style: AlertStyle(
          backgroundColor: Theme.of(context).primaryColor,
          titleStyle: const TextStyle(color: Colors.white),
          isCloseButton: false,
        ),
        content: FutureBuilder<Widget>(
          future: _filterBody(),
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

  Future<Widget> _filterBody() async {
    List<String> iller = await JsonLocationService().ilIsimleriniGetir();
    List<String> types = await JsonPetTypeAndBreedServices().getTypeNames();
    List<String> ilceler = [];
    List<String> breeds = [];
    ilce = null;
    petBreed = null;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            decoration: CustomInputDecorations()
                                .inputDecoration1(
                                    context, 'Pati Türü Seçiniz', null),
                            items: types.map((String e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),
                            onChanged: (String? selectedValue) async {
                              setState(() {
                                breeds = [];
                                petBreed = null;
                              });
                              petType = selectedValue.toString();
                              breeds = await JsonPetTypeAndBreedServices()
                                  .getBreedBySelectedType(petType!);
                              setState(
                                () {
                                  petType = petType;
                                  breeds = breeds;
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
                            value: petBreed,
                            decoration: CustomInputDecorations()
                                .inputDecoration1(
                                    context, 'Pati Cinsi Seçiniz', null),
                            items: breeds.map((String e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),
                            onChanged: (String? selectedValue) {
                              setState(
                                () {
                                  petBreed = selectedValue.toString();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
