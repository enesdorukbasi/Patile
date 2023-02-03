import 'package:flutter_bloc/flutter_bloc.dart';

class IsClickedFollowButton extends Cubit<bool?> {
  IsClickedFollowButton() : super(null);

  void isFollowing(bool item) {
    emit(item);
  }
}
