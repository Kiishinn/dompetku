import 'package:flutter/services.dart';

class CurrencyFormatter {
  /// Formats a double into Rupiah format: e.g. 15000000 -> Rp 15.000.000
  static String format(double amount, {bool showPrefix = true, bool isIncome = true, bool withSign = false}) {
    bool isNegative = amount < 0;
    String value = amount.abs().toInt().toString();
    String formatted = formatRawDigits(value);

    if (!showPrefix) {
      return isNegative ? '-$formatted' : formatted;
    }

    if (withSign) {
      String sign = isIncome ? '+ ' : '- ';
      return '$sign' 'Rp $formatted';
    }

    return isNegative ? '- Rp $formatted' : 'Rp $formatted';
  }

  /// Helper to format raw numeric string with dot thousands separators (e.g. "10000" -> "10.000")
  static String formatRawDigits(String digits) {
    String clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '0';
    
    try {
      clean = BigInt.parse(clean).toString();
    } catch (_) {}

    String formatted = '';
    int count = 0;
    for (int i = clean.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = clean[i] + formatted;
      count++;
    }
    return formatted;
  }
}

/// Custom TextInputFormatter for automatic live dot thousands separator (10000 -> 10.000)
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = CurrencyFormatter.formatRawDigits(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
