import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../models/app_state.dart';
import '../../widgets/sheets/pilih_kategori_sheet.dart';

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

  void _showEditCategoryLimitDialog(String categoryName, double currentLimit) {
    final controller = TextEditingController(
      text: currentLimit > 0 ? CurrencyFormatter.formatRawDigits(currentLimit.toInt().toString()) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.tune, color: AppTheme.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Atur Limit [$categoryName]',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan batas maksimal pengeluaran bulanan untuk kategori ini:',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Nominal Limit Bulanan (Rp)',
                hintText: '0 (Isi 0 untuk menghapus limit)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final cleanText = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
              final amount = double.tryParse(cleanText) ?? 0.0;
              AppState.instance.setCategoryBudget(categoryName, amount);
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan Limit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _addNewCategoryBudget() {
    PilihKategoriSheet.show(
      context,
      onSelectCategory: (cat) {
        _showEditCategoryLimitDialog(cat.name, AppState.instance.categoryBudgets[cat.name] ?? 0.0);
      },
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daftar Limit Kategori",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  InkWell(
                    onTap: _addNewCategoryBudget,
                    child: Row(
                      children: const [
                        Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primary),
                        SizedBox(width: 4),
                        Text(
                          "+ Limit Kategori",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
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
                                      onTap: () => _showEditCategoryLimitDialog(cat.name, limit),
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
