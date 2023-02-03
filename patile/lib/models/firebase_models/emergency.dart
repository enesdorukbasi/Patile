import 'package:cloud_firestore/cloud_firestore.dart';

class Emergency {
  final String id;
  final String title;
  final String content;
  final String latitude;
  final String longitude;
  final String il;
  final String ilce;
  final String imageUrl;
  final String publishedUserId;
  final Timestamp createdTime;
  final bool isActive;

  Emergency({
    required this.id,
    required this.title,
    required this.content,
    required this.latitude,
    required this.longitude,
    required this.il,
    required this.ilce,
    required this.imageUrl,
    required this.publishedUserId,
    required this.createdTime,
    required this.isActive,
  });

  factory Emergency.createEmergencyByDoc(DocumentSnapshot doc) {
    return Emergency(
      id: doc.id,
      title: doc.get("title"),
      content: doc.get("content"),
      latitude: doc.get("latitude"),
      longitude: doc.get("longitude"),
      il: doc.get("il"),
      ilce: doc.get("ilce"),
      imageUrl: doc.get("imageUrl"),
      publishedUserId: doc.get("publishedUserId"),
      createdTime: doc.get("createdTime"),
      isActive: doc.get("isActive"),
    );
  }
}
