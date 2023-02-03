// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/models/firebase_models/emergency.dart';
import 'package:patile/views/emergency_alert_pages/emergency_details_page.dart';

class EmergencyCard extends StatelessWidget {
  Size? size;
  Emergency emergency;

  EmergencyCard({Key? key, required this.emergency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return _emergencyAlertBody(context);
  }

  Padding _emergencyAlertBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: double.infinity,
        height: size!.height * 0.15,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _alertImage(context),
                _emergencyAlertMiddle(),
                Center(
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EmergencyDetailsPage(
                                emergency: emergency,
                              )));
                    },
                    icon: FaIcon(
                      Icons.arrow_circle_right_rounded,
                      size: size!.height * 0.05,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Center _emergencyAlertMiddle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            emergency.title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${emergency.il}/${emergency.ilce}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const Text(
            '5 dakika önce',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Container _alertImage(BuildContext context) {
    return Container(
      width: size!.width * 0.2,
      height: size!.width * 0.2,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColorLight,
          width: 2,
        ),
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColorLight,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(emergency.imageUrl),
        ),
      ),
    );
  }
}
