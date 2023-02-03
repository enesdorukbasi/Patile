import 'package:flutter/material.dart';

class CustomInputDecorations {
  InputDecoration inputDecoration1(
    BuildContext context,
    String selectedLabel,
    Widget? selectedIcon,
  ) {
    return InputDecoration(
      label: Text(selectedLabel),
      prefixIcon: selectedIcon,
      labelStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      fillColor: Theme.of(context).primaryColorLight.withOpacity(0.7),
      filled: true,
    );
  }

  InputDecoration inputDecoration2(
    BuildContext context,
    String selectedHint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  ) {
    return InputDecoration(
      hintText: selectedHint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).backgroundColor,
          width: 2.0,
        ),
      ),
      fillColor: Theme.of(context).primaryColorLight.withOpacity(0.7),
      filled: true,
    );
  }
}
