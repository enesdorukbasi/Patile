import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/views/adoption_pages/adoption_main_page.dart';
import 'package:patile/views/map_pages/maps_main_page.dart';
import 'package:patile/views/search_pages/search_main_page.dart';
import 'package:patile/views/social_media_pages/social_media_main_page.dart';

class BottomNavBarPage extends StatelessWidget {
  const BottomNavBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavbarCubit(),
      child: BottomNavBarView(),
    );
  }
}

class BottomNavBarView extends StatelessWidget {
  BottomNavBarView({super.key});

  final List<Widget> pageLists = [
    const SocialMediaMainPage(),
    const SearchMainPage(),
    const AdoptionMainPage(),
    const MapsMainPage(),
    // EmergencyAlertMainPage(),
    // ServiceMainPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BlocBuilder<NavbarCubit, int>(
        builder: (context, state) {
          return CurvedNavigationBar(
            height: 60,
            buttonBackgroundColor: Theme.of(context).primaryColor,
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.transparent,
            items: const <Widget>[
              FaIcon(
                FontAwesomeIcons.photoFilm,
                color: Colors.white,
              ),
              FaIcon(
                Icons.search,
                color: Colors.white,
              ),
              FaIcon(
                FontAwesomeIcons.paw,
                color: Colors.white,
              ),
              FaIcon(
                FontAwesomeIcons.mapLocationDot,
                color: Colors.white,
              ),
              // FaIcon(
              //   Icons.room_service,
              //   color: Colors.white,
              // ),
            ],
            onTap: (index) {
              int activeIndex = context.read<NavbarCubit>().state;
              if (activeIndex != index) {
                context.read<NavbarCubit>().changePage(index);
              }
            },
          );
        },
      ),
      body: BlocBuilder<NavbarCubit, int>(
        builder: (context, state) {
          return pageLists[state];
        },
      ),
    );
  }
}
