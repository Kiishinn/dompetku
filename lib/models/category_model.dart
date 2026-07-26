import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CategoryGroup {
  kebutuhanUtama('KEBUTUHAN UTAMA'),
  gayaHidup('GAYA HIDUP'),
  finansial('FINANSIAL');

  final String title;
  const CategoryGroup(this.title);
}

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final CategoryGroup group;
  final bool isExpense;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.color = AppTheme.primary,
    required this.group,
    this.isExpense = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'groupName': group.name,
      'isExpense': isExpense,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: IconData(json['iconCodePoint'] ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] ?? AppTheme.primary.value),
      group: CategoryGroup.values.firstWhere(
        (g) => g.name == (json['groupName'] ?? 'gayaHidup'),
        orElse: () => CategoryGroup.gayaHidup,
      ),
      isExpense: json['isExpense'] ?? true,
    );
  }
}

class AppCategories {
  static const List<CategoryModel> incomeCategories = [
    CategoryModel(
      id: 'cat_salary',
      name: 'Gaji & Pendapatan',
      icon: Icons.payments_outlined,
      color: AppTheme.incomeGreen,
      group: CategoryGroup.finansial,
      isExpense: false,
    ),
    CategoryModel(
      id: 'cat_freelance',
      name: 'Freelance & Sampingan',
      icon: Icons.laptop_chromebook,
      color: AppTheme.accentBlue,
      group: CategoryGroup.finansial,
      isExpense: false,
    ),
    CategoryModel(
      id: 'cat_bonus',
      name: 'Bonus & Hadiah',
      icon: Icons.card_giftcard,
      color: Colors.orange,
      group: CategoryGroup.finansial,
      isExpense: false,
    ),
    CategoryModel(
      id: 'cat_investment_inc',
      name: 'Investasi & Bunga',
      icon: Icons.trending_up,
      color: AppTheme.purpleAccent,
      group: CategoryGroup.finansial,
      isExpense: false,
    ),
    CategoryModel(
      id: 'cat_other_income',
      name: 'Pemasukan Lainnya',
      icon: Icons.add_chart,
      color: Colors.teal,
      group: CategoryGroup.finansial,
      isExpense: false,
    ),
  ];

  static const List<CategoryModel> allCategories = [
    // Kebutuhan Utama
    CategoryModel(
      id: 'cat_food',
      name: 'Makan & Minum',
      icon: Icons.restaurant,
      color: AppTheme.expenseRed,
      group: CategoryGroup.kebutuhanUtama,
    ),
    CategoryModel(
      id: 'cat_transport',
      name: 'Transportasi',
      icon: Icons.directions_car,
      color: AppTheme.accentBlue,
      group: CategoryGroup.kebutuhanUtama,
    ),
    CategoryModel(
      id: 'cat_shopping',
      name: 'Belanja',
      icon: Icons.shopping_cart_outlined,
      color: AppTheme.pinkAccent,
      group: CategoryGroup.kebutuhanUtama,
    ),
    CategoryModel(
      id: 'cat_bills',
      name: 'Tagihan',
      icon: Icons.receipt_long,
      color: AppTheme.purpleAccent,
      group: CategoryGroup.kebutuhanUtama,
    ),
    CategoryModel(
      id: 'cat_health',
      name: 'Kesehatan',
      icon: Icons.medical_services_outlined,
      color: AppTheme.incomeGreen,
      group: CategoryGroup.kebutuhanUtama,
    ),
    CategoryModel(
      id: 'cat_edu',
      name: 'Pendidikan',
      icon: Icons.school_outlined,
      color: AppTheme.primary,
      group: CategoryGroup.kebutuhanUtama,
    ),

    // Gaya Hidup
    CategoryModel(
      id: 'cat_entertainment',
      name: 'Hiburan',
      icon: Icons.movie_outlined,
      color: Colors.orange,
      group: CategoryGroup.gayaHidup,
    ),
    CategoryModel(
      id: 'cat_hobby',
      name: 'Hobi',
      icon: Icons.sports_esports_outlined,
      color: Colors.teal,
      group: CategoryGroup.gayaHidup,
    ),
    CategoryModel(
      id: 'cat_sport',
      name: 'Olahraga',
      icon: Icons.fitness_center,
      color: AppTheme.primary,
      group: CategoryGroup.gayaHidup,
    ),
    CategoryModel(
      id: 'cat_beauty',
      name: 'Kecantikan',
      icon: Icons.spa_outlined,
      color: AppTheme.pinkAccent,
      group: CategoryGroup.gayaHidup,
    ),
    CategoryModel(
      id: 'cat_travel',
      name: 'Liburan',
      icon: Icons.flight_takeoff,
      color: AppTheme.accentBlue,
      group: CategoryGroup.gayaHidup,
    ),
    CategoryModel(
      id: 'cat_dineout',
      name: 'Makan Luar',
      icon: Icons.local_cafe_outlined,
      color: AppTheme.warningAmber,
      group: CategoryGroup.gayaHidup,
    ),

    // Finansial
    CategoryModel(
      id: 'cat_savings',
      name: 'Tabungan',
      icon: Icons.savings_outlined,
      color: AppTheme.incomeGreen,
      group: CategoryGroup.finansial,
    ),
    CategoryModel(
      id: 'cat_investment',
      name: 'Investasi',
      icon: Icons.trending_up,
      color: AppTheme.accentBlue,
      group: CategoryGroup.finansial,
    ),
    CategoryModel(
      id: 'cat_installment',
      name: 'Cicilan',
      icon: Icons.credit_card,
      color: AppTheme.expenseRed,
      group: CategoryGroup.finansial,
    ),
    CategoryModel(
      id: 'cat_insurance',
      name: 'Asuransi',
      icon: Icons.security_outlined,
      color: AppTheme.primary,
      group: CategoryGroup.finansial,
    ),
    CategoryModel(
      id: 'cat_tax',
      name: 'Pajak',
      icon: Icons.account_balance_outlined,
      color: AppTheme.purpleAccent,
      group: CategoryGroup.finansial,
    ),
    CategoryModel(
      id: 'cat_charity',
      name: 'Sedekah',
      icon: Icons.volunteer_activism_outlined,
      color: AppTheme.incomeGreen,
      group: CategoryGroup.finansial,
    ),
  ];

  static List<CategoryModel> getQuickCategories() {
    return [
      allCategories[0], // Makan
      allCategories[1], // Transport
      allCategories[2], // Belanja
      allCategories[4], // Kesehatan
      allCategories[3], // Tagihan
    ];
  }

  static List<CategoryModel> getByGroup(CategoryGroup group) {
    return allCategories.where((c) => c.group == group).toList();
  }
}
