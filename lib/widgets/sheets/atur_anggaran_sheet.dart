import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../models/app_state.dart';

class AturAnggaranSheet extends StatefulWidget {
  final String? initialCategoryName;
  final double initialLimit;
  final Function(String categoryName, double limit, int warningPercent, bool isNotif)? onSaveBudget;

  const AturAnggaranSheet({
    super.key,
    this.initialCategoryName,
    this.initialLimit = 3500000.0,
    this.onSaveBudget,
  });

  static void show(BuildContext context, {
    String? categoryName,
    double currentLimit = 3500000.0,
    Function(String categoryName, double limit, int warningPercent, bool isNotif)? onSaveBudget,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AturAnggaranSheet(
          initialCategoryName: categoryName,
          initialLimit: currentLimit,
          onSaveBudget: onSaveBudget,
        ),
      ),
    );
  }

  @override
  State<AturAnggaranSheet> createState() => _AturAnggaranSheetState();
}

class _AturAnggaranSheetState extends State<AturAnggaranSheet> {
  bool isNotifEnabled = true;
  int warningPercent = 80;

  Widget _buildQuickChip(TextEditingController ctrl, String label, double value) {
    return InkWell(
      onTap: () {
        ctrl.text = CurrencyFormatter.formatRawDigits(value.toInt().toString());
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  void _showEditCategoryLimitDialog(String categoryName, double currentLimit, [IconData? icon, Color? color]) {
    final controller = TextEditingController(
      text: currentLimit > 0 ? CurrencyFormatter.formatRawDigits(currentLimit.toInt().toString()) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: AppTheme.surface,
        elevation: 8,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Megah
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (color ?? AppTheme.primary).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon ?? Icons.tune, color: color ?? AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Kelola Batas Anggaran Bulanan',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 22),
                      splashRadius: 20,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Field Nominal Eksklusif
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nominal Limit Bulanan',
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    hintText: '0 (Bebas Limit)',
                    hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textLight),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Chip Pilihan Nominal Cepat (Bebas Emoji)
                const Text(
                  'Pilihan Nominal Cepat:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickChip(controller, '500 Rb', 500000),
                    _buildQuickChip(controller, '1 Jt', 1000000),
                    _buildQuickChip(controller, '2 Jt', 2000000),
                    _buildQuickChip(controller, '3 Jt', 3000000),
                    _buildQuickChip(controller, '5 Jt', 5000000),
                  ],
                ),
                const SizedBox(height: 24),

                // Tombol Aksi Simpan Megah
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final cleanText = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = double.tryParse(cleanText) ?? 0.0;
                      AppState.instance.setCategoryBudget(categoryName, amount);
                      if (widget.onSaveBudget != null) {
                        widget.onSaveBudget!(categoryName, amount, warningPercent, isNotifEnabled);
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            amount > 0
                                ? "Limit [$categoryName] disetor ke ${CurrencyFormatter.format(amount)}!"
                                : "Limit [$categoryName] dihapus.",
                          ),
                          backgroundColor: amount > 0 ? AppTheme.incomeGreen : AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      elevation: 2,
                      shadowColor: AppTheme.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Simpan & Terapkan Limit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final appState = AppState.instance;
          final categoryBudgets = appState.categoryBudgets;
          final categories = appState.categories;

          // Calculate grand totals for all budgets
          double grandTotalLimit = 0.0;
          double grandTotalSpent = 0.0;

          categoryBudgets.forEach((catName, limit) {
            grandTotalLimit += limit;
            grandTotalSpent += appState.getCategorySpentThisMonth(catName);
          });

          final grandTotalRemaining = grandTotalLimit - grandTotalSpent;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Kelola Limit Anggaran Kategori",
                    style: TextStyle(
                      fontSize: 18,
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
              const SizedBox(height: 12),

              // Grand Total Budget Overview Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A365D), Color(0xFF0F2942)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL KUOTA ANGGARAN KATEGORI",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8), letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.format(grandTotalLimit, showPrefix: true),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: grandTotalRemaining >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            grandTotalRemaining >= 0
                                ? "Sisa Jatah: ${CurrencyFormatter.format(grandTotalRemaining)}"
                                : "Overbudget ${CurrencyFormatter.format(grandTotalRemaining.abs())}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: grandTotalLimit > 0 ? (grandTotalSpent / grandTotalLimit).clamp(0.0, 1.0) : 0.0,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          grandTotalRemaining >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Terpakai: ${CurrencyFormatter.format(grandTotalSpent)} dari total ${CurrencyFormatter.format(grandTotalLimit)}",
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: const [
                  Text(
                    "Daftar Limit Kategori",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Categories List with Visual Progress Bars & Budget Quota!
              Expanded(
                child: categories.isEmpty
                    ? const Center(child: Text("Belum ada kategori."))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final limit = categoryBudgets[cat.name] ?? 0.0;
                          final spent = appState.getCategorySpentThisMonth(cat.name);
                          final remaining = limit - spent;
                          final double rawRatio = limit > 0 ? (spent / limit) : 0.0;
                          final double progress = rawRatio.clamp(0.0, 1.0);
                          final int percentInt = (rawRatio * 100).toInt();

                          Color barColor = AppTheme.primary;
                          if (percentInt >= 90 || remaining < 0) {
                            barColor = AppTheme.expenseRed;
                          } else if (percentInt >= 80) {
                            barColor = AppTheme.warningAmber;
                          } else {
                            barColor = AppTheme.incomeGreen;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: limit > 0 ? barColor.withOpacity(0.4) : AppTheme.outlineVariant.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: cat.color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(cat.icon, color: cat.color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cat.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            limit > 0
                                                ? "Limit: ${CurrencyFormatter.format(limit)}"
                                                : "Belum Diset Limit",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: limit > 0 ? AppTheme.textSecondary : AppTheme.textLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showEditCategoryLimitDialog(cat.name, limit, cat.icon, cat.color),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.edit, size: 13, color: AppTheme.primary),
                                            SizedBox(width: 4),
                                            Text(
                                              "Atur",
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (limit > 0) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: AppTheme.surfaceContainer,
                                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Terpakai: ${CurrencyFormatter.format(spent)} ($percentInt%)",
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        remaining >= 0
                                            ? "Sisa Jatah: ${CurrencyFormatter.format(remaining)}"
                                            : "Overbudget ${CurrencyFormatter.format(remaining.abs())}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: remaining >= 0 ? barColor : AppTheme.expenseRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // Save / Done Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline, color: AppTheme.textOnPrimary, size: 20),
                  label: const Text(
                    "Selesai Pengaturan",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textOnPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
