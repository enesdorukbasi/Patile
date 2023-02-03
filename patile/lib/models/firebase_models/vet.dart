import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Vet {
  final String id,
      clinicName,
      name,
      surname,
      email,
      pphoto,
      phoneNumber,
      fullAddress,
      il,
      ilce,
      latitude,
      longitude;

  Vet(
      {required this.id,
      this.clinicName = "",
      this.name = "",
      this.surname = "",
      required this.email,
      this.pphoto = "",
      this.phoneNumber = "",
      this.fullAddress = "",
      this.il = "",
      this.ilce = "",
      this.latitude = "",
      this.longitude = ""});

  factory Vet.createVetByFirebase(User? user) {
    return Vet(id: user!.uid, email: user.email.toString());
  }

  factory Vet.createVetByDoc(DocumentSnapshot doc) {
    return Vet(
        id: doc.id,
        clinicName: doc.get("clinicName"),
        name: doc.get("name"),
        surname: doc.get("surname"),
        email: doc.get("email"),
        pphoto: doc.get("pphoto"),
        phoneNumber: doc.get("phoneNumber"),
        fullAddress: doc.get("fullAddress"),
        il: doc.get("il"),
        ilce: doc.get("ilce"),
        latitude: doc.get("latitude"),
        longitude: doc.get("longitude"));
  }
}
