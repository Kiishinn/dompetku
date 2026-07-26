import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/app_state.dart';
import '../widgets/sheets/pilih_kategori_sheet.dart';
import '../theme/app_theme.dart';

class CategorySelectScreen extends StatefulWidget {
  final bool isManageOnly;
  const CategorySelectScreen({super.key, this.isManageOnly = false});

  @override
  State<CategorySelectScreen> createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends State<CategorySelectScreen> {
  String searchQuery = '';
  bool isExpense = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Pilih Kategori',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Segmented Switcher: Pengeluaran vs Pemasukan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isExpense = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isExpense ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isExpense ? AppTheme.cardShadow : null,
                          ),
                          child: Center(
                            child: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isExpense ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isExpense = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isExpense ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: !isExpense ? AppTheme.cardShadow : null,
                          ),
                          child: Center(
                            child: Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !isExpense ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari kategori...',
                    hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 15),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppTheme.textSecondary, size: 22),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Category Display Grid with Game Inventory Style
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: ListenableBuilder(
                  listenable: AppState.instance,
                  builder: (context, _) {
                    final categories = isExpense
                        ? AppState.instance.categories.where((c) => c.isExpense != false).toList()
                        : AppState.instance.categories.where((c) => !c.isExpense).toList();
                    final filteredCats = categories.where((cat) {
                      return searchQuery.isEmpty || cat.name.toLowerCase().contains(searchQuery);
                    }).toList();

                    if (filteredCats.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text("Tidak ada kategori ditemukan", style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 16),
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
                                      : "Ketuk untuk pilih. Geser untuk scroll. Tahan untuk angkat & atur Hotbar (4 Slot Atas). Ketuk 2x / ikon titik tiga untuk edit & hapus.",
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
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: filteredCats.length,
                          itemBuilder: (context, index) {
                            final cat = filteredCats[index];
                            return _buildGridTile(cat, index, isExpense);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(CategoryModel cat, int index, bool currentIsExpense) {
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
        AppState.instance.swapCategorySlots(fromIndex, index, isExpense: currentIsExpense);
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
