import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final IconData icon;
  final Color _color;
  Color get color => AppTheme.getAdaptiveColor(_color);
  final DateTime targetDate;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.icon,
    Color color = AppTheme.defaultPrimary,
    required this.targetDate,
  }) : _color = color;

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final ratio = currentAmount / targetAmount;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  int get percentageInt => (progressPercentage * 100).toInt();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'iconCodePoint': icon.codePoint,
      'colorValue': _color.value,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      icon: IconData(json['iconCodePoint'] ?? Icons.savings.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] ?? AppTheme.primary.value),
      targetDate: DateTime.parse(json['targetDate']),
    );
  }
}
