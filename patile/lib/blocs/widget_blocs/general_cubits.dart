import 'package:bloc/bloc.dart';

// ignore: camel_case_types
class isLoadingCubit extends Cubit<bool> {
  isLoadingCubit() : super(false);

  void isLoadingState(bool result) {
    emit(result);
  }
}

class NavbarCubit extends Cubit<int> {
  NavbarCubit() : super(0);

  void changePage(int index) {
    emit(index);
  }
}

class PageNumber extends Cubit<int> {
  PageNumber() : super(0);

  void changePage(int pageNumber) {
    emit(pageNumber);
  }
}

class NavPagesDetailsCubit extends Cubit<int> {
  NavPagesDetailsCubit() : super(0);

  void changeNavPageIndex(int index) {
    emit(index);
  }
}

class UserTypeCubit extends Cubit<String> {
  UserTypeCubit() : super("");

  changeType(String type) {
    emit(type);
  }
}
