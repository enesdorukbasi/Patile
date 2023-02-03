// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/controls/formatters/phone_number_formatter.dart';
import 'package:patile/controls/validators/user_validators.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class UserRegisterPage extends StatelessWidget {
  const UserRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => Image1Cubit()),
      ],
      child: UserRegisterView(),
    );
  }
}

// ignore: must_be_immutable
class UserRegisterView extends StatelessWidget {
  Size? size;
  var formKey = GlobalKey<FormState>();
  String name = "",
      surname = "",
      nickname = "",
      email = "",
      pphoto = "",
      phoneNumber = "",
      password = "",
      passwordConfirm = "";

  File? photo;

  UserRegisterView({Key? key}) : super(key: key);
  final _mobileFormatter = NumberTextInputFormatter();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _appbar(context),
      body: _userRegisterBody(context),
    );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      title: const Text('Kayıt Ol'),
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }

  Stack _userRegisterBody(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
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
                            String selectedPicker =
                                await _selectPhoto(1, context);
                            if (selectedPicker == "gallery") {
                              await _selectAGallery(1, context);
                            } else if (selectedPicker == "takePhoto") {
                              await _takeAPhoto(1, context);
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            radius: 50,
                            child: BlocBuilder<Image1Cubit, String>(
                              builder: (context, state) {
                                if (state.isEmpty) {
                                  return CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
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
                          onSaved: (newValue) => nickname = newValue.toString(),
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            label: const Text('Kullanıcı Adı'),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                          onSaved: (newValue) => name = newValue.toString(),
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            label: const Text('Ad'),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                          onSaved: (newValue) => surname = newValue.toString(),
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            label: const Text('Soyad'),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                            LengthLimitingTextInputFormatter(25), // for mobile
                          ],
                          validator: (value) =>
                              UserValidators().validateEmail(value),
                          onSaved: (newValue) => email = newValue.toString(),
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            label: const Text('Mail Adresi'),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                            _mobileFormatter,
                          ],
                          onSaved: (newValue) =>
                              phoneNumber = newValue.toString(),
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            label: const Text('Telefon Numarası'),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                          onSaved: (newValue) => password = newValue.toString(),
                          obscureText: true,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            label: const Text('Parola'),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                          onSaved: (newValue) =>
                              passwordConfirm = newValue.toString(),
                          obscureText: true,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            label: const Text('Parola Tekrar'),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                          onTap: () async {
                            await _registerMethod(context);
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
                        )
                      ],
                    ),
                  ],
                )),
          ),
        ),
        BlocBuilder<isLoadingCubit, bool>(
          builder: (context, state) {
            return Visibility(
              visible: state,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      height: size!.height,
                      width: size!.width,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.2),
                      ),
                      child: const CustomProgressIndicator(),
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Future<void> _registerMethod(BuildContext context) async {
    var formState = formKey.currentState;
    final authenticationService =
        Provider.of<AuthenticationService>(context, listen: false);

    if (formState!.validate()) {
      formState.save();
      context.read<isLoadingCubit>().isLoadingState(true);
      try {
        UserLocal? user =
            await authenticationService.createUserWithEmail(email, password);
        if (user != null) {
          if (photo != null) {
            pphoto = await StorageService().UserLocalImageUpload(photo!);
          }

          await UserAndVetFirestoreServices().createUser(
            id: user.id,
            email: user.email,
            username: nickname,
            photoUrl: pphoto,
            name: name,
            surname: surname,
            phoneNumber: phoneNumber,
          );
        }
        context.read<isLoadingCubit>().isLoadingState(false);
        Navigator.pop(context);
      } catch (ex) {
        context.read<isLoadingCubit>().isLoadingState(false);
        UserValidators().authControl(exCode: ex, context: context);
      }
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
