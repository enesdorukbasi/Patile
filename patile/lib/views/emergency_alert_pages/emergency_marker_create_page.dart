// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/json_blocs/il_ilce_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/emergency_services.dart';
import 'package:patile/cores/json_services/json_location_services.dart';
import 'package:patile/models/firebase_models/emergency_alert.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class EmergencyMarkerCreatePage extends StatelessWidget {
  const EmergencyMarkerCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => getIlNamesCubit()),
        BlocProvider(create: (context) => getIlceNamesCubit()),
      ],
      child: EmergencyMarkerCreateView(),
    );
  }
}

class EmergencyMarkerCreateView extends StatelessWidget {
  Size? size;
  String activeUserId = "";
  String? il = "", ilce = "";
  double widthSize = 0;

  EmergencyMarkerCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().colorBackgroundAppbar(context, 'Bildirim Konumu', [
        IconButton(
            onPressed: () => openDialog(context),
            icon: const FaIcon(
              FontAwesomeIcons.plus,
              color: Colors.white,
            ))
      ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: EmergencyAndAlertFirestoreServices()
            .getAllEmergencyAlertsByUserId(activeUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CustomProgressIndicator();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Bir hata oluştu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          List<EmergencyAlert> alerts = snapshot.data!.docs
              .map((e) => EmergencyAlert.createEmergencyAlertByDoc(e))
              .toList();

          if (alerts.isEmpty) {
            return Center(
              child: Text(
                'Özel bildirim oluşturulmamış.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size!.width * 0.05,
              vertical: size!.height * 0.03,
            ),
            child: SizedBox(
              height: size!.height * 0.9,
              width: double.infinity,
              child: GridView.builder(
                itemCount: alerts.length,
                // ignore: unnecessary_new
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: size!.height * 5 / (size!.height * 2),
                ),
                itemBuilder: (context, index) {
                  return notificationItem(context, alerts[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  notificationItem(BuildContext context, EmergencyAlert alert) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size!.width * 0.01,
        vertical: size!.height * 0.01,
      ),
      child: Container(
        color: Colors.transparent,
        width: size!.width * 0.32,
        height: size!.width * 0.13,
        child: Stack(
          children: [
            Container(
              width: size!.width * 0.32,
              height: size!.width * 0.13,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "${alert.il} / ${alert.ilce}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -1,
              child: InkWell(
                onTap: () => EmergencyAndAlertFirestoreServices()
                    .deleteEmergencyAlert(alert: alert, userId: activeUserId),
                child: Container(
                  height: size!.width * 0.13,
                  width: size!.width * 0.13,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future openDialog(BuildContext context) {
    return Alert(
        style: AlertStyle(
          backgroundColor: Theme.of(context).primaryColor,
          titleStyle: const TextStyle(color: Colors.white),
          isCloseButton: false,
        ),
        context: context,
        title: "Özel Bildirim Oluştur",
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
              EmergencyAndAlertFirestoreServices()
                  .createEmergencyAlert(il!, ilce!, activeUserId);
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
}
