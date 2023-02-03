import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';

class UserAndVetFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//USER METHODS

  Future<void> createUser(
      {id, email, phoneNumber, username, name, surname, photoUrl = ""}) async {
    try {
      await _firestore.collection("users").doc(id).set({
        "username": username,
        "name": name,
        "surname": surname,
        "pphoto": photoUrl,
        "email": email,
        "phoneNumber": phoneNumber
      });
    } catch (ex) {
      // ignore: avoid_print
      print(ex);
    }
  }

  deleteUser(id) async {
    await _firestore.collection('users').doc(id).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  Future<void> editUser({id, name, surname, username, photoUrl = ""}) async {
    await _firestore.collection('users').doc(id).update({
      'name': name,
      'surname': surname,
      'username': username,
      'pphoto': photoUrl,
    });
  }

  Future<UserLocal?> getUser(id) async {
    DocumentSnapshot? doc = await _firestore.collection("users").doc(id).get();
    if (doc.exists) {
      UserLocal user = UserLocal.createUserByDoc(doc);
      return user;
    }
    return null;
  }

  Future<List<UserLocal>?> getAllUserByName(String username) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .get();

    List<UserLocal> users =
        snapshot.docs.map((e) => UserLocal.createUserByDoc(e)).toList();
    return users;
  }

  Future<UserLocal> getUserButNotNull(id) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(id).get();

    UserLocal user = UserLocal.createUserByDoc(doc);
    return user;
  }

  Future<bool> loginUpdateUserById(id, token) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(id).get();
      await _firestore.collection("users").doc(id).update({
        "email": doc.get("email"),
        "name": doc.get("name"),
        "surname": doc.get("surname"),
        "username": doc.get("username"),
        "pphoto": doc.get("pphoto"),
        "phoneNumber": doc.get("phoneNumber"),
        "token": token
      });
      return true;
    } catch (ex) {
      return false;
    }
  }

//VET METHODS

  Future<void> createVet(
      {id,
      clinicName,
      name,
      surname,
      email,
      phoneNumber,
      fullAddress,
      il,
      ilce,
      latitude,
      longitude,
      pphoto = ""}) async {
    await _firestore.collection("vet").doc(id).set({
      "clinicName": clinicName,
      "name": name,
      "surname": surname,
      "email": email,
      "phoneNumber": phoneNumber,
      "fullAddress": fullAddress,
      "il": il,
      "ilce": ilce,
      "latitude": latitude,
      "longitude": longitude,
      "pphoto": pphoto
    });
  }

  deleteVet(id) async {
    await _firestore.collection("vet").doc(id).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  Future<void> editVet(
      {id,
      clinicName,
      name,
      surname,
      fullAddress,
      il,
      ilce,
      latitude,
      longitude,
      pphoto = ""}) async {
    await _firestore.collection("vet").doc(id).update({
      "clinicName": clinicName,
      "name": name,
      "surname": surname,
      "fullAddress": fullAddress,
      "il": il,
      "ilce": ilce,
      "latitude": latitude,
      "longitude": longitude,
      "pphoto": pphoto
    });
  }

  Future<bool> loginUpdateVetById(id, token) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("vet").doc(id).get();
      await _firestore.collection("vet").doc(id).update({
        "email": doc.get("email"),
        "clinicName": doc.get("clinicName"),
        "pphoto": doc.get("pphoto"),
        "phoneNumber": doc.get("phoneNumber"),
        "fullAddress": doc.get("fullAddress"),
        "il": doc.get("il"),
        "ilce": doc.get("ilce"),
        "latitude": doc.get("latitude"),
        "longitude": doc.get("longitude"),
        "token": token
      });
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<Vet?> getVet(id) async {
    DocumentSnapshot doc = await _firestore.collection("vet").doc(id).get();
    Vet vet = Vet.createVetByDoc(doc);
    return vet;
  }

  Future<List<Vet>?> getAllVetByClinicName(String clinicName) async {
    QuerySnapshot snapshot = await _firestore
        .collection('vet')
        .where(
          'clinicName',
          isGreaterThanOrEqualTo: clinicName,
        )
        .get();

    List<Vet>? vets = snapshot.docs.map((e) => Vet.createVetByDoc(e)).toList();
    return vets;
  }

  Future<Vet> getVetButNotNull(id) async {
    DocumentSnapshot doc = await _firestore.collection("vet").doc(id).get();

    Vet vet = Vet.createVetByDoc(doc);
    return vet;
  }

  Future<List<Vet>> getAllVet() async {
    QuerySnapshot snapshot = await _firestore.collection('vet').get();

    List<Vet> vets = snapshot.docs.map((e) => Vet.createVetByDoc(e)).toList();
    return vets;
  }

  Future<List<Vet>> getFilteringVet(String? il, String? ilce) async {
    il ??= "";
    ilce ??= "";
    QuerySnapshot snapshot = await _firestore.collection('vet').get();

    List<DocumentSnapshot> docs = snapshot.docs
        .where((element) =>
            element['il'].toString().contains(il!) &&
            element['ilce'].toString().contains(ilce!))
        .toList();

    List<Vet> vets = docs.map((e) => Vet.createVetByDoc(e)).toList();
    return vets;
  }

//Follow Methods

  Future<bool> isFollowingUser(
      {required String currentUserId, required String followerUserId}) async {
    DocumentSnapshot snapshot = await _firestore
        .collection('follow')
        .doc(currentUserId)
        .collection('followers')
        .doc(followerUserId)
        .get();

    if (snapshot.exists) {
      return true;
    }
    return false;
  }

  Future<void> followingUserOrVet(
      {required String currentUserId, required String followerUserId}) async {
    await _firestore
        .collection('follow')
        .doc(currentUserId)
        .collection('followers')
        .doc(followerUserId)
        .set({});

    await _firestore
        .collection('follow')
        .doc(followerUserId)
        .collection('following')
        .doc(currentUserId)
        .set({});
  }

  Future<void> unfollowingUserOrVet(
      {required String currentUserId, required String followerUserId}) async {
    await _firestore
        .collection('follow')
        .doc(currentUserId)
        .collection('followers')
        .doc(followerUserId)
        .delete();

    await _firestore
        .collection('follow')
        .doc(followerUserId)
        .collection('following')
        .doc(currentUserId)
        .delete();
  }

  deleteAllFollowingUserId(userId) async {
    QuerySnapshot snapshotFollowing = await _firestore
        .collection('follow')
        .doc(userId)
        .collection('following')
        .get();

    QuerySnapshot snapshotFollowers = await _firestore
        .collection('follow')
        .doc(userId)
        .collection('followers')
        .get();
    if (snapshotFollowing.docs.isNotEmpty) {
      snapshotFollowing.docs.map(
        (e) async {
          await _firestore
              .collection('follow')
              .doc(e.id)
              .collection('followers')
              .doc(userId)
              .get()
              .then(
            (value) {
              if (value.exists) {
                value.reference.delete();
              }
            },
          );
        },
      );
    }
    if (snapshotFollowers.docs.isNotEmpty) {
      snapshotFollowers.docs.map(
        (e) async {
          await _firestore
              .collection('follow')
              .doc(e.id)
              .collection('following')
              .doc(userId)
              .get()
              .then(
            (value) {
              if (value.exists) {
                value.reference.delete();
              }
            },
          );
        },
      );
    }

    await _firestore.collection('follow').doc(userId).get().then(
      (value) {
        if (value.exists) {
          value.reference.delete();
        }
      },
    );
  }

  Future<List<String>> getFollowersUserOrVet(
      {required String currentUserId}) async {
    List<String> followers = [];

    QuerySnapshot snapshot = await _firestore
        .collection('follow')
        .doc(currentUserId)
        .collection('followers')
        .get();

    followers = snapshot.docs.map((e) => e.id.toString()).toList();
    return followers;
  }

  Future<List<String>> getFollowingUserOrVet(
      {required String currentUserId}) async {
    List<String> followers = [];

    QuerySnapshot snapshot = await _firestore
        .collection('follow')
        .doc(currentUserId)
        .collection('following')
        .get();

    followers = snapshot.docs.map((e) => e.id.toString()).toList();
    return followers;
  }
}
