import 'package:flutter_bloc/flutter_bloc.dart';

class EmailVerificateCubit extends Cubit<bool> {
  EmailVerificateCubit() : super(false);

  changeVerificateState(bool? state) {
    emit(state!);
  }
}
