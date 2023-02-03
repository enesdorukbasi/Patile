// ignore_for_file: unnecessary_null_comparison
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:patile/cores/firebase_services/firestore_services/adoption_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/emergency_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/question_answer_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/social_media_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? activeUserId;

//UserLocal
  UserLocal? _createUser(User? user) {
    // ignore: unused_local_variable
    // String token;

    // user!.getIdTokenResult().then((value) {
    //   token = value.token!;
    // });
    return user == null ? null : UserLocal.createUserByFirebase(user);
  }

  Stream<UserLocal?> get stateFollower {
    return _firebaseAuth.authStateChanges().map((event) => _createUser(event));
  }

  createUserWithEmail(String email, String password) async {
    if (email == null || password == null) {
      return null;
    }
    var loginCard = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    // String token = "";
    // await FirebaseMessaging.instance.getToken().then((value) {
    //   token = value == null ? "" : value;
    // });

    // bool isUserOkey =
    //     await FireStore().loginUpdateUserById(loginCard.user!.uid, token);
    // if (isUserOkey != true) {
    //   await FireStore().loginUpdateVetById(loginCard.user!.uid, token);
    // }
    // await sendVerificationEmail();
    return UserLocal.createUserByFirebase(loginCard.user!);
  }

  Future<UserLocal?> createWithGMail() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>['email']).signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential loginCard =
        await _firebaseAuth.signInWithCredential(credential);

    UserLocal? userLocal = _createUser(loginCard.user);

    return userLocal;
  }

  sendVerificationEmail() async {
    User? firebaseUser = _firebaseAuth.currentUser;

    if (!(firebaseUser!.emailVerified)) {
      firebaseUser.sendEmailVerification();
    }
  }

  Future<bool?> isEmailVerificate() async {
    await FirebaseAuth.instance.currentUser!.reload();

    return _firebaseAuth.currentUser?.emailVerified;
  }

  changeAccountPassword() {
    User? firebaseUser = _firebaseAuth.currentUser;
    _firebaseAuth.sendPasswordResetEmail(email: firebaseUser!.email.toString());
  }

  deleteAccount(BuildContext context) async {
    User? firebaseUser = _firebaseAuth.currentUser;

    String uid = firebaseUser!.uid;

    await AdoptionFirestoreServices().deleteAllAdvertByUserId(uid);
    await EmergencyAndAlertFirestoreServices()
        .deleteAllEmergencyAlertsByUserId(uid);
    await EmergencyAndAlertFirestoreServices()
        .deleteAllEmergenciesByUserId(uid);
    await QuestionAndAnswersFirestoreServices().deleteAllQuestionsByUserId(uid);
    await SocialMediaFireStoreServices().deleteAllPostsByUserId(uid);
    await UserAndVetFirestoreServices().deleteAllFollowingUserId(uid);

    await UserAndVetFirestoreServices().deleteUser(uid);
    await UserAndVetFirestoreServices().deleteVet(uid);
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          FlashMessages().flasMessages1(
              title: 'Hata!',
              message:
                  'Bu işlemin gerçekleşmesi için yeniden giriş yapmanız gerekmektedir.',
              type: FlashMessageTypes.error,
              svgPath: 'assets/svgs/error_svg.svg'),
        );
      }
    }
  }

  loginUserWithEmail(String email, String password) async {
    if (email == null || password == null) {
      return null;
    }
    var loginCard = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    // String token = "";
    // await FirebaseMessaging.instance.getToken().then((value) {
    //   token = value == null ? "" : value;
    // });

    // bool isUserOkey =
    //     await FireStore().loginUpdateUserById(loginCard.user!.uid, token);
    // if (isUserOkey != true) {
    //   await FireStore().loginUpdateVetById(loginCard.user!.uid, token);
    // }
    return UserLocal.createUserByFirebase(loginCard.user!);
  }

  signOut() async {
    // bool isUserOkey = await FireStore().loginUpdateUserById(activeUserId, "");
    // if (isUserOkey != true) {
    //   await FireStore().loginUpdateVetById(activeUserId, "");
    // }
    await _firebaseAuth.signOut();
  }
}
