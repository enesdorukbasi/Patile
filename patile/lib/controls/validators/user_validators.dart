import 'package:flutter/material.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';

class UserValidators {
  authControl({exCode, BuildContext? context}) {
    String errorMessage = "";

    switch (exCode.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        errorMessage = "Bu E-mail zaten kullanılmış. Giriş sayfasına gidin.";
        break;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        errorMessage = "E-Mail/Şifre hatalı. Lütfen tekrar deneyin.";
        break;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        errorMessage = "Bu e-postaya sahip kullanıcı bulunamadı.";
        break;
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        errorMessage = "Kullanıcı devre dışı bırakıldı.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        errorMessage = "Bu hesaba giriş yapmak için çok fazla istek var.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
      // ignore: no_duplicate_case_values
      case "operation-not-allowed":
        errorMessage = "Sunucu hatası, lütfen daha sonra tekrar deneyin.";
        break;
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        errorMessage = "Email adresi geçersiz.";
        break;
      default:
        errorMessage = "Giriş başarısız. Lütfen tekrar deneyin.";
        break;
    }
    ScaffoldMessenger.of(context!).showSnackBar(FlashMessages().flasMessages1(
      title: "Hata!",
      message: errorMessage.toString(),
      type: FlashMessageTypes.error,
      svgPath: "assets/svgs/error_svg.svg",
    ));
  }

  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin.';
    } else {
      return null;
    }
  }
}
