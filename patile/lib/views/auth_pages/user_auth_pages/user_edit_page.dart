// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/widgets/button_custom_progress_indicator.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';

class UserEditPage extends StatelessWidget {
  UserLocal userLocal;

  UserEditPage({super.key, required this.userLocal});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => Image1Cubit()),
      ],
      child: UserEditView(userLocal: userLocal),
    );
  }
}

class UserEditView extends StatelessWidget {
  Size? size;
  var formKey = GlobalKey<FormState>();

  String name = "", surname = "", nickname = "", pphoto = "";
  File? photo;

  UserLocal userLocal;

  UserEditView({Key? key, required this.userLocal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    name = userLocal.name;
    surname = userLocal.surname;
    nickname = userLocal.username;
    pphoto = userLocal.pphoto;

    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().colorBackgroundAppbar(context, 'Profili Düzenle', []),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
            key: formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: size!.height * 0.04),
              children: [
                Column(
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
                                      ? pphoto
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
                        LengthLimitingTextInputFormatter(10), // for mobile
                      ],
                      validator: (value) {
                        if (value!.length < 3) {
                          return "Kullanıcı adı minimum 3 karakter içermelidir.";
                        }
                      },
                      initialValue: nickname,
                      onSaved: (newValue) => nickname = newValue.toString(),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        label: const Text('Kullanıcı Adı'),
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
                          return "Ad minimum 3 karakter içermelidir.";
                        }
                      },
                      initialValue: name,
                      onSaved: (newValue) => name = newValue.toString(),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        label: const Text('Ad'),
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
                          return "Soyad minimum 3 karakter içermelidir.";
                        }
                      },
                      initialValue: surname,
                      onSaved: (newValue) => surname = newValue.toString(),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        label: const Text('Soyad'),
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
                    BlocBuilder<isLoadingCubit, bool>(
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () async {
                            if (!state) {
                              editUserButtonClick(context);
                            }
                          },
                          child: Container(
                            height: size!.height * 0.05,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: state
                                  ? const ButtonCustomProgressIndicator()
                                  : const Text(
                                      'Kaydı Tamamla',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            )),
      ),
    );
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
        return SimpleDialog(title: Text("Fotoğraf $photoNumber"), children: [
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

  editUserButtonClick(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      context.read<isLoadingCubit>().isLoadingState(true);
      try {
        if (photo != null) {
          pphoto = await StorageService().VetImageUpload(photo!);
          if (pphoto.isNotEmpty) {
            await StorageService().vetImageDelete(pphoto);
          }
        }

        await UserAndVetFirestoreServices().editUser(
            id: userLocal.id,
            name: name,
            photoUrl: pphoto,
            surname: surname,
            username: nickname);

        context.read<Image1Cubit>().image1Change("");
        context.read<isLoadingCubit>().isLoadingState(false);
        Navigator.pop(context);
        // ignore: empty_catches
      } catch (ex) {
        context.read<isLoadingCubit>().isLoadingState(false);
      }
    }
  }
}
