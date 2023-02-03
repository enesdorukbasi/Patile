// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/models/firebase_models/adoption.dart';
import 'package:patile/views/adoption_pages/adoption_details_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdoptionCard extends StatelessWidget {
  Size? size;
  Adoption adoption;

  AdoptionCard({Key? key, required this.adoption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    return _adoptionBody(context);
  }

  Padding _adoptionBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: double.infinity,
        height: size!.height * 0.41,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              _adoptionImage(context),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size!.width * 0.04,
                    vertical: size!.height * 0.01,
                  ),
                  child: Column(
                    children: [
                      Text(
                        adoption.title.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const FaIcon(
                                    Icons.account_tree_rounded,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    ' ${adoption.petType}/${adoption.petBreed}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const FaIcon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    ' ${adoption.il}/${adoption.ilce}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const FaIcon(
                                    Icons.timer,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    " ${timeago.format(adoption.createdTime.toDate(), locale: "tr")} önce",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _adoptionImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // BottomSheetPage()
        //     .bottomSheet(context, AdoptionDetailsPage(adoption: adoption));
        // bottomSheet(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AdoptionDetailsPage(adoption: adoption)));
      },
      child: Container(
        width: double.infinity,
        height: size!.height * 0.27,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
              image: NetworkImage(adoption.photoOneUrl), fit: BoxFit.fill),
        ),
      ),
    );
  }
}
