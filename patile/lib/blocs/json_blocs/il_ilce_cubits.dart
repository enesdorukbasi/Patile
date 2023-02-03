// ignore_for_file: camel_case_types

import 'package:bloc/bloc.dart';
import 'package:patile/cores/json_services/json_location_services.dart';

class getIlNamesCubit extends Cubit<List<String>> {
  getIlNamesCubit() : super([]);

  Future<void> getIl() async {
    List<String> iller = await JsonLocationService().ilIsimleriniGetir();
    emit(iller);
  }
}

class getIlceNamesCubit extends Cubit<List<String>> {
  getIlceNamesCubit() : super([]);

  Future<void> getIlce(String selectedIl) async {
    List<String> ilceler =
        await JsonLocationService().secilenIlinIlceleriniGetir(selectedIl);
    emit(ilceler);
  }
}
