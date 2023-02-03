import 'package:flutter_bloc/flutter_bloc.dart';

class AccountSettingsIsShowCubit extends Cubit<bool> {
  AccountSettingsIsShowCubit() : super(false);

  isShow(bool state) {
    emit(state);
  }
}
