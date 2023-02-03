// ignore_for_file: must_be_immutable, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:patile/blocs/json_blocs/il_ilce_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/blocs/widget_blocs/location_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/emergency_services.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/cores/location_services/geolocator_service.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/button_custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class EmergencyAlertCreatePage extends StatelessWidget {
  const EmergencyAlertCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => PageNumber()),
      BlocProvider(create: (context) => isLoadingCubit()),
      BlocProvider(create: (context) => getIlNamesCubit()),
      BlocProvider(create: (context) => getIlceNamesCubit()),
      BlocProvider(create: (context) => Image1Cubit()),
      BlocProvider(create: (context) => IsLoadiongLocationCubit()),
      BlocProvider(create: (context) => LocationIsNotNullCubit()),
      BlocProvider(create: (context) => GetCoordsCubit()),
    ], child: EmergencyAlertCreateView());
  }
}

class EmergencyAlertCreateView extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  Size? size;
  File? photo;
  List address = [];
  String title = "",
      content = "",
      latitude = "",
      longitude = "",
      il = "",
      ilce = "",
      imageUrl = "",
      publishedUserId = "";

  EmergencyAlertCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    context.read<getIlNamesCubit>().getIl();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar:
          AppBars().colorBackgroundAppbar(context, 'Acil Durum Oluştur', null),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: size!.width * 0.02, vertical: size!.height * 0.03),
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
              child: BlocBuilder<Image1Cubit, String>(
                builder: (context, state) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: state != null || state != " "
                        ? FileImage(File(state))
                        : null,
                  );
                },
              ),
            ),
            SizedBox(height: size!.height * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                              _getLocation(context);
                              context
                                  .read<LocationIsNotNullCubit>()
                                  .changeStatus(false);
                            } else {
                              _getLocation(context);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(
                              size!.width * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: BlocBuilder<IsLoadiongLocationCubit, bool>(
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
                    bool isLocation = state;
                    return Row(
                      children: [
                        const Text('Konum Göster : '),
                        BlocBuilder<GetCoordsCubit, Coords>(
                          builder: (context, state) {
                            return InkWell(
                              onTap: () {
                                if (isLocation) {
                                  _getMapLauncher(state);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(
                                  size!.width * 0.02,
                                ),
                                decoration: BoxDecoration(
                                  color: isLocation
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(15),
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
            SizedBox(height: size!.height * 0.01),
            TextFormField(
              onSaved: (newValue) => title = newValue.toString(),
              validator: (value) {
                if (value!.length < 5) {
                  return "Başlık alanı minimum 5 karakter içermelidir.";
                }
              },
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Başlık', null),
            ),
            SizedBox(height: size!.height * 0.01),
            TextFormField(
              onSaved: (newValue) => content = newValue.toString(),
              validator: (value) {
                if (value!.length < 10) {
                  return "Açıklama alanı minimum 10 karakter içermelidir.";
                }
              },
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Açıklama', null),
            ),
            SizedBox(height: size!.height * 0.01),
            BlocBuilder<getIlNamesCubit, List<String>>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      decoration: CustomInputDecorations()
                          .inputDecoration1(context, 'İl Seçiniz', null),
                      items: state.map((String e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        il = selectedValue.toString();
                        context
                            .read<getIlceNamesCubit>()
                            .getIlce(selectedValue!);
                      },
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
                      decoration: CustomInputDecorations()
                          .inputDecoration1(context, 'İlçe Seçiniz', null),
                      items: state.map((String e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        ilce = selectedValue.toString();
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size!.height * 0.03),
            BlocBuilder<GetCoordsCubit, Coords>(
              builder: (context, state) {
                Coords coordsState = state;
                return BlocBuilder<isLoadingCubit, bool>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        if (!state) {
                          if (coordsState.latitude != 0 &&
                              coordsState.longitude != 0) {
                            _shareEmergencyMethod(context, coordsState);
                          }
                        }
                      },
                      child: Container(
                        height: size!.height * 0.05,
                        width: size!.width * 0.85,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: state
                              ? const ButtonCustomProgressIndicator()
                              : const Text(
                                  'Paylaş',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
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

  // ignore: body_might_complete_normally_nullable
  Future<List<dynamic>?> _getLocation(BuildContext context) async {
    // List _address = await geolocatorController.getAddress();
    // print(_address);
    context.read<IsLoadiongLocationCubit>().changeStatus(true);
    Geolocator.requestPermission().then((request) async {
      if (Platform.isIOS) {
        if (request != LocationPermission.denied) {
          address = await GeolocatorService().getAddress();
          Coords currentCoords = Coords(address[0], address[1]);

          context.read<IsLoadiongLocationCubit>().changeStatus(false);
          context.read<LocationIsNotNullCubit>().changeStatus(true);
          context.read<GetCoordsCubit>().changeCoords(currentCoords);
        } else {
          context.read<IsLoadiongLocationCubit>().changeStatus(false);
          return;
        }
      } else {
        if (request != LocationPermission.denied) {
          address = await GeolocatorService().getAddress();
          Coords currentCoords = Coords(address[0], address[1]);

          context.read<IsLoadiongLocationCubit>().changeStatus(false);
          context.read<LocationIsNotNullCubit>().changeStatus(true);
          context.read<GetCoordsCubit>().changeCoords(currentCoords);
        } else {
          context.read<IsLoadiongLocationCubit>().changeStatus(false);
          return;
        }
      }
    });
  }

  _selectPhoto(int photoNumber, BuildContext context) async {
    String selectedPicker = "";

    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            title: const Text("Acil Durum Fotoğrafı"),
            children: [
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

  _shareEmergencyMethod(BuildContext context, Coords coords) async {
    try {
      context.read<isLoadingCubit>().isLoadingState(true);
      String? publishedUserId =
          Provider.of<AuthenticationService>(context, listen: false)
              .activeUserId;

      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        //Photo Uploads
        if (photo != null) {
          imageUrl = await StorageService().EmergencyImageUpload(photo!);
        }

        if (imageUrl.isEmpty) {
          context.read<isLoadingCubit>().isLoadingState(false);
          ScaffoldMessenger.of(context).showSnackBar(
            FlashMessages().flasMessages1(
                title: 'Hata!',
                message: 'Acil durumlar için görsel eklenmesi gerekmektedir.',
                type: FlashMessageTypes.error,
                svgPath: 'assets/svgs/error_svg.svg'),
          );
          return;
        }

        //Creating Emergency
        await EmergencyAndAlertFirestoreServices().createEmergency(
          title,
          content,
          il,
          ilce,
          coords.latitude.toString(),
          coords.longitude.toString(),
          imageUrl,
          publishedUserId!,
        );

        context.read<isLoadingCubit>().isLoadingState(false);
        Navigator.pop(context);
      }
    } catch (ex) {
      context.read<isLoadingCubit>().isLoadingState(false);
      ScaffoldMessenger.of(context).showSnackBar(
        FlashMessages().flasMessages1(
            title: 'Hata!',
            message: 'Bir hata oluştu.',
            type: FlashMessageTypes.error,
            svgPath: 'assets/svgs/error_svg.svg'),
      );
    }
  }
}
