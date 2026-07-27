import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import 'tambah_kategori_sheet.dart';

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
    TambahKategoriSheet.show(
      context,
      onCategorySaved: onSelect,
      defaultIsExpense: defaultIsExpense,
    );
  }

  static void showManageActionSheet(BuildContext context, CategoryModel cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: BoxDecoration(
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
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Text(cat.isExpense ? "Kategori Pengeluaran" : "Kategori Pemasukan", style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: AppTheme.textSecondary)),
              ],
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(Icons.edit_outlined, color: AppTheme.accentBlue),
              ),
              title: Text("Edit Kategori", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
              subtitle: Text("Ubah nama, warna, atau ikon kategori ini", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _showEditCategoryDialog(context, cat);
              },
            ),
            Divider(color: AppTheme.surfaceContainer, height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.expenseRed.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(Icons.delete_outline, color: AppTheme.expenseRed),
              ),
              title: Text("Hapus Kategori", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.expenseRed)),
              subtitle: Text("Buang dari daftar inventory Anda", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmationDialog(context, cat);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeleteConfirmationDialog(BuildContext context, CategoryModel cat) {
    showDialog(
      context: context,
      builder: (delCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: AppTheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.expenseRed.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseRed, size: 40),
              ),
              SizedBox(height: 18),
              Text(
                "Hapus Kategori '${cat.name}'?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Kategori ini akan dihapus dari daftar pilihan Anda. Transaksi lama yang sudah tercatat memakai kategori ini tetap tersimpan dengan aman.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(delCtx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.8), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(delCtx);
                        AppState.instance.deleteCategory(cat.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Kategori '${cat.name}' telah berhasil dihapus.",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppTheme.expenseRed,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(milliseconds: 2200),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.expenseRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        "Ya, Hapus",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showEditCategoryDialog(BuildContext context, CategoryModel oldCat) {
    TambahKategoriSheet.show(
      context,
      existingCategory: oldCat,
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
      decoration: BoxDecoration(
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
              Text(
                "Pilih Kategori",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppTheme.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 10),

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
          SizedBox(height: 12),

          // Search Bar
          TextField(
            onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Cari kategori...",
              hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16),

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
                            Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.isManageOnly
                                    ? "Mode Kelola: Ketuk item atau ikon titik tiga untuk edit & hapus. Tahan & geser untuk tukar urutan Hotbar (4 Slot Atas)."
                                    : "Ketuk untuk pilih transaksi. Geser untuk scroll. Tahan untuk angkat & atur Hotbar (4 Slot Atas). Ketuk 2x / ikon titik tiga untuk edit & hapus.",
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
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
          SizedBox(height: 16),

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
              icon: Icon(Icons.add, color: AppTheme.primary, size: 20),
              label: Text(
                "Tambah Kategori Baru",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primary),
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
                SizedBox(height: 6),
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
                    Icon(Icons.star_rounded, color: Colors.white, size: 10),
                    SizedBox(width: 2),
                    Text(
                      '${index + 1}',
                      style: TextStyle(
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
              icon: Icon(Icons.more_vert, size: 16, color: AppTheme.textSecondary),
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
              SizedBox(height: 6),
              Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
                : BoxDecoration(),
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
