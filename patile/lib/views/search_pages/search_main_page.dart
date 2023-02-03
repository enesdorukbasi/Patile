// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patile/blocs/widget_blocs/search_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/user_card.dart';
import 'package:patile/widgets/vet_card_search.dart';

class SearchMainPage extends StatelessWidget {
  const SearchMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => isLoadingCubit()),
      BlocProvider(create: (context) => DropdownCubit()),
      BlocProvider(create: (context) => SearchTextCubit()),
    ], child: SearchMainWiew());
  }
}

class SearchMainWiew extends StatelessWidget {
  List<String> userTypes = ["Kullanıcı", "Veteriner"];
  String selectedType = "Kullanıcı";
  Size? size;
  SearchMainWiew({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DropdownCubit>().changeItem(selectedType);
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          BlocBuilder<DropdownCubit, String>(
            builder: (context, state) {
              selectedType = state;
              return const SizedBox(
                height: 0,
                width: 0,
              );
            },
          ),
          BlocBuilder<SearchTextCubit, String>(
            builder: (context, state) {
              if (state != "") {
                if (selectedType == "Kullanıcı") {
                  return _getUserWidget(state);
                } else if (selectedType == "Veteriner") {
                  return _getVetWidget(state);
                }
              }
              return const SizedBox(height: 0);
            },
          ),
          _searchBar(context),
        ],
      ),
    );
  }

  _getUserWidget(String searchText) {
    return FutureBuilder<List<UserLocal>?>(
      future: UserAndVetFirestoreServices().getAllUserByName(searchText),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CustomProgressIndicator();
        }
        List<UserLocal>? users = snapshot.data;
        if (users!.isEmpty) {
          return const Center(
            child: Text(
              'Aranan kullanıcıadına ait bir kullanıcı bulunamadı.',
            ),
          );
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(top: size!.height * 0.1),
                child: UserCard(userLocal: users[index]),
              );
            }
            return UserCard(userLocal: users[index]);
          },
        );
      },
    );
  }

  _getVetWidget(String searchText) {
    return FutureBuilder<List<Vet>?>(
      future: UserAndVetFirestoreServices().getAllVetByClinicName(searchText),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CustomProgressIndicator();
        }
        List<Vet>? vets = snapshot.data;
        if (vets!.isEmpty) {
          return Center(
            child: Text(
              'Aranan kullanıcıadına ait bir kullanıcı bulunamadı.',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: vets.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(top: size!.height * 0.1),
                child: VetCardSearch(
                  vet: vets[index],
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.only(top: size!.height * 0.01),
              child: VetCardSearch(
                vet: vets[index],
              ),
            );
          },
        );
      },
    );
  }

  Padding _searchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size!.height * 0.05),
      child: Row(
        children: [
          SizedBox(
            width: size!.width * 0.7,
            height: size!.height * 0.07,
            child: TextField(
              onChanged: (value) {
                context.read<SearchTextCubit>().changeText(value);
              },
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Ara...', null),
            ),
          ),
          SizedBox(
            width: size!.width * 0.3,
            height: size!.height * 0.07,
            child: SizedBox(
              width: double.infinity,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField(
                  decoration: CustomInputDecorations()
                      .inputDecoration1(context, selectedType, null),
                  items: userTypes.map((String e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (String? selectedValue) {
                    selectedType = selectedValue.toString();
                    context.read<DropdownCubit>().changeItem(selectedType);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
