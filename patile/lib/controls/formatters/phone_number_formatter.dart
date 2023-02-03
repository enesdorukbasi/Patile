import 'package:flutter/services.dart';

class NumberTextInputFormatter extends TextInputFormatter {
  String internationalPhoneFormat(value) {
    String nums = value.replaceAll(RegExp(r'[^0-9]'), '');
    String internationalPhoneFormatted = nums.isNotEmpty
        ? '+${nums.substring(0, nums.length >= 2 ? 2 : null)}${nums.length > 2 ? ' (' : ''}${nums.substring(2, nums.length >= 5 ? 5 : null)}${nums.length > 5 ? ') ' : ''}${nums.length > 5 ? nums.substring(5, nums.length >= 8 ? 8 : null) + (nums.length > 8 ? '-${nums.substring(8, nums.length >= 12 ? 12 : null)}' : '') : ''}'
        : nums;
    return internationalPhoneFormatted;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    return newValue.copyWith(
        text: internationalPhoneFormat(text),
        selection: TextSelection.collapsed(
            offset: internationalPhoneFormat(text).length));
  }
}
