// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patile/blocs/widget_blocs/settings_page_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => AccountSettingsIsShowCubit()),
    ], child: SettingsView());
  }
}

class SettingsView extends StatelessWidget {
  Size? size;

  SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().colorBackgroundAppbar(context, 'Ayarlar', []),
      body: ListView(
        children: [
          BlocBuilder<AccountSettingsIsShowCubit, bool>(
            builder: (context, state) {
              return ListTile(
                onTap: () {
                  context.read<AccountSettingsIsShowCubit>().isShow(!state);
                },
                title: const Text('Hesap Ayarları'),
                trailing: Icon(
                  state
                      ? Icons.arrow_drop_up_outlined
                      : Icons.arrow_drop_down_outlined,
                ),
              );
            },
          ),
          BlocBuilder<AccountSettingsIsShowCubit, bool>(
            builder: (context, state) {
              return !state
                  ? const SizedBox()
                  : Column(
                      children: [
                        ListTile(
                          onTap: () {
                            AuthenticationService().changeAccountPassword();
                            ScaffoldMessenger.of(context).showSnackBar(
                              FlashMessages().flasMessages1(
                                  title: 'Başarılı',
                                  message:
                                      'E-posta adresinize şifre değişim linki gönderilmiştir.',
                                  type: FlashMessageTypes.succes,
                                  svgPath: 'assets/svgs/success_svg.svg'),
                            );
                          },
                          title: const Text(
                            'Hesap Şifresini Değiştir',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            AuthenticationService().deleteAccount(context);
                          },
                          title: const Text(
                            'Hesabımı Sil',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      ],
                    );
            },
          )
        ],
      ),
    );
  }
}
