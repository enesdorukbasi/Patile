// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/cores/firebase_services/firestore_services/emergency_services.dart';
import 'package:patile/models/firebase_models/emergency.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/views/emergency_alert_pages/emergency_alert_create_page.dart';
import 'package:patile/views/emergency_alert_pages/emergency_marker_create_page.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/emergency_card.dart';

class EmergencyAlertMainPage extends StatelessWidget {
  Size? size;

  EmergencyAlertMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    List<Widget> actions = [
      IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const EmergencyMarkerCreatePage()));
        },
        icon: FaIcon(
          FontAwesomeIcons.solidBell,
          color: Theme.of(context).primaryColor,
          size: size!.height * 0.035,
        ),
      ),
      IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const EmergencyAlertCreatePage()));
        },
        icon: FaIcon(
          Icons.emergency_share,
          color: Theme.of(context).primaryColor,
          size: size!.height * 0.035,
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().transparentBackgroundAppBar(
        context,
        'Acil Durumlar',
        actions,
        false,
        false,
        null,
      ),
      body: _body(),
    );
  }

  ListView _body() {
    return ListView(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: EmergencyAndAlertFirestoreServices().getEmergencies(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Birşeyler ters gitti.");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const CustomProgressIndicator(),
                  ],
                ),
              );
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs;

            docs = docs
                .where((element) => element.get('isActive') == true)
                .toList();

            if (docs.isEmpty) {
              return Center(
                  child: Text(
                "Henüz paylaşım yapılmamış.",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ));
            }

            return SizedBox(
              height: size!.height * 0.89,
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Emergency emergency =
                      Emergency.createEmergencyByDoc(docs[index]);

                  return EmergencyCard(emergency: emergency);
                },
              ),
            );
          },
        )
      ],
    );
  }
}
