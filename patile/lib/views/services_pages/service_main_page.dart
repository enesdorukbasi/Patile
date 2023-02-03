// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:patile/views/vet_pages/vets_main_page.dart';

class ServiceMainPage extends StatelessWidget {
  Size? size;

  ServiceMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hizmetler',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          serviceItem(context, () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const VetsMainPage(),
            ));
          }, "assets/images/vet_image.jpg", 1, "Veterinerler"),
          serviceItem(context, () {}, "assets/images/pet_shop_image.jpg", 0.5,
              "Petshop (Yakında)"),
        ],
      ),
    );
  }

  GestureDetector serviceItem(BuildContext context, Function clickedMethod,
      String imagePath, double imageOpacity, String title) {
    return GestureDetector(
      onTap: () => clickedMethod(),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: size!.height * 0.30,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3))
            ],
            color: Theme.of(context).primaryColor,
            image: DecorationImage(
              image: AssetImage(imagePath),
              opacity: imageOpacity,
              fit: BoxFit.fill,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 33,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.8),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(30))),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
