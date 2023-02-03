import 'package:flutter_bloc/flutter_bloc.dart';

class ParentCommentIdCubit extends Cubit<String> {
  ParentCommentIdCubit() : super("");

  changeParentCommentId(String id) {
    emit(id);
  }
}

class ShowAllChildCommentsCubit extends Cubit<bool> {
  ShowAllChildCommentsCubit() : super(false);

  changeShowState(bool state) {
    emit(state);
  }
}
