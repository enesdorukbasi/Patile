// ignore_for_file: must_be_immutable

import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:patile/widgets/product_card.dart';

class StoreMainPage extends StatelessWidget {
  Size? size;

  StoreMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _appBar(context),
      body: _body(),
    );
  }

  DynamicHeightGridView _body() {
    return DynamicHeightGridView(
        itemCount: 10,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        builder: (ctx, index) {
          return ProductCard();
        });
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Mağaza',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }
}
