import 'package:flutter/material.dart';

class AppBars {
  AppBar transparentBackgroundAppBar(
    BuildContext context,
    String? title,
    List<Widget>? actions,
    bool automaticallyImplyLeading,
    bool titleColorIsWhite,
    TabBar? bottom,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      bottom: bottom,
      elevation: 0,
      title: Text(
        title!,
        style: TextStyle(
          color:
              titleColorIsWhite ? Colors.white : Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      iconTheme: IconThemeData(
          color: titleColorIsWhite
              ? Colors.white
              : Theme.of(context).primaryColor),
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  AppBar colorBackgroundAppbar(
      BuildContext context, String? title, List<Widget>? actions) {
    return AppBar(
      title: Text(title!),
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColorDark,
      elevation: 1,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }
}
