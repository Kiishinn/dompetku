import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class PilihKategoriSheet extends StatefulWidget {
  final Function(CategoryModel)? onSelectCategory;
  final VoidCallback? onAddNewCategoryClick;
  final bool isExpense;
  final bool isManageOnly;

  const PilihKategoriSheet({
    super.key,
    this.onSelectCategory,
    this.onAddNewCategoryClick,
    this.isExpense = true,
    this.isManageOnly = false,
  });

  static void show(BuildContext context, {
    Function(CategoryModel)? onSelectCategory,
    bool isExpense = true,
    bool isManageOnly = false,
    VoidCallback? onAddNewCategoryClick,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PilihKategoriSheet(
        onSelectCategory: onSelectCategory,
        isExpense: isExpense,
        isManageOnly: isManageOnly,
        onAddNewCategoryClick: onAddNewCategoryClick ?? () => _showAddCustomCategoryDialog(context, onSelectCategory),
      ),
    );
  }

  static void _showAddCustomCategoryDialog(
    BuildContext context,
    Function(CategoryModel)? onSelect, {
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
                  if (onSelect != null) onSelect(newCat);
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

  static void showManageActionSheet(BuildContext context, CategoryModel cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppTheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: cat.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(cat.icon, color: cat.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Text(cat.isExpense ? "Kategori Pengeluaran" : "Kategori Pemasukan", style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.edit_outlined, color: AppTheme.accentBlue),
              ),
              title: const Text("Edit Kategori", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
              subtitle: const Text("Ubah nama, warna, atau ikon kategori ini", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _showEditCategoryDialog(context, cat);
              },
            ),
            const Divider(color: AppTheme.surfaceContainer, height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.expenseRed.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: AppTheme.expenseRed),
              ),
              title: const Text("Hapus Kategori", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.expenseRed)),
              subtitle: const Text("Buang dari daftar inventory Anda", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _executeDeleteWithUndo(context, cat);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _executeDeleteWithUndo(BuildContext context, CategoryModel cat) {
    final index = AppState.instance.categories.indexWhere((c) => c.id == cat.id);
    final deleted = AppState.instance.deleteCategory(cat.id);
    if (deleted != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kategori '${cat.name}' telah dibuang.", style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: "BATALKAN (UNDO)",
            textColor: AppTheme.primary,
            onPressed: () {
              AppState.instance.restoreCategory(deleted, index: index >= 0 ? index : null);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  static void _showEditCategoryDialog(BuildContext context, CategoryModel oldCat) {
    final TextEditingController nameController = TextEditingController(text: oldCat.name);
    IconData selectedIcon = oldCat.icon;
    Color selectedColor = oldCat.color;
    bool isExpenseType = oldCat.isExpense;

    final List<IconData> availableIcons = [
      Icons.restaurant, Icons.directions_car, Icons.shopping_bag_outlined, Icons.home_outlined,
      Icons.work_outline, Icons.laptop_chromebook, Icons.card_giftcard, Icons.trending_up,
      Icons.sports_esports_outlined, Icons.flight_takeoff, Icons.medical_services_outlined, Icons.school_outlined,
      Icons.bolt, Icons.local_gas_station, Icons.pets, Icons.star_outline,
    ];

    final List<Color> availableColors = [
      AppTheme.primary, AppTheme.incomeGreen, AppTheme.expenseRed, AppTheme.warningAmber,
      AppTheme.purpleAccent, AppTheme.pinkAccent, AppTheme.accentBlue, Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppTheme.surface,
          title: const Text("Edit Kategori", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tipe Kategori:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
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
                              child: Text('Pengeluaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isExpenseType ? AppTheme.textPrimary : AppTheme.textSecondary)),
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
                              child: Text('Pemasukan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: !isExpenseType ? AppTheme.textPrimary : AppTheme.textSecondary)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Nama Kategori:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Contoh: Kuliner Harian",
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Pilih Ikon:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((ic) {
                    final isSel = selectedIcon == ic || selectedIcon.codePoint == ic.codePoint;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIcon = ic),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? selectedColor.withOpacity(0.2) : AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: isSel ? Border.all(color: selectedColor, width: 2) : null,
                        ),
                        child: Icon(ic, color: isSel ? selectedColor : AppTheme.textSecondary, size: 22),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text("Pilih Warna:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: availableColors.map((col) {
                    final isSel = selectedColor.value == col.value;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = col),
                      child: Container(
                        width: 34,
                        height: 34,
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
                  final updatedCat = CategoryModel(
                    id: oldCat.id,
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: selectedColor,
                    group: oldCat.group,
                    isExpense: isExpenseType,
                  );
                  AppState.instance.updateCategory(oldCat.id, updatedCat);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Simpan Perubahan", style: TextStyle(color: AppTheme.textOnPrimary)),
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
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
                      : AppState.instance.categories.where((c) => !c.isExpense).toList();
                  final filteredCats = categories.where((cat) {
                    return searchQuery.isEmpty || cat.name.toLowerCase().contains(searchQuery);
                  }).toList();

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.isManageOnly
                                    ? "Mode Kelola: Ketuk item atau ikon titik tiga untuk edit & hapus. Tahan & geser untuk tukar urutan Hotbar (4 Slot Atas)."
                                    : "Ketuk untuk pilih transaksi. Geser untuk scroll. Tahan untuk angkat & atur Hotbar (4 Slot Atas). Ketuk 2x / ikon titik tiga untuk edit & hapus.",
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: filteredCats.length,
                        itemBuilder: (context, index) {
                          final cat = filteredCats[index];
                          return _buildGridTile(cat, index, currentIsExpense);
                        },
                      ),
                    ],
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

  Widget _buildGridTile(CategoryModel cat, int index, bool isExpense) {
    final isHotbar = index < 4;

    final tileContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isHotbar
            ? Border.all(color: AppTheme.warningAmber, width: 1.8)
            : Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: isHotbar
            ? [BoxShadow(color: AppTheme.warningAmber.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)]
            : AppTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isHotbar ? FontWeight.w700 : FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isHotbar)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppTheme.warningAmber,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: AppTheme.warningAmber.withOpacity(0.4), blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.more_vert, size: 16, color: AppTheme.textSecondary),
              splashRadius: 16,
              onPressed: () => PilihKategoriSheet.showManageActionSheet(context, cat),
            ),
          ),
        ],
      ),
    );

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 1.1,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: cat.color.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)],
            border: Border.all(color: cat.color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat.icon, color: cat.color, size: 28),
              const SizedBox(height: 6),
              Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ),
    );

    return DragTarget<int>(
      onWillAccept: (fromIndex) => fromIndex != null && fromIndex != index,
      onAccept: (fromIndex) {
        AppState.instance.swapCategorySlots(fromIndex, index, isExpense: isExpense);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return LongPressDraggable<int>(
          data: index,
          feedback: feedbackWidget,
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: tileContent,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: isHighlighted
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.warningAmber, width: 2.5),
                  )
                : const BoxDecoration(),
            child: InkWell(
              onTap: () {
                if (widget.isManageOnly) {
                  PilihKategoriSheet.showManageActionSheet(context, cat);
                } else {
                  if (widget.onSelectCategory != null) {
                    widget.onSelectCategory!(cat);
                  }
                  Navigator.pop(context, cat);
                }
              },
              onDoubleTap: widget.isManageOnly ? null : () => PilihKategoriSheet.showManageActionSheet(context, cat),
              borderRadius: BorderRadius.circular(16),
              child: tileContent,
            ),
          ),
        );
      },
    );
  }
}
