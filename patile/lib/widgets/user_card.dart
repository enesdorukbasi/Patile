// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/views/profile_pages/profile_page.dart';

class UserCard extends StatelessWidget {
  UserLocal? userLocal;
  Size? size;
  UserCard({super.key, this.userLocal});

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
                      userLocal: userLocal,
                      vet: null,
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
                  backgroundImage: NetworkImage(userLocal!.pphoto),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userLocal!.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${userLocal!.name} ${userLocal!.surname}",
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
