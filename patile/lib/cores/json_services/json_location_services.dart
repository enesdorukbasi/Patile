// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:patile/models/json_models/il_ilce.dart';

class JsonLocationService {
  List<dynamic> illerList = [];
  List<String> ilNameList = [];
  List<String> ilceNameList = [];

  int? selectedIlIndex, selectedIlceIndex;
  bool isSelectedIl = false, isSelectedIlce = false;

  Future<List<dynamic>> _illeriGetir() async {
    illerList = [];
    String jsonString = await rootBundle.loadString('assets/json/il-ilce.json');

    final jsonResponse = json.decode(jsonString);

    illerList = jsonResponse.map((x) => Il.fromJson(x)).toList();

    return illerList;
  }

  Future<List<String>> ilIsimleriniGetir() async {
    List<dynamic> iller = await _illeriGetir();
    ilNameList = [];

    iller.forEach((element) {
      ilNameList.add(element.ilAdi);
    });

    return ilNameList;
  }

  Future<List<String>> secilenIlinIlceleriniGetir(String secilenIl) async {
    List<dynamic> iller = await _illeriGetir();
    ilceNameList = [];
    iller.forEach((element) {
      if (element.ilAdi == secilenIl) {
        element.ilceler.forEach((element) {
          ilceNameList.add(element.ilceAdi);
        });
      }
    });
    return ilceNameList;
  }
}
