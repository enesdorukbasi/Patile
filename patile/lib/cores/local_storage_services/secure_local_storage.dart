import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';

class SecureLocalStorage {
  static const storage = FlutterSecureStorage();
  static const activeUserKeys = "activeUser";
  static const activeUserTypeKeys = "activeUserType";
  static const parentCommentId = "parentCommentId";

//User-Vet
  static setActiveUserType(String text) async {
    await storage.write(key: activeUserTypeKeys, value: text);
  }

  static getActiveUserType() async {
    var result = await storage.read(key: activeUserTypeKeys);

    return result.toString();
  }

  static setActiveUser(Vet? vet, UserLocal? userLocal) async {
    if (vet != null) {
      var activeUser = json.encode(vet);
      await storage.write(key: activeUserKeys, value: activeUser);
      setActiveUserType("vet");
    } else if (userLocal != null) {
      var activeUser = json.encode([userLocal]);
      await storage.write(key: activeUserKeys, value: activeUser);
      setActiveUserType("userLocal");
    }
  }

  static getActiveUser() async {
    String userType = getActiveUserType();

    if (userType == "vet") {
      var activeUserRead = await storage.read(key: activeUserKeys);
      Vet activeUser = await json.decode(activeUserRead!);

      return activeUser;
    } else if (userType == "userLocal") {
      var activeUserRead = await storage.read(key: activeUserKeys);
      Vet activeUser = await json.decode(activeUserRead!);

      return activeUser;
    }
  }

//Comment
  setParentCommentId(String text) async {
    await storage.write(key: parentCommentId, value: text);
  }

  getParentCommentId() async {
    var result = await storage.read(key: parentCommentId);

    return result.toString();
  }
}
