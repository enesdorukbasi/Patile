// ignore_for_file: camel_case_types

import 'package:bloc/bloc.dart';
import 'package:patile/cores/json_services/json_pet_type_breed_services.dart';

class getTypeNameListCubit extends Cubit<List<String>> {
  getTypeNameListCubit() : super([]);

  Future<void> getTypes() async {
    List<String> types = await JsonPetTypeAndBreedServices().getTypeNames();
    emit(types);
  }
}

class getBreedNameListCubit extends Cubit<List<String>> {
  getBreedNameListCubit() : super([]);

  Future<void> getBreeds(String selectedType) async {
    List<String> breeds = await JsonPetTypeAndBreedServices()
        .getBreedBySelectedType(selectedType);
    emit(breeds);
  }
}
