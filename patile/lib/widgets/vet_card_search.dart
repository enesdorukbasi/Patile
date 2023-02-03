// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/views/profile_pages/profile_page.dart';

class VetCardSearch extends StatelessWidget {
  Vet? vet;
  Size? size;
  VetCardSearch({super.key, this.vet});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return _body(context);
  }

  Padding _body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size!.width * 0.07),
      child: Container(
        height: size!.height * 0.1,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userLocal: null,
                      vet: vet,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColorLight,
                radius: 35,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColorDark,
                  backgroundImage: NetworkImage(vet!.pphoto),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vet!.clinicName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${vet!.il} ${vet!.ilce}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
