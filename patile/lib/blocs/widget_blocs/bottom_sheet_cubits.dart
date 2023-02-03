import 'package:bloc/bloc.dart';

class OnBottomSheetStatus extends Cubit<bool> {
  OnBottomSheetStatus() : super(false);

  void statusChange(bool status) {
    emit(status);
  }
}
