// ignore_for_file: must_be_immutable, empty_catches
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/views/profile_pages/profile_page.dart';
import 'package:patile/views/settings_pages/settings_page.dart';
import 'package:patile/views/write_portal_pages/write_portal_main_page.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  String _activeUserId = "";
  UserLocal? userLocal;
  Vet? vet;

  CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    return _drawerMain(context);
  }

  Drawer _drawerMain(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _headerDrawer(context),
            _drawerList(context),
          ],
        ),
      ),
    );
  }

  _headerDrawer(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getUserOrVet(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return _headerInside(size, userLocal, vet, context);
      },
    );
  }

  Container _headerInside(
      Size size, UserLocal? userLocal, Vet? vet, BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
      width: double.infinity,
      height: size.height * 0.30,
      padding: EdgeInsets.only(top: size.height * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                  userLocal != null ? userLocal.pphoto : vet!.pphoto),
            ),
          ),
          Text(
            userLocal != null
                ? "${userLocal.name} ${userLocal.surname}"
                : vet!.clinicName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          Text(
            userLocal != null ? userLocal.email : vet!.email,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  _drawerList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _menuItem(1, "Profilim", FontAwesomeIcons.user, true, context),
          _menuItem(
              2, "Soru-Cevap", FontAwesomeIcons.noteSticky, true, context),
          _menuItem(3, "Ayarlar", Icons.settings_outlined, false, context),
          _menuItem(4, "Çıkış Yap", Icons.exit_to_app, false, context)
        ],
      ),
    );
  }

  Widget _menuItem(int id, String title, IconData icon, bool isFaIcon,
      BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          if (id == 1) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ProfilePage(userLocal: userLocal, vet: vet)));
          } else if (id == 2) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const WritePortalPage()));
          } else if (id == 3) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          } else if (id == 4) {
            var authService =
                Provider.of<AuthenticationService>(context, listen: false);
            authService.signOut();
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              border: const Border.symmetric(
                  horizontal: BorderSide(color: Colors.white, width: 0.5))),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: isFaIcon
                      ? FaIcon(
                          icon,
                          color: Theme.of(context).primaryColorDark,
                          size: 25,
                        )
                      : Icon(
                          icon,
                          color: Theme.of(context).primaryColorDark,
                          size: 25,
                        ),
                ),
                Expanded(
                    child: Text(
                  title,
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 16),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  getUserOrVet() async {
    try {
      userLocal =
          await UserAndVetFirestoreServices().getUserButNotNull(_activeUserId);
      return userLocal;
    } catch (ex) {}
    try {
      vet = await UserAndVetFirestoreServices().getVetButNotNull(_activeUserId);
      return vet;
    } catch (ex) {}
  }
}
