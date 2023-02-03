import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/models/firebase_models/emergency.dart';
import 'package:patile/models/firebase_models/emergency_alert.dart';

class EmergencyAndAlertFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime nowTime = DateTime.now();

//EMERGENCY
  Future<void> createEmergency(
      String title,
      String content,
      String il,
      String ilce,
      String latitude,
      String longitude,
      String imageUrl,
      String publishedUserId) async {
    await _firestore.collection("emergency").doc().set({
      "title": title,
      "content": content,
      "il": il,
      "ilce": ilce,
      "latitude": latitude,
      "longitude": longitude,
      "imageUrl": imageUrl,
      "publishedUserId": publishedUserId,
      "createdTime": nowTime,
      "isActive": true
    });
  }

  Future<Emergency> editEmergency(String id) async {
    DocumentSnapshot doc =
        await _firestore.collection("emergency").doc(id).get();
    if (doc.exists) {
      Emergency oldEmergency = Emergency.createEmergencyByDoc(doc);
      await _firestore
          .collection("emergency")
          .doc(oldEmergency.id)
          .update({"isActive": !oldEmergency.isActive});
    }
    DocumentSnapshot updatedDoc =
        await _firestore.collection("emergency").doc(id).get();
    Emergency emergency = Emergency.createEmergencyByDoc(updatedDoc);
    return emergency;
  }

  deleteEmergency(String id) async {
    DocumentSnapshot doc =
        await _firestore.collection("emergency").doc(id).get();
    if (doc.exists) {
      Emergency emergency = Emergency.createEmergencyByDoc(doc);
      await StorageService().emergencyImageDelete(emergency.imageUrl);
      await doc.reference.delete();
    }
  }

  Stream<QuerySnapshot> getEmergencies() {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection("emergency")
        .orderBy("createdTime", descending: true)
        .snapshots();
    return snapshot;
  }

  Future<List<Emergency>> getEmergenciesMap() async {
    QuerySnapshot snapshot = await _firestore.collection("emergency").get();

    List<Emergency> emergencies =
        snapshot.docs.map((e) => Emergency.createEmergencyByDoc(e)).toList();

    return emergencies;
  }

  Future<List<Emergency>> getEmergenciesByUserId(publishedUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("emergency")
        .orderBy("createdTime", descending: true)
        .get();

    List<Emergency> emergencies =
        snapshot.docs.map((e) => Emergency.createEmergencyByDoc(e)).toList();
    List<Emergency> currentEmergency = emergencies
        .where((element) => element.publishedUserId == publishedUserId)
        .toList();
    return currentEmergency;
  }

  deleteAllEmergenciesByUserId(publishedUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("emergency")
        .orderBy("createdTime", descending: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.map(
        (e) {
          if (e.exists) {
            if (e.get('imageUrl').toString().isNotEmpty) {
              StorageService().emergencyImageDelete(e.get('imageUrl'));
            }
            e.reference.delete();
          }
        },
      );
    }
  }

  //EMERGENCY ALERT

  Future<void> createEmergencyAlert(
      String il, String ilce, String userId) async {
    await _firestore
        .collection("alertBells")
        .doc('emergencyAlertsUserBells')
        .collection(il)
        .doc(ilce)
        .collection("users")
        .doc(userId)
        .set({});

    await _firestore
        .collection("alertBells")
        .doc('emergencyAlertsUserBellsGet')
        .collection(userId)
        .doc()
        .set({
      'il': il,
      'ilce': ilce,
    });
  }

  Future<void> deleteEmergencyAlert(
      {required EmergencyAlert alert, required String userId}) async {
    DocumentSnapshot doc1 = await _firestore
        .collection("alertBells")
        .doc('emergencyAlertsUserBells')
        .collection(alert.il)
        .doc(alert.ilce)
        .collection("users")
        .doc(userId)
        .get();

    DocumentSnapshot doc2 = await _firestore
        .collection("alertBells")
        .doc('emergencyAlertsUserBellsGet')
        .collection(userId)
        .doc(alert.id)
        .get();

    if (doc1.exists) {
      doc1.reference.delete();
    }
    if (doc2.exists) {
      doc2.reference.delete();
    }
  }

  deleteAllEmergencyAlertsByUserId(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('alertBells')
        .doc('emergencyAlertsUserBellsGet')
        .collection(userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.map(
        (e) {
          if (e.exists) {
            EmergencyAlert emergencyAlert =
                EmergencyAlert.createEmergencyAlertByDoc(e);
            deleteEmergencyAlert(alert: emergencyAlert, userId: userId);
          }
        },
      );
    }
  }

  Stream<QuerySnapshot> getAllEmergencyAlertsByUserId(String userId) {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection('alertBells')
        .doc('emergencyAlertsUserBellsGet')
        .collection(userId)
        .snapshots();

    return snapshot;
  }
}
