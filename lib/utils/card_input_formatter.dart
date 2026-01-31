import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 1. Remove any non-digit characters (including existing spaces)
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 2. Enforce 16-digit limit (standard credit card)
    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    // 3. Add spaces every 4 digits
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();

    // 4. Return the formatted text and keep cursor at the end
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}