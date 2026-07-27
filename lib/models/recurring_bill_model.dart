import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecurringBillModel {
  final String id;
  final String title;
  final double amount;
  final String categoryName;
  final int dueDateDay; // 1 - 31
  final String repeatInterval; // 'Bulanan', 'Mingguan', 'Tahunan'
  bool isActive;
  final IconData icon;
  final Color _color;
  Color get color => AppTheme.getAdaptiveColor(_color);

  RecurringBillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryName,
    this.dueDateDay = 1,
    this.repeatInterval = 'Bulanan',
    this.isActive = true,
    this.icon = Icons.receipt_long_outlined,
    Color color = AppTheme.defaultPrimary,
  }) : _color = color;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryName': categoryName,
      'dueDateDay': dueDateDay,
      'repeatInterval': repeatInterval,
      'isActive': isActive,
      'iconCodePoint': icon.codePoint,
      'colorValue': _color.value,
    };
  }

  factory RecurringBillModel.fromJson(Map<String, dynamic> json) {
    return RecurringBillModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      categoryName: json['categoryName'] ?? 'Tagihan & Langganan',
      dueDateDay: json['dueDateDay'] ?? 1,
      repeatInterval: json['repeatInterval'] ?? 'Bulanan',
      isActive: json['isActive'] ?? true,
      icon: IconData(json['iconCodePoint'] ?? Icons.receipt_long_outlined.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] ?? AppTheme.primary.value),
    );
  }
}
