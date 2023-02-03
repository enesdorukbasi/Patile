import 'package:cloud_firestore/cloud_firestore.dart';

class CureType {
  final String id;
  final String name;
  final String content;
  final String price;

  CureType(this.id, this.name, this.content, this.price);

  factory CureType.createCureTypeByDoc(DocumentSnapshot doc) {
    return CureType(
        doc.id, doc.get("name"), doc.get("content"), doc.get("price"));
  }
}
