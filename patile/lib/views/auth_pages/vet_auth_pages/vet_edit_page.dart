// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:patile/blocs/json_blocs/il_ilce_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/blocs/widget_blocs/location_cubits.dart';
import 'package:patile/controls/validators/user_validators.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';

class VetEditPage extends StatelessWidget {
  Vet vet;

  VetEditPage({Key? key, required this.vet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => PageNumber()),
        BlocProvider(create: (context) => getIlNamesCubit()),
        BlocProvider(create: (context) => getIlceNamesCubit()),
        BlocProvider(create: (context) => IsLoadiongLocationCubit()),
        BlocProvider(create: (context) => LocationIsNotNullCubit()),
        BlocProvider(create: (context) => GetCoordsCubit()),
        BlocProvider(create: (context) => Image1Cubit()),
      ],
      child: VetEditView(vet: vet),
    );
  }
}

class VetEditView extends StatelessWidget {
  Vet vet;

  Size? size;
  bool bodyOneIsActive = false;
  var formKey1 = GlobalKey<FormState>();
  var formKey2 = GlobalKey<FormState>();
  List address = [];

  File? photo;
  String? clinicName,
      email,
      name,
      surname,
      pphoto,
      fullAddress,
      il,
      ilce,
      latitude,
      longitude;

  VetEditView({Key? key, required this.vet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    pphoto = vet.pphoto;
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().colorBackgroundAppbar(context, 'Profil Düzenle', []),
      body: BlocBuilder<PageNumber, int>(
        builder: (context, state) {
          bodyOneIsActive = state == 0 ? true : false;
          return Stack(
            children: [
              Visibility(
                visible: bodyOneIsActive,
                child: _vetRegisterBody1(context),
              ),
              Visibility(
                visible: !bodyOneIsActive,
                child: _vetRegisterBody2(context),
              ),
              BlocBuilder<isLoadingCubit, bool>(
                builder: (context, state) {
                  return Visibility(
                      visible: state, child: const CustomProgressIndicator());
                },
              )
            ],
          );
        },
      ),
    );
  }

  Center _vetRegisterBody1(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
            key: formKey1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    String selectedPicker = await _selectPhoto(1, context);
                    if (selectedPicker == "gallery") {
                      await _selectAGallery(1, context);
                    } else if (selectedPicker == "takePhoto") {
                      await _takeAPhoto(1, context);
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    radius: 50,
                    child: BlocBuilder<Image1Cubit, String>(
                      builder: (context, state) {
                        if (state.isEmpty) {
                          return CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            backgroundImage: NetworkImage(
                              pphoto != ""
                                  ? pphoto!
                                  : 'https://cdn.pixabay.com/photo/2020/05/09/16/47/account-5150387_960_720.png',
                            ),
                            radius: 47,
                          );
                        } else {
                          photo = File(state);
                          return CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            backgroundImage: FileImage(File(state)),
                            radius: 47,
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: size!.height * 0.05),
                TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(25), // for mobile
                  ],
                  validator: (value) {
                    if (value!.length < 5) {
                      return "Klinik adı 5 karakterden az olamaz.";
                    }
                  },
                  initialValue: vet.clinicName,
                  onSaved: (newValue) => clinicName = newValue.toString(),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    label: const Text('Klinik Adı'),
                    prefixIcon: const Icon(
                      Icons.store,
                      color: Colors.white,
                    ),
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    fillColor: Theme.of(context).primaryColorLight,
                    filled: true,
                  ),
                ),
                SizedBox(height: size!.height * 0.01),
                TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15), // for mobile
                  ],
                  validator: (value) {
                    if (value!.length < 3) {
                      return "Ad 3 karakterden az olamaz.";
                    }
                  },
                  initialValue: vet.name,
                  onSaved: (newValue) => name = newValue.toString(),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    label: const Text('Ad'),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    fillColor: Theme.of(context).primaryColorLight,
                    filled: true,
                  ),
                ),
                SizedBox(height: size!.height * 0.01),
                TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15), // for mobile
                  ],
                  validator: (value) {
                    if (value!.length < 3) {
                      return "Soyad 3 karakterden az olamaz.";
                    }
                  },
                  initialValue: vet.surname,
                  onSaved: (newValue) => surname = newValue.toString(),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    label: const Text('Soyad'),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 2.0,
                      ),
                    ),
                    fillColor: Theme.of(context).primaryColorLight,
                    filled: true,
                  ),
                ),
                SizedBox(height: size!.height * 0.04),
                GestureDetector(
                  onTap: () {
                    if (formKey1.currentState!.validate()) {
                      formKey1.currentState!.save();
                      context.read<PageNumber>().changePage(1);
                      context.read<getIlNamesCubit>().getIl();
                    }
                  },
                  child: Container(
                    height: size!.height * 0.05,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Devam Et',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Center _vetRegisterBody2(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          key: formKey2,
          child: Column(
            children: [
              SizedBox(height: size!.height * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bu kısımda konum belirlenmesi;',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size!.height * 0.02,
                    ),
                  ),
                  Text(
                    'kliniğinizin kullanıcılar tarafından bulunabilmesi açısından kayıt işlemi için zorunludur.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size!.height * 0.02,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size!.height * 0.03),
              BlocBuilder<getIlNamesCubit, List<String>>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField(
                        hint: const Text("İl Seçiniz"),
                        items: state.map((String e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                        onChanged: (String? selectedValue) {
                          il = selectedValue.toString();
                          context
                              .read<getIlceNamesCubit>()
                              .getIlce(selectedValue!);
                        },
                        decoration: InputDecoration(
                          label: const Text('Parola Tekrar'),
                          labelStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Theme.of(context).primaryColorLight,
                          filled: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: size!.height * 0.01),
              BlocBuilder<getIlceNamesCubit, List<String>>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField(
                        hint: const Text("İlçe Seçiniz"),
                        items: state.map((String e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                        onChanged: (String? selectedValue) {
                          ilce = selectedValue.toString();
                        },
                        decoration: InputDecoration(
                          label: const Text('Parola Tekrar'),
                          labelStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Theme.of(context).primaryColorLight,
                          filled: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: size!.height * 0.01),
              TextFormField(
                initialValue: vet.fullAddress,
                onSaved: (newValue) => fullAddress = newValue.toString(),
                keyboardType: TextInputType.streetAddress,
                maxLines: 6,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text('Tam Adres'),
                  labelStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).backgroundColor,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).backgroundColor,
                      width: 2.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).backgroundColor,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).backgroundColor,
                      width: 2.0,
                    ),
                  ),
                  fillColor: Theme.of(context).primaryColorLight,
                  filled: true,
                ),
              ),
              SizedBox(height: size!.height * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Text('Konum Al : '),
                            BlocBuilder<LocationIsNotNullCubit, bool>(
                              builder: (context, state) {
                                bool locationIsNotNull = state;
                                return InkWell(
                                  onTap: () async {
                                    if (state) {
                                      address = [];
                                      context
                                          .read<LocationIsNotNullCubit>()
                                          .changeStatus(false);
                                    } else {}
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      size!.width * 0.02,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: BlocBuilder<IsLoadiongLocationCubit,
                                        bool>(
                                      builder: (context, state) {
                                        if (state) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return FaIcon(
                                          locationIsNotNull
                                              ? Icons.wrong_location_rounded
                                              : Icons.add_location_alt,
                                          color: Colors.white,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        BlocBuilder<LocationIsNotNullCubit, bool>(
                          builder: (context, state) {
                            bool enabledFeedBack = state;
                            return Row(
                              children: [
                                const Text('Konum Göster : '),
                                BlocBuilder<GetCoordsCubit, Coords>(
                                  builder: (context, state) {
                                    return InkWell(
                                      onTap: () {
                                        if (enabledFeedBack) {
                                          _getMapLauncher(state);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(
                                          size!.width * 0.02,
                                        ),
                                        decoration: BoxDecoration(
                                          color: enabledFeedBack
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context)
                                                  .primaryColorLight,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: const FaIcon(
                                          Icons.map,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        )
                      ],
                    ),
                    SizedBox(height: size!.height * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context.read<PageNumber>().changePage(0);
                            },
                            child: Container(
                              height: size!.height * 0.05,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  'Geri Git',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size!.width * 0.02),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              clickedEditVet(context);
                            },
                            child: Container(
                              height: size!.height * 0.05,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  'Kaydı Tamamla',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> clickedEditVet(BuildContext context) async {
    // ignore: unnecessary_null_comparison
    // ignore: unnecessary_null_comparison

    // ignore: unnecessary_null_comparison
    if ((il != null || il != "") && (ilce != null || ilce != "")) {
      try {
        context.read<isLoadingCubit>().isLoadingState(true);

        if (formKey2.currentState!.validate()) {
          formKey2.currentState!.save();

          if (vet.pphoto.isNotEmpty) {
            StorageService().vetImageDelete(vet.pphoto);
          }
          String imageUrl = await StorageService().VetImageUpload(photo!);

          await UserAndVetFirestoreServices().editVet(
            id: vet.id,
            clinicName: clinicName ?? vet.clinicName,
            name: name ?? vet.name,
            surname: surname ?? vet.surname,
            pphoto: pphoto != null ? imageUrl : vet.pphoto,
            il: il ?? vet.il,
            ilce: ilce ?? vet.ilce,
            fullAddress: fullAddress ?? vet.fullAddress,
            latitude: latitude ?? vet.latitude,
            longitude: longitude ?? vet.longitude,
          );
          context.read<isLoadingCubit>().isLoadingState(false);
          Navigator.pop(context);
        }
        context.read<isLoadingCubit>().isLoadingState(false);
      } catch (ex) {
        context.read<isLoadingCubit>().isLoadingState(false);
        UserValidators().authControl(exCode: ex, context: context);
      }
    } else {
      context.read<isLoadingCubit>().isLoadingState(false);
      ScaffoldMessenger.of(context).showSnackBar(
        FlashMessages().flasMessages1(
            title: 'Hata!',
            message: 'Eksik alanları doldurunuz.',
            type: FlashMessageTypes.error,
            svgPath: 'assets/svgs/error_svg.svg'),
      );
    }
  }

  _takeAPhoto(int imageNumber, BuildContext context) async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    if (image != null) {
      photo = File(image.path);
      context.read<Image1Cubit>().image1Change(image.path);
    }
  }

  _selectPhoto(int photoNumber, BuildContext context) async {
    String selectedPicker = "";

    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(title: const Text("Profil Fotoğrafı"), children: [
          SimpleDialogOption(
            onPressed: () async {
              selectedPicker = "takePhoto";
              Navigator.pop(context);
            },
            child: const Text("Kamerayı Kullan"),
          ),
          SimpleDialogOption(
            onPressed: () async {
              selectedPicker = "gallery";
              Navigator.pop(context);
            },
            child: const Text("Galeriden Seç"),
          )
        ]);
      },
    );
    return selectedPicker;
  }

  _selectAGallery(int imageNumber, BuildContext context) async {
    // Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    if (image != null) {
      photo = File(image.path);
      context.read<Image1Cubit>().image1Change(image.path);
    }
  }
}
