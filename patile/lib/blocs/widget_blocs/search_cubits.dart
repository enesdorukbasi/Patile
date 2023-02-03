import 'package:flutter_bloc/flutter_bloc.dart';

class DropdownCubit extends Cubit<String> {
  DropdownCubit() : super("");

  void changeItem(String item) {
    emit(item);
  }
}

class SearchTextCubit extends Cubit<String> {
  SearchTextCubit() : super("");

  void changeText(String text) {
    emit(text);
  }
}
