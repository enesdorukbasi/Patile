import 'package:bloc/bloc.dart';

class IsFilterListCubit extends Cubit<bool> {
  IsFilterListCubit() : super(false);

  changeFilterState(bool state) {
    emit(state);
  }
}

class RefreshStateCubit extends Cubit<bool> {
  RefreshStateCubit() : super(true);

  void refreshState(bool state) {
    super.emit(state);
  }
}
