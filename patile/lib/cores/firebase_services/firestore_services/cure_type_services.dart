import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/models/firebase_models/cure_types.dart';

class CureTypeFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCureType(id, name, content, price) async {
    await _firestore
        .collection("cureTypes")
        .doc(id)
        .collection("vetCureTypes")
        .doc()
        .set({"name": name, "content": content, "price": price});
  }

  Future<void> deleteCureType(vetId, cureTypeId) async {
    await _firestore
        .collection('cureTypes')
        .doc(vetId)
        .collection('vetCureTypes')
        .doc(cureTypeId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  deleteAllCureTypesByUserId(id) async {
    QuerySnapshot snapshot = await _firestore
        .collection("cureTypes")
        .doc(id)
        .collection("vetCureTypes")
        .get();

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.map((e) {
        if (e.exists) {
          e.reference.delete();
        }
      });
    }
  }

  Future<List<CureType>> getCureTypes(id) async {
    QuerySnapshot snapshot = await _firestore
        .collection("cureTypes")
        .doc(id)
        .collection("vetCureTypes")
        .get();

    List<CureType> cureTypes =
        snapshot.docs.map((e) => CureType.createCureTypeByDoc(e)).toList();
    return cureTypes;
  }
}
