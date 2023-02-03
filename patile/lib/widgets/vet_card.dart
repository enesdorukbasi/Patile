// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/views/profile_pages/profile_page.dart';

class VetCard extends StatelessWidget {
  Vet? vet;
  Size? size;
  VetCard({super.key, this.vet});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size!.height * 0.01,
        horizontal: size!.width * 0.01,
      ),
      child: Container(
        width: size!.width * 0.4,
        height: size!.height * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _body(context),
      ),
    );
  }

  Column _body(BuildContext context) {
    return Column(
      children: [
        _vetImage(context),
        Text(
          vet!.clinicName.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size!.height * 0.025,
          ),
        ),
        Text(
          "${vet!.il.toUpperCase()} / ${vet!.ilce.toUpperCase()}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size!.height * 0.015,
          ),
        ),
      ],
    );
  }

  GestureDetector _vetImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfilePage(vet: vet, userLocal: null),
        ));
      },
      child: Container(
        width: double.infinity,
        height: size!.height * 0.15,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColorLight),
          image: DecorationImage(
            image: NetworkImage(vet!.pphoto),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
