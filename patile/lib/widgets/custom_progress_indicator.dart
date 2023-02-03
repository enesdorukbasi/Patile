import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(50)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CollectionScaleTransition(
                children: <Widget>[
                  FaIcon(
                    FontAwesomeIcons.dog,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  FaIcon(
                    FontAwesomeIcons.cat,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  FaIcon(
                    FontAwesomeIcons.userDoctor,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
