import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlashMessages {
  flasMessages1({
    required String title,
    required String message,
    required FlashMessageTypes type,
    required String svgPath,
  }) {
    Color backgroundColors;
    Color? svgColors;
    if (type == FlashMessageTypes.error) {
      backgroundColors = Colors.red;
      svgColors = Colors.red[900];
    } else if (type == FlashMessageTypes.succes) {
      backgroundColors = Colors.green;
      svgColors = Colors.green[900];
    } else {
      backgroundColors = Colors.blue;
      svgColors = Colors.blue[900];
    }

    return SnackBar(
      content: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
              color: backgroundColors,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            left: 5,
            child: SvgPicture.asset(
              svgPath,
              height: 48,
              width: 40,
              color: svgColors,
            ),
          )
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

enum FlashMessageTypes {
  succes,
  error,
  info,
}
