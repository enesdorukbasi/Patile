import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/models/firebase_models/adoption.dart';

class AdoptionFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime nowTime = DateTime.now();

  Future<void> createAdoption(
      {title,
      content,
      il,
      ilce,
      petType,
      petBreed,
      old,
      photoOneUrl,
      photoTwoUrl,
      photoThreeUrl,
      publishedUserId}) async {
    await _firestore.collection("adoptions").doc().set({
      "title": title,
      "content": content,
      "il": il,
      "ilce": ilce,
      "petType": petType,
      "petBreed": petBreed,
      "old": old,
      "photoOneUrl": photoOneUrl ?? "",
      "photoTwoUrl": photoTwoUrl ?? "",
      "photoThreeUrl": photoThreeUrl ?? "",
      "publishedUserId": publishedUserId,
      "createdTime": nowTime
    });
  }

  upgradeAdvert({
    id,
    title,
    content,
    il,
    ilce,
    petType,
    petBreed,
    old,
    photoOneUrl,
    photoTwoUrl,
    photoThreeUrl,
  }) async {
    DocumentSnapshot doc =
        await _firestore.collection("adoptions").doc(id).get();

    if (doc.exists) {
      Adoption oldAdvert = Adoption.createAdvertByDoc(doc);

      if (photoOneUrl != "") {
        if (oldAdvert.photoOneUrl != "") {
          StorageService().advertImageDelete(oldAdvert.photoOneUrl);
        }
      }
      if (photoTwoUrl != "") {
        if (oldAdvert.photoTwoUrl != "") {
          StorageService().advertImageDelete(oldAdvert.photoTwoUrl);
        }
      }
      if (photoThreeUrl != "") {
        if (oldAdvert.photoThreeUrl != "") {
          StorageService().advertImageDelete(oldAdvert.photoThreeUrl);
        }
      }

      await _firestore.collection("adoptions").doc(id).update({
        "title": title,
        "content": content,
        "il": il,
        "ilce": ilce,
        "petType": petType,
        "petBreed": petBreed,
        "old": old,
        "photoOneUrl": photoOneUrl != "" ? photoOneUrl : oldAdvert.photoOneUrl,
        "photoTwoUrl": photoTwoUrl != "" ? photoTwoUrl : oldAdvert.photoTwoUrl,
        "photoThreeUrl":
            photoThreeUrl != "" ? photoThreeUrl : oldAdvert.photoThreeUrl,
        "publishedUserId": oldAdvert.publishedUserId,
        "createdTime": oldAdvert.createdTime
      });
    }
  }

  deleteAdvert(advertId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection("adoptions").doc(advertId).get();

    Adoption advert = Adoption.createAdvertByDoc(snapshot);
    advert.photoOneUrl != ""
        ? StorageService().advertImageDelete(advert.photoOneUrl)
        : null;
    advert.photoTwoUrl != ""
        ? StorageService().advertImageDelete(advert.photoTwoUrl)
        : null;
    advert.photoThreeUrl != ""
        ? StorageService().advertImageDelete(advert.photoThreeUrl)
        : null;

    snapshot.reference.delete();
  }

  deleteAllAdvertByUserId(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('adoptions')
        .where('publishedUserId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.map(
        (e) {
          if (e.get('photoOneUrl').toString().isNotEmpty) {
            StorageService().advertImageDelete(e.get('photoOneUrl'));
          }
          if (e.get('photoTwoUrl').toString().isNotEmpty) {
            StorageService().advertImageDelete(e.get('photoTwoUrl'));
          }
          if (e.get('photoThreeUrl').toString().isNotEmpty) {
            StorageService().advertImageDelete(e.get('photoThreeUrl'));
          }
          e.reference.delete();
        },
      );
    }
  }

  Future<List<Adoption>> getAllAdverts() async {
    QuerySnapshot snapshot = await _firestore
        .collection("adoptions")
        .orderBy("createdTime", descending: true)
        .get();

    List<Adoption> adoptions =
        snapshot.docs.map((e) => Adoption.createAdvertByDoc(e)).toList();
    return adoptions;
  }

  Future<List<Adoption>> getAllAdoptionsByUserId(currentUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('adoptions')
        .where('publishedUserId', isEqualTo: currentUserId)
        .get();

    List<Adoption> adoptions =
        snapshot.docs.map((e) => Adoption.createAdvertByDoc(e)).toList();
    return adoptions;
  }

  Future<List<Adoption>> getFilterAdverts(
      String? il, String? ilce, String? petType, String? petBreed) async {
    QuerySnapshot snapshot = await _firestore.collection("adoptions").get();

    List<DocumentSnapshot> snapshot1 = snapshot.docs
        .where((element) =>
            element['il'].toString().contains(il!) &&
            element['ilce'].toString().contains(ilce!) &&
            element['petType'].toString().contains(petType!) &&
            element['petBreed'].toString().contains(petBreed!))
        .toList();

    List<Adoption> adoptions =
        snapshot1.map((e) => Adoption.createAdvertByDoc(e)).toList();
    return adoptions;
  }

  Future<List<Adoption>> getAllAdvertEski() async {
    QuerySnapshot snapshot = await _firestore
        .collection("adoptions")
        .orderBy("createdTime", descending: true)
        .get();

    List<Adoption> adverts =
        snapshot.docs.map((e) => Adoption.createAdvertByDoc(e)).toList();
    return adverts;
  }

  Future<List<Adoption>> getFilterAdvertsEski(il, ilce, type, breed) async {
    QuerySnapshot snapshot = await _firestore
        .collection("adoptions")
        .orderBy("createdTime", descending: true)
        .get();

    List<Adoption> adverts =
        snapshot.docs.map((e) => Adoption.createAdvertByDoc(e)).toList();

    List<Adoption> filterAdverts = adverts
        .where((element) => element.il.contains(il))
        .where((element) => element.ilce.contains(ilce))
        .where((element) => element.petType.contains(type))
        .where((element) => element.petBreed.contains(breed))
        .toList();
    return filterAdverts;
  }

  Future<List<Adoption>> getAdoptionByUserId(publishedUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("adoptions")
        .orderBy("createdTime", descending: true)
        .get();

    List<Adoption> adverts =
        snapshot.docs.map((e) => Adoption.createAdvertByDoc(e)).toList();
    List<Adoption> filteringAdvert = adverts
        .where((element) => element.publishedUserId == publishedUserId)
        .toList();
    return filteringAdvert;
  }
}
