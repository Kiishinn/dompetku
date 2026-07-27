import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../models/category_model.dart';

class TambahKategoriSheet extends StatefulWidget {
  final CategoryModel? existingCategory;
  final Function(CategoryModel)? onCategorySaved;
  final bool defaultIsExpense;

  const TambahKategoriSheet({
    super.key,
    this.existingCategory,
    this.onCategorySaved,
    this.defaultIsExpense = true,
  });

  static void show(
    BuildContext context, {
    CategoryModel? existingCategory,
    Function(CategoryModel)? onCategorySaved,
    bool defaultIsExpense = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TambahKategoriSheet(
        existingCategory: existingCategory,
        onCategorySaved: onCategorySaved,
        defaultIsExpense: defaultIsExpense,
      ),
    );
  }

  @override
  State<TambahKategoriSheet> createState() => _TambahKategoriSheetState();
}

class _TambahKategoriSheetState extends State<TambahKategoriSheet> {
  late final TextEditingController _nameController;
  late bool _isExpenseType;
  late IconData _selectedIcon;
  late Color _selectedColor;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car_filled,
    Icons.shopping_bag_rounded,
    Icons.home_rounded,
    Icons.work_rounded,
    Icons.laptop_chromebook,
    Icons.card_giftcard,
    Icons.trending_up_rounded,
    Icons.sports_esports_rounded,
    Icons.flight_takeoff_rounded,
    Icons.medical_services_rounded,
    Icons.school_rounded,
    Icons.bolt_rounded,
    Icons.local_gas_station_rounded,
    Icons.pets_rounded,
    Icons.star_rounded,
    Icons.fitness_center_rounded,
    Icons.theater_comedy_rounded,
    Icons.monetization_on_rounded,
    Icons.celebration_rounded,
  ];

  final List<Color> _availableColors = [
    AppTheme.primary,
    AppTheme.incomeGreen,
    AppTheme.expenseRed,
    AppTheme.warningAmber,
    AppTheme.purpleAccent,
    AppTheme.pinkAccent,
    AppTheme.accentBlue,
    const Color(0xFF0D9488), // Teal
    const Color(0xFFEA580C), // Orange
    const Color(0xFF4F46E5), // Indigo
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      _nameController = TextEditingController(text: widget.existingCategory!.name);
      _isExpenseType = widget.existingCategory!.isExpense;
      _selectedIcon = widget.existingCategory!.icon;
      _selectedColor = widget.existingCategory!.color;
    } else {
      _nameController = TextEditingController();
      _isExpenseType = widget.defaultIsExpense;
      _selectedIcon = Icons.shopping_bag_rounded;
      _selectedColor = AppTheme.primary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama kategori terlebih dahulu.'),
          backgroundColor: AppTheme.expenseRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.existingCategory != null) {
      final updatedCat = CategoryModel(
        id: widget.existingCategory!.id,
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        group: widget.existingCategory!.group,
        isExpense: _isExpenseType,
      );
      AppState.instance.updateCategory(widget.existingCategory!.id, updatedCat);
      if (widget.onCategorySaved != null) {
        widget.onCategorySaved!(updatedCat);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kategori '$name' berhasil diperbarui!"),
          backgroundColor: _selectedColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final newCat = CategoryModel(
        id: 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        icon: _selectedIcon,
        color: _selectedColor,
        group: CategoryGroup.gayaHidup,
        isExpense: _isExpenseType,
      );
      AppState.instance.addCustomCategory(newCat);
      if (widget.onCategorySaved != null) {
        widget.onCategorySaved!(newCat);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kategori baru '$name' berhasil ditambahkan!"),
          backgroundColor: _selectedColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.existingCategory != null;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle and sticky header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _selectedColor.withOpacity(0.4), width: 1.5),
                          ),
                          child: Icon(_selectedIcon, color: _selectedColor, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? "Edit Kategori" : "Tambah Kategori Baru",
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              "Kustomisasi ikon, warna, & jenis",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerLow,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: AppTheme.outlineVariant, height: 1, thickness: 0.5),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Category Type Selector
                  const Text(
                    "TIPE KATEGORI",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        // Pengeluaran button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isExpenseType = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isExpenseType ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: _isExpenseType
                                    ? Border.all(color: AppTheme.expenseRed.withOpacity(0.4), width: 1.5)
                                    : null,
                                boxShadow: _isExpenseType
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.expenseRed.withOpacity(0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.trending_down_rounded,
                                    size: 18,
                                    color: _isExpenseType ? AppTheme.expenseRed : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _isExpenseType ? FontWeight.bold : FontWeight.w600,
                                      color: _isExpenseType ? AppTheme.expenseRed : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Pemasukan button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isExpenseType = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isExpenseType ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: !_isExpenseType
                                    ? Border.all(color: AppTheme.incomeGreen.withOpacity(0.4), width: 1.5)
                                    : null,
                                boxShadow: !_isExpenseType
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.incomeGreen.withOpacity(0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    size: 18,
                                    color: !_isExpenseType ? AppTheme.incomeGreen : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: !_isExpenseType ? FontWeight.bold : FontWeight.w600,
                                      color: !_isExpenseType ? AppTheme.incomeGreen : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Input Nama Kategori
                  const Text(
                    "NAMA KATEGORI",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: _isExpenseType
                          ? "Contoh: Kuliner Malam, Langganan Netflix, Kopi..."
                          : "Contoh: Komisi Freelance, Dividen, Cash & Reward...",
                      hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.normal),
                      filled: true,
                      fillColor: AppTheme.surfaceContainerLow,
                      prefixIcon: Icon(_selectedIcon, color: _selectedColor, size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _selectedColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Pilih Ikon Grid
                  const Text(
                    "PILIH IKON KATEGORI",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final ic = _availableIcons[index];
                      final isSel = _selectedIcon.codePoint == ic.codePoint;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = ic),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSel ? _selectedColor.withOpacity(0.14) : AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? _selectedColor : AppTheme.outlineVariant.withOpacity(0.5),
                              width: isSel ? 2.0 : 1.0,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: _selectedColor.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            ic,
                            color: isSel ? _selectedColor : AppTheme.textSecondary.withOpacity(0.7),
                            size: isSel ? 26 : 22,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 26),

                  // 4. Pilih Warna Swatch
                  const Text(
                    "PILIH WARNA TEMA",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: _availableColors.map((col) {
                      final isSel = _selectedColor.value == col.value;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = col),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: col,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? Colors.white : Colors.transparent,
                              width: isSel ? 3.5 : 0,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: col.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: isSel
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saveCategory,
                      icon: const Icon(Icons.check_circle_rounded, color: AppTheme.textOnPrimary, size: 22),
                      label: Text(
                        isEditing ? "Simpan Perubahan" : "Simpan Kategori Baru",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedColor,
                        elevation: 4,
                        shadowColor: _selectedColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
