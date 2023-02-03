import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLocal {
  final String id;
  final String username;
  final String name;
  final String surname;
  final String pphoto;
  final String email;
  final String phoneNumber;
  final String token;

  UserLocal(
      {required this.id,
      required this.username,
      this.name = "",
      this.surname = "",
      required this.pphoto,
      required this.email,
      this.phoneNumber = "",
      this.token = ""});

  factory UserLocal.createUserByFirebase(User? user) {
    return UserLocal(
        id: user!.uid,
        username: user.displayName.toString(),
        pphoto: user.photoURL.toString(),
        email: user.email.toString());
  }

  factory UserLocal.createUserByDoc(DocumentSnapshot doc) {
    return UserLocal(
      id: doc.id,
      username: doc.get("username"),
      name: doc.get("name"),
      surname: doc.get("surname"),
      pphoto: doc.get("pphoto"),
      email: doc.get("email"),
      phoneNumber: doc.get("phoneNumber"),
    );
  }
}
