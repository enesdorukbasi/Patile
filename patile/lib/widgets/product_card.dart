// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  Size? size;

  ProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return _productCardBody(context);
  }

  Padding _productCardBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: size!.width * 0.3,
        height: size!.height * 0.33,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _productImage(context),
            _cardInfo(context),
          ],
        ),
      ),
    );
  }

  Column _cardInfo(BuildContext context) {
    return Column(
      children: [
        const Text(
          'ÜRÜN ADI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          '25 TL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Sepete Ekle',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Padding _productImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: size!.height * 0.2,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }
}
