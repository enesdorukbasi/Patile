// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/cure_type_services.dart';
import 'package:patile/models/firebase_models/cure_types.dart';
import 'package:provider/provider.dart';

class CureTypeCard extends StatelessWidget {
  CureType cureType;
  Size? size;
  String activeUserId = "";
  String profileId;

  CureTypeCard({Key? key, required this.cureType, required this.profileId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size!.width * 0.1,
        vertical: size!.height * 0.02,
      ),
      child: Container(
        width: double.infinity,
        height: size!.height * 0.1,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            activeUserId == profileId
                ? IconButton(
                    onPressed: () {
                      CureTypeFirestoreServices()
                          .deleteCureType(profileId, cureType.id);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.trash,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    width: size!.width * 0.15,
                    height: size!.width * 0.15,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/cureType.png'),
                      ),
                    ),
                  ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cureType.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  cureType.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              "${cureType.price} ₺",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
