// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/cure_type_services.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/button_custom_progress_indicator.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class CureTypeCreatePage extends StatelessWidget {
  const CureTypeCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
      ],
      child: CureTypeCreateView(),
    );
  }
}

class CureTypeCreateView extends StatelessWidget {
  Size? size;
  var formKey = GlobalKey<FormState>();
  String? cureTypeName, content, price;

  CureTypeCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().colorBackgroundAppbar(context, 'Tedavi Ekle', []),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
            vertical: size!.height * 0.03,
            horizontal: size!.width * 0.03,
          ),
          children: [
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Tedavi adını kısaca belirtiniz.";
                }
              },
              onSaved: (newValue) => cureTypeName = newValue,
              decoration: CustomInputDecorations()
                  .inputDecoration2(context, 'Tedavi Adı', null, null),
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Tedaviyi kısaca açıklayınız.";
                }
              },
              onSaved: (newValue) => content = newValue,
              decoration: CustomInputDecorations()
                  .inputDecoration2(context, 'Açıklama', null, null),
            ),
            TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Fiyat bilgisi verilmesi zorunludur.";
                }
              },
              onSaved: (newValue) => price = newValue.toString(),
              keyboardType: TextInputType.number,
              decoration: CustomInputDecorations()
                  .inputDecoration2(context, 'Fiyat', null, null),
            ),
            SizedBox(height: size!.height * 0.02),
            BlocBuilder<isLoadingCubit, bool>(
              builder: (context, state) {
                return InkWell(
                  onTap: () {
                    if (!state) {
                      _shareCureType(context);
                    }
                  },
                  child: Container(
                    height: size!.height * 0.05,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
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
            ),
          ],
        ),
      ),
    );
  }

  _shareCureType(BuildContext context) {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        context.read<isLoadingCubit>().isLoadingState(true);
        String activeUserId =
            Provider.of<AuthenticationService>(context, listen: false)
                .activeUserId
                .toString();

        try {
          CureTypeFirestoreServices()
              .createCureType(activeUserId, cureTypeName, content, price);
          context.read<isLoadingCubit>().isLoadingState(false);
          Navigator.pop(context);
        } catch (ex) {
          context.read<isLoadingCubit>().isLoadingState(false);
          ScaffoldMessenger.of(context)
              .showSnackBar(FlashMessages().flasMessages1(
            title: 'Hata!',
            message: 'Bir hata oluştu.',
            type: FlashMessageTypes.error,
            svgPath: 'assets/svgs/error_svg.svg',
          ));
        }
      }
    } catch (ex) {
      context.read<isLoadingCubit>().isLoadingState(false);
      ScaffoldMessenger.of(context).showSnackBar(FlashMessages().flasMessages1(
        title: 'Hata!',
        message: 'Bir hata oluştu.',
        type: FlashMessageTypes.error,
        svgPath: 'assets/svgs/error_svg.svg',
      ));
    }
  }
}
