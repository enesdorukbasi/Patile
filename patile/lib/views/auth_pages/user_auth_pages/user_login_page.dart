// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/controls/validators/user_validators.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/cores/local_storage_services/secure_local_storage.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/views/auth_pages/user_auth_pages/user_register_page.dart';
import 'package:patile/views/auth_pages/user_or_vet_register_google_page.dart';
import 'package:patile/views/auth_pages/vet_auth_pages/vet_register_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class UserLoginPage extends StatelessWidget {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => isLoadingCubit(),
      child: UserLoginView(),
    );
  }
}

// ignore: must_be_immutable
class UserLoginView extends StatelessWidget {
  Size? size;
  String _email = "", _password = "";
  final _formKey = GlobalKey<FormState>();

  UserLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: _body(context),
    );
  }

  Stack _body(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size!.width,
          height: size!.height,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(size!.height * 0.25),
            ),
          ),
          child: Container(
            width: size!.width,
            height: size!.height,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size!.height * 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Patile',
                  style: TextStyle(
                    fontFamily: 'RubikBubbles-Regular',
                    fontSize: size!.height * 0.1,
                    color: Colors.white,
                  ),
                ),
                _userLoginPageBody(context),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: size!.width * 0.01,
            bottom: size!.height * 0.01,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: _changeLoginPageButton(context),
          ),
        ),
        BlocBuilder<isLoadingCubit, bool>(
          builder: (context, state) {
            return state
                ? const CustomProgressIndicator()
                : const SizedBox(
                    height: 0,
                    width: 0,
                  );
          },
        ),
      ],
    );
  }

  Form _userLoginPageBody(context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(25), // for mobile
                ],
                style: const TextStyle(color: Colors.white),
                validator: (value) => UserValidators().validateEmail(value),
                onSaved: (newValue) => _email = newValue.toString(),
                decoration: CustomInputDecorations().inputDecoration1(
                  context,
                  "Mail Adresi",
                  const Icon(
                    Icons.mail,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: size!.height * 0.03),
              TextFormField(
                obscureText: true,
                onSaved: (newValue) => _password = newValue.toString(),
                style: const TextStyle(color: Colors.white),
                decoration: CustomInputDecorations().inputDecoration1(
                  context,
                  'Parola',
                  const Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: size!.height * 0.03),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlocBuilder<isLoadingCubit, bool>(
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () async {
                            context.read<isLoadingCubit>().isLoadingState(true);
                            await Future.delayed(
                                const Duration(milliseconds: 5000), () async {
                              await _loginMethod(context);
                            });
                            // ignore: use_build_context_synchronously
                            context
                                .read<isLoadingCubit>()
                                .isLoadingState(false);
                          },
                          child: Container(
                            width: size!.width * 0.45,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).backgroundColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: const Center(
                                child: Text(
                              'Giriş Yap',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const UserRegisterPage()));
                      },
                      child: Container(
                        width: size!.width * 0.45,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          border: Border.all(
                            color: Theme.of(context).backgroundColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Center(
                            child: Text(
                          'Kayıt Ol',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size!.height * 0.03),
              Center(
                child: Text(
                  'Veya',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size!.height * 0.02,
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  // ignore: avoid_returning_null_for_void
                  onPressed: () async {
                    UserLocal? userLocal =
                        await AuthenticationService().createWithGMail();
                    // ignore: unrelated_type_equality_checks
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              UserRegisterGooglePage(userLocal: userLocal!)),
                    );
                  },
                  child: Text(
                    'Google İle Giriş Yap',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size!.height * 0.025,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _changeLoginPageButton(context) {
    return GestureDetector(
      onTap: (() {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const VetRegisterPage()));
      }),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          FaIcon(
            FontAwesomeIcons.userDoctor,
            color: Theme.of(context).primaryColorDark,
          ),
          Text(
            'Veteriner',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginMethod(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authService =
          Provider.of<AuthenticationService>(context, listen: false);
      try {
        await authService.loginUserWithEmail(_email, _password);

        String id = "";
        await Future.delayed(const Duration(milliseconds: 2000), () async {
          id = authService.activeUserId.toString();
        });
        Vet? activeVet;
        UserLocal? activeUserLocal;

        try {
          activeUserLocal = await UserAndVetFirestoreServices().getUser(id);
          await SecureLocalStorage.setActiveUser(null, activeUserLocal);
        } catch (ex) {}
        try {
          activeVet = await UserAndVetFirestoreServices().getVet(id);
          await SecureLocalStorage.setActiveUser(activeVet, null);
        } catch (ex) {}
      } catch (ex) {
        UserValidators().authControl(exCode: ex, context: context);
      }
    }
  }
}
