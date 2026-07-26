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

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.color = AppTheme.primary,
    required this.group,
  });
}

class AppCategories {
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
