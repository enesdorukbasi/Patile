// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:patile/models/json_models/pet_type_breed.dart';

class JsonPetTypeAndBreedServices {
  List<dynamic> typeList = [];
  List<String> typesNameList = [];
  List<String> breedNameList = [];

  int? selectedIlIndex, selectedIlceIndex;
  bool isSelectedIl = false, isSelectedIlce = false;

  Future<List<dynamic>> _getTypes() async {
    typeList = [];
    String jsonString =
        await rootBundle.loadString('assets/json/pet_type-breed.json');

    final jsonResponse = json.decode(jsonString);

    typeList = jsonResponse.map((x) => Type.fromJson(x)).toList();

    return typeList;
  }

  Future<List<String>> getTypeNames() async {
    List<dynamic> types = await _getTypes();
    typesNameList = [];

    types.forEach((element) {
      typesNameList.add(element.type_name);
    });

    return typesNameList;
  }

  Future<List<String>> getBreedBySelectedType(String selectedType) async {
    List<dynamic> types = await _getTypes();
    breedNameList = [];
    types.forEach((element) {
      if (element.type_name == selectedType) {
        element.breeds.forEach((element) {
          breedNameList.add(element.breed_name);
        });
      }
    });
    return breedNameList;
  }
}
