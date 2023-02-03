import 'package:flutter_bloc/flutter_bloc.dart';

class MapMainNavbarCubit extends Cubit<int> {
  MapMainNavbarCubit() : super(0);

  changeNavbarIndex(int index) {
    emit(index);
  }
}

class IconInfoStateCubit extends Cubit<bool> {
  IconInfoStateCubit() : super(false);

  changeStatus(bool isShow) {
    emit(isShow);
  }
}
