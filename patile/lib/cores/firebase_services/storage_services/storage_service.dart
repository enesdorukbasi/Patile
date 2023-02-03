// ignore_for_file: non_constant_identifier_names, empty_catches, unnecessary_null_comparison

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final Reference _storage = FirebaseStorage.instance.ref();
  String _imageId = "";

  Future<String> VetImageUpload(File file) async {
    _imageId = const Uuid().v4();
    UploadTask uploadManager =
        _storage.child("images/vet/vet_$_imageId.jpg").putFile(file);

    String uploadImageUrl = "";

    while (true) {
      try {
        TaskSnapshot snapshot = uploadManager.snapshot;
        uploadImageUrl = await snapshot.ref.getDownloadURL();
        break;
      } catch (ex) {}
    }
    return uploadImageUrl;
  }

  vetImageDelete(String imageUrl) {
    RegExp rule = RegExp(r"vet.+\.jpg");
    var match = rule.firstMatch(imageUrl);
    String FileName = match![0].toString();

    if (FileName.isNotEmpty) {
      _storage.child("images/vet/$FileName").delete();
    }
  }

  Future<String> UserLocalImageUpload(File file) async {
    _imageId = const Uuid().v4();
    UploadTask uploadManager = _storage
        .child("images/userlocal/userlocal_$_imageId.jpg")
        .putFile(file);

    String uploadImageUrl = "";

    while (true) {
      try {
        TaskSnapshot snapshot = uploadManager.snapshot;
        uploadImageUrl = await snapshot.ref.getDownloadURL();
        break;
      } catch (ex) {}
    }
    return uploadImageUrl;
  }

  UserLocalImageDelete(String imageUrl) {
    RegExp rule = RegExp(r"userlocal.+\.jpg");
    var match = rule.firstMatch(imageUrl);
    String FileName = match![0].toString();

    if (FileName.isNotEmpty) {
      _storage.child("images/userlocal/$FileName").delete();
    }
  }

  Future<String> AdvertImageUpload(File file) async {
    _imageId = const Uuid().v4();
    UploadTask uploadManager =
        _storage.child("images/adverts/advert_$_imageId.jpg").putFile(file);

    String uploadImageUrl = "";

    while (true) {
      try {
        TaskSnapshot snapshot = uploadManager.snapshot;
        uploadImageUrl = await snapshot.ref.getDownloadURL();
        break;
      } catch (ex) {}
    }
    return uploadImageUrl;
  }

  advertImageDelete(String imageUrl) {
    RegExp rule = RegExp(r"advert_.+\.jpg");
    var match = rule.firstMatch(imageUrl);
    String FileName = match![0].toString();

    if (FileName.isNotEmpty) {
      _storage.child("images/adverts/$FileName").delete();
    }
  }

  Future<String> EmergencyImageUpload(File file) async {
    _imageId = const Uuid().v4();
    UploadTask uploadManager = _storage
        .child("images/emergency/emergency_$_imageId.jpg")
        .putFile(file);

    String uploadImageUrl = "";

    while (true) {
      try {
        TaskSnapshot snapshot = uploadManager.snapshot;
        uploadImageUrl = await snapshot.ref.getDownloadURL();
        break;
      } catch (ex) {}
    }
    return uploadImageUrl;
  }

  emergencyImageDelete(String imageUrl) {
    RegExp rule = RegExp(r"emergency_.+\.jpg");
    var match = rule.firstMatch(imageUrl);
    String FileName = match![0].toString();

    if (FileName.isNotEmpty) {
      _storage.child("images/emergency/$FileName").delete();
    }
  }

  Future<String> ProductImageUpload(File file) async {
    _imageId = const Uuid().v4();
    UploadTask uploadManager =
        _storage.child("images/product/product_$_imageId.jpg").putFile(file);

    String uploadImageUrl = "";

    while (true) {
      try {
        TaskSnapshot snapshot = uploadManager.snapshot;
        uploadImageUrl = await snapshot.ref.getDownloadURL();
        break;
      } catch (e) {}
    }
    return uploadImageUrl;
  }

  productImageDelete(String imageUrl) {
    RegExp rule = RegExp(r"product_.+\.jpg");
    var match = rule.firstMatch(imageUrl);
    String FileName = match![0].toString();

    if (FileName.isNotEmpty) {
      _storage.child("images/product/$FileName").delete();
    }
  }

  Future<List<String>> postImagesUpload(List<File> files) async {
    List<String> imagesUrls = [];

    if (files[0] != null) {
      _imageId = const Uuid().v4();
      UploadTask uploadManager =
          _storage.child("images/post/post_$_imageId.jpg").putFile(files[0]);

      String uploadImageUrl = "";

      while (true) {
        try {
          TaskSnapshot snapshot = uploadManager.snapshot;
          uploadImageUrl = await snapshot.ref.getDownloadURL();
          break;
        } catch (e) {}
      }
      imagesUrls.add(uploadImageUrl);
    }
    if (files[1] != null) {
      _imageId = const Uuid().v4();
      UploadTask uploadManager =
          _storage.child("images/post/post_$_imageId.jpg").putFile(files[1]);

      String uploadImageUrl = "";

      while (true) {
        try {
          TaskSnapshot snapshot = uploadManager.snapshot;
          uploadImageUrl = await snapshot.ref.getDownloadURL();
          break;
        } catch (e) {}
      }
      imagesUrls.add(uploadImageUrl);
    }
    if (files[2] != null) {
      _imageId = const Uuid().v4();
      UploadTask uploadManager =
          _storage.child("images/post/post_$_imageId.jpg").putFile(files[2]);

      String uploadImageUrl = "";

      while (true) {
        try {
          TaskSnapshot snapshot = uploadManager.snapshot;
          uploadImageUrl = await snapshot.ref.getDownloadURL();
          break;
        } catch (e) {}
      }
      imagesUrls.add(uploadImageUrl);
    }

    return imagesUrls;
  }

  postImageDelete(String imageUrl) {
    RegExp rule = RegExp(r"post_.+\.jpg");
    var match = rule.firstMatch(imageUrl);
    String FileName = match![0].toString();

    if (FileName != null) {
      _storage.child("images/post/$FileName").delete();
    }
  }
}
