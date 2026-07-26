import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TransactionModel {
  final String id;
  final String title;
  final String categoryName;
  final String? walletName;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;
  final DateTime date;
  final String timeText;
  final String note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.categoryName,
    this.walletName = 'Uang Tunai',
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
    required this.date,
    this.timeText = '12:00 WIB',
    this.note = '',
  });

  String get displayWallet => (walletName != null && walletName!.isNotEmpty) ? walletName! : 'Uang Tunai';

  String get formattedDateLabel {
    final now = DateTime.now();
    final isToday = now.year == date.year && now.month == date.month && now.day == date.day;
    final isYesterday = now.year == date.year && now.month == date.month && now.day == (date.day - 1);

    final months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"];
    final monthStr = months[date.month - 1];

    if (isToday) {
      return "Hari ini, $timeText";
    } else if (isYesterday) {
      return "Kemarin, $timeText";
    } else {
      return "${date.day} $monthStr ${date.year}";
    }
  }

  Color get amountColor => isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryName': categoryName,
      'walletName': walletName,
      'amount': amount,
      'isIncome': isIncome,
      'iconCodePoint': icon.codePoint,
      'iconColorValue': iconColor.value,
      'date': date.toIso8601String(),
      'timeText': timeText,
      'note': note,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      categoryName: json['categoryName'] ?? '',
      walletName: json['walletName'] ?? 'Uang Tunai',
      amount: (json['amount'] as num).toDouble(),
      isIncome: json['isIncome'] ?? false,
      icon: IconData(json['iconCodePoint'] ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
      iconColor: Color(json['iconColorValue'] ?? AppTheme.primary.value),
      date: DateTime.parse(json['date']),
      timeText: json['timeText'] ?? '12:00 WIB',
      note: json['note'] ?? '',
    );
  }
}
