import 'package:cloud_firestore/cloud_firestore.dart';

class Adoption {
  final String id;
  final String title;
  final String content;
  final String il;
  final String ilce;
  final String petType;
  final String petBreed;
  final String old;
  final String photoOneUrl;
  final String photoTwoUrl;
  final String photoThreeUrl;
  final String publishedUserId;
  final Timestamp createdTime;

  Adoption(
      {required this.id,
      required this.title,
      required this.content,
      required this.il,
      required this.ilce,
      required this.petType,
      required this.petBreed,
      required this.old,
      required this.photoOneUrl,
      required this.photoTwoUrl,
      required this.photoThreeUrl,
      required this.publishedUserId,
      required this.createdTime});

  factory Adoption.createAdvertByDoc(DocumentSnapshot doc) {
    return Adoption(
        id: doc.id,
        title: doc.get("title"),
        content: doc.get("content"),
        il: doc.get("il"),
        ilce: doc.get("ilce"),
        petType: doc.get("petType"),
        petBreed: doc.get("petBreed"),
        old: doc.get("old"),
        photoOneUrl: doc.get("photoOneUrl"),
        photoTwoUrl: doc.get("photoTwoUrl"),
        photoThreeUrl: doc.get("photoThreeUrl"),
        publishedUserId: doc.get("publishedUserId"),
        createdTime: doc.get("createdTime"));
  }
}
