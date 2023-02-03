import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_launcher/map_launcher.dart';

class IsLoadiongLocationCubit extends Cubit<bool> {
  IsLoadiongLocationCubit() : super(false);

  void changeStatus(bool item) {
    emit(item);
  }
}

class LocationIsNotNullCubit extends Cubit<bool> {
  LocationIsNotNullCubit() : super(false);

  void changeStatus(bool item) {
    emit(item);
  }
}

class GetCoordsCubit extends Cubit<Coords> {
  GetCoordsCubit() : super(Coords(0, 0));

  void changeCoords(Coords coords) {
    emit(coords);
  }
}
