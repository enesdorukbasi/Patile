// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patile/blocs/widget_blocs/control_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/views/auth_pages/user_auth_pages/user_login_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/home_page_navbar.dart';
import 'package:provider/provider.dart';

class AuthenticationControlPage extends StatelessWidget {
  const AuthenticationControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => EmailVerificateCubit()),
    ], child: const AuthenticationControl());
  }
}

class AuthenticationControl extends StatelessWidget {
  const AuthenticationControl({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _authenticationService =
        Provider.of<AuthenticationService>(context, listen: false);
    return StreamBuilder<UserLocal?>(
      stream: _authenticationService.stateFollower,
      builder: (context, snapshot) {
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

        if (snapshot.hasData) {
          _authenticationService.activeUserId = snapshot.data!.id;
          return FutureBuilder(
            future: checkEmailVerified(context),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return emailVerified(context);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const CustomProgressIndicator(),
                ],
              );
            },
          );
        } else {
          return const UserLoginPage();
        }
      },
    );
  }

  Stack emailVerified(BuildContext context) {
    checkEmailVerified(context);
    return Stack(
      children: [
        const BottomNavBarPage(),
        BlocBuilder<EmailVerificateCubit, bool>(
          builder: (context, state) {
            return Visibility(
              visible: !state,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                "Devam Etmek İçin E-Mail Adresinizi Onaylayınız",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Feedback.forTap(context);
                                      AuthenticationService()
                                          .sendVerificationEmail();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Tekrar Mail Gönder",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Feedback.forTap(context);
                                      AuthenticationService().signOut();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Çıkış Yap",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
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

  checkEmailVerified(BuildContext context) async {
    bool? isVerificate = await AuthenticationService().isEmailVerificate();
    context.read<EmailVerificateCubit>().changeVerificateState(isVerificate);

    if (isVerificate! == false) {
      // ignore: unused_local_variable
      Timer timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        isVerificate = await AuthenticationService().isEmailVerificate();
        context
            .read<EmailVerificateCubit>()
            .changeVerificateState(isVerificate);
        if (isVerificate! == true) {
          timer.cancel();
        }
      });
    }
    return isVerificate;
  }
}
