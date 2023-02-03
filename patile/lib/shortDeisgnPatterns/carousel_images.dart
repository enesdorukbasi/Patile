// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';

class CarouselImages {
  int imageIndex = 0;
  Widget AdvertImagesCarousel(
      BuildContext context, List<String> images, double height) {
    BuildContext bContext = context;
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.02,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                imageIndex = index;
                context.read<CarouselIndexChangeCubits>().changeIndex(index);
              },
            ),
            items: images.map((i) {
              return Container(
                width: MediaQuery.of(bContext).size.width,
                // margin: const EdgeInsets.symmetric(
                //     horizontal: 5.0, vertical: 5.0),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: Image.network(
                  i,
                  fit: BoxFit.fill,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget PostCarouselIndexControl(List images, int state) {
    var length = images.length;
    return Center(
      child: SizedBox(
        height: 20,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: index == state
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget CarouselIndexControl(List images, int state) {
    var length = images.length;
    return Center(
      child: SizedBox(
        height: 35,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: index == state
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
