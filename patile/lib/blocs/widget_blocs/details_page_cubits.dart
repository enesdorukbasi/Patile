import 'package:bloc/bloc.dart';

class DetailsOk extends Cubit<bool> {
  DetailsOk() : super(true);

  void isOkChange(bool isOk) {
    emit(isOk);
  }
}

class UserInfoOk extends Cubit<bool> {
  UserInfoOk() : super(false);

  void isOkChange(bool isOk) {
    emit(isOk);
  }
}

class StatusControl extends Cubit<String?> {
  StatusControl() : super(null);

  void changeString(String statusString) {
    emit(statusString);
  }
}
