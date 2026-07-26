import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class PilihKategoriSheet extends StatefulWidget {
  final Function(CategoryModel) onSelectCategory;
  final VoidCallback? onAddNewCategoryClick;
  final bool isExpense;

  const PilihKategoriSheet({
    super.key,
    required this.onSelectCategory,
    this.onAddNewCategoryClick,
    this.isExpense = true,
  });

  static void show(BuildContext context, {
    required Function(CategoryModel) onSelectCategory,
    bool isExpense = true,
    VoidCallback? onAddNewCategoryClick,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PilihKategoriSheet(
        onSelectCategory: onSelectCategory,
        isExpense: isExpense,
        onAddNewCategoryClick: onAddNewCategoryClick ?? () => _showAddCustomCategoryDialog(context, onSelectCategory),
      ),
    );
  }

  static void _showAddCustomCategoryDialog(
    BuildContext context,
    Function(CategoryModel) onSelect, {
    bool defaultIsExpense = true,
  }) {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.star;
    Color selectedColor = AppTheme.primary;
    bool isExpenseType = defaultIsExpense;

    final List<IconData> availableIcons = [
      Icons.restaurant,
      Icons.directions_car,
      Icons.shopping_bag_outlined,
      Icons.home_outlined,
      Icons.work_outline,
      Icons.laptop_chromebook,
      Icons.card_giftcard,
      Icons.trending_up,
      Icons.sports_esports_outlined,
      Icons.flight_takeoff,
      Icons.medical_services_outlined,
      Icons.school_outlined,
      Icons.bolt,
      Icons.local_gas_station,
      Icons.pets,
      Icons.star_outline,
    ];

    final List<Color> availableColors = [
      AppTheme.primary,
      AppTheme.incomeGreen,
      AppTheme.expenseRed,
      AppTheme.warningAmber,
      AppTheme.purpleAccent,
      AppTheme.pinkAccent,
      AppTheme.accentBlue,
      Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppTheme.surface,
          title: const Text("Tambah Kategori Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Type Switcher
                const Text("Tipe Kategori:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isExpenseType = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isExpenseType ? AppTheme.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isExpenseType ? AppTheme.cardShadow : null,
                            ),
                            child: Center(
                              child: Text(
                                'Pengeluaran',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isExpenseType ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isExpenseType = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !isExpenseType ? AppTheme.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !isExpenseType ? AppTheme.cardShadow : null,
                            ),
                            child: Center(
                              child: Text(
                                'Pemasukan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: !isExpenseType ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Name Input
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nama Kategori",
                    hintText: isExpenseType ? "Misal: Langganan Netflix, Kopi" : "Misal: Komisi Jualan, Dividen",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon Grid
                const Text("Pilih Ikon:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableIcons.map((ic) {
                    final isSel = selectedIcon == ic;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIcon = ic),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: isSel ? Border.all(color: AppTheme.primary, width: 2) : null,
                        ),
                        child: Icon(ic, color: isSel ? AppTheme.primary : AppTheme.textSecondary, size: 22),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color Swatches
                const Text("Pilih Warna:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableColors.map((col) {
                    final isSel = selectedColor == col;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = col),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSel ? [BoxShadow(color: col.withOpacity(0.6), blurRadius: 6)] : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final newCat = CategoryModel(
                    id: 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: selectedColor,
                    group: CategoryGroup.gayaHidup,
                    isExpense: isExpenseType,
                  );
                  AppState.instance.addCustomCategory(newCat);
                  Navigator.pop(ctx);
                  onSelect(newCat);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Simpan Kategori", style: TextStyle(color: AppTheme.textOnPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  static void _showReorderModal(BuildContext context, {bool isExpense = true}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isExpense ? "Urutkan Kategori Pengeluaran" : "Urutkan Kategori Pemasukan",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Selesai", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Geser (drag & drop) item kategori di bawah untuk mengatur urutannya. 4 posisi teratas akan muncul di menu utama.",
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: AppState.instance,
                builder: (context, _) {
                  final categories = isExpense
                      ? AppState.instance.categories.where((c) => c.isExpense != false).toList()
                      : AppCategories.incomeCategories;
                  return ReorderableListView.builder(
                    itemCount: categories.length,
                    onReorder: (oldIndex, newIndex) {
                      if (isExpense) {
                        AppState.instance.reorderCategories(oldIndex, newIndex);
                      }
                    },
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Container(
                        key: ValueKey(cat.id),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: index < 4 ? AppTheme.primaryContainer.withOpacity(0.4) : AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: index < 4 ? Border.all(color: AppTheme.primary.withOpacity(0.5)) : null,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 20),
                          ),
                          title: Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: index < 4 ? FontWeight.bold : FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: index < 4
                              ? const Text("⭐ Tampil di Akses Cepat", style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold))
                              : null,
                          trailing: const Icon(Icons.drag_handle, color: AppTheme.textSecondary),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<PilihKategoriSheet> createState() => _PilihKategoriSheetState();
}

class _PilihKategoriSheetState extends State<PilihKategoriSheet> {
  String searchQuery = "";
  late bool currentIsExpense;

  @override
  void initState() {
    super.initState();
    currentIsExpense = widget.isExpense;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header with Reorder Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pilih Kategori",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => PilihKategoriSheet._showReorderModal(context, isExpense: currentIsExpense),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.swap_vert, size: 16, color: AppTheme.primary),
                          SizedBox(width: 4),
                          Text("Atur Urutan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Segmented Switcher: Pengeluaran vs Pemasukan inside Sheet!
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => currentIsExpense = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: currentIsExpense ? AppTheme.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: currentIsExpense ? AppTheme.cardShadow : null,
                      ),
                      child: Center(
                        child: Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: currentIsExpense ? AppTheme.textPrimary : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => currentIsExpense = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !currentIsExpense ? AppTheme.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: !currentIsExpense ? AppTheme.cardShadow : null,
                      ),
                      child: Center(
                        child: Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: !currentIsExpense ? AppTheme.textPrimary : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Bar
          TextField(
            onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Cari kategori...",
              hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category Grid
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ListenableBuilder(
                listenable: AppState.instance,
                builder: (context, _) {
                  final categories = currentIsExpense
                      ? AppState.instance.categories.where((c) => c.isExpense != false).toList()
                      : AppCategories.incomeCategories;
                  final filteredCats = categories.where((cat) {
                    return searchQuery.isEmpty || cat.name.toLowerCase().contains(searchQuery);
                  }).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: filteredCats.length,
                    itemBuilder: (context, index) {
                      final cat = filteredCats[index];
                      return _buildGridTile(cat);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add Custom Category Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onAddNewCategoryClick != null) {
                  widget.onAddNewCategoryClick!();
                }
              },
              icon: const Icon(Icons.add, color: AppTheme.primary, size: 20),
              label: const Text(
                "Tambah Kategori Baru",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(CategoryModel cat) {
    return InkWell(
      onTap: () {
        widget.onSelectCategory(cat);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat.icon, color: cat.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              cat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
