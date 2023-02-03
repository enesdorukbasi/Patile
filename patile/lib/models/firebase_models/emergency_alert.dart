import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlert {
  final String id;
  final String il;
  final String ilce;

  EmergencyAlert({required this.il, required this.ilce, required this.id});

  factory EmergencyAlert.createEmergencyAlertByDoc(DocumentSnapshot doc) {
    return EmergencyAlert(
      id: doc.id,
      il: doc.get('il'),
      ilce: doc.get('ilce'),
    );
  }
}
