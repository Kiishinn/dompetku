import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/app_state.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/sheets/notifikasi_sheet.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime selectedMonth = DateTime.now();
  bool isExpenseMode = true;

  final List<String> monthNames = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  final List<String> shortMonthNames = [
    "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
    "Jul", "Agt", "Sep", "Okt", "Nov", "Des"
  ];

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  double _calculateMonthlyTotal(List<TransactionModel> allTx, DateTime monthDate, bool isExpense) {
    return allTx.where((tx) {
      return tx.date.year == monthDate.year &&
          tx.date.month == monthDate.month &&
          tx.isIncome == !isExpense;
    }).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      final inJuta = value / 1000000;
      return "Rp ${inJuta.toStringAsFixed(inJuta.truncateToDouble() == inJuta ? 0 : 1)} Jt";
    } else if (value >= 1000) {
      final inRibu = value / 1000;
      return "Rp ${inRibu.toStringAsFixed(0)} Rb";
    } else {
      return "Rp ${value.toInt()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final allTransactions = appState.transactions;
    final unreadNotifCount = appState.unreadNotificationCount;

    // Current month transactions
    final currentMonthTx = allTransactions.where((tx) {
      return tx.date.year == selectedMonth.year &&
          tx.date.month == selectedMonth.month &&
          tx.isIncome == !isExpenseMode;
    }).toList();

    final currentTotal = _calculateMonthlyTotal(allTransactions, selectedMonth, isExpenseMode);

    // Previous month total for comparison percentage
    final prevMonthDate = DateTime(selectedMonth.year, selectedMonth.month - 1);
    final prevTotal = _calculateMonthlyTotal(allTransactions, prevMonthDate, isExpenseMode);

    double percentChange = 0.0;
    if (prevTotal > 0) {
      percentChange = ((currentTotal - prevTotal) / prevTotal) * 100;
    } else if (currentTotal > 0) {
      percentChange = 100.0;
    }

    // Category breakdown
    final Map<String, double> categoryTotals = {};
    final Map<String, Color> categoryColors = {};
    final Map<String, IconData> categoryIcons = {};

    for (var tx in currentMonthTx) {
      categoryTotals[tx.categoryName] = (categoryTotals[tx.categoryName] ?? 0.0) + tx.amount;
      categoryColors[tx.categoryName] = tx.iconColor;
      categoryIcons[tx.categoryName] = tx.icon;
    }

    // Calculate 6-Month history for Bar Chart
    final List<DateTime> chartMonths = List.generate(6, (i) {
      return DateTime(selectedMonth.year, selectedMonth.month - (5 - i));
    });

    final List<double> chartTotals = chartMonths.map((m) {
      return _calculateMonthlyTotal(allTransactions, m, isExpenseMode);
    }).toList();

    double maxChartValue = chartTotals.fold(0.0, (max, v) => v > max ? v : max);
    if (maxChartValue == 0) maxChartValue = 1.0; // avoid division by zero

    final activeColor = isExpenseMode ? AppTheme.expenseRed : AppTheme.incomeGreen;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Statistik Keuangan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                        onPressed: () => NotifikasiSheet.show(context),
                      ),
                    ),
                    if (unreadNotifCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.expenseRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadNotifCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Month Navigator Bar ([📅 Juli 2026] < >)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        '${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: _previousMonth,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.chevron_left, color: AppTheme.primary, size: 24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _nextMonth,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.chevron_right, color: AppTheme.primary, size: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Segmented Switcher (Pengeluaran vs Pemasukan)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpenseMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isExpenseMode ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isExpenseMode ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpenseMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isExpenseMode ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: !isExpenseMode ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Total Card Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpenseMode ? 'Total Pengeluaran' : 'Total Pemasukan',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(currentTotal, showPrefix: true),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        percentChange >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: percentChange >= 0 ? AppTheme.expenseRed : AppTheme.incomeGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(0)}% dibanding bulan lalu',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 6-Month Bar Chart
                  SizedBox(
                    height: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(chartMonths.length, (index) {
                        final mDate = chartMonths[index];
                        final val = chartTotals[index];
                        final isSelectedMonth = mDate.year == selectedMonth.year && mDate.month == selectedMonth.month;
                        final double barHeightRatio = (val / maxChartValue).clamp(0.08, 1.0);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isSelectedMonth && val > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatShortCurrency(val),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else if (isSelectedMonth && val == 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "Rp 0",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 22),

                            Container(
                              width: 24,
                              height: 100 * barHeightRatio,
                              decoration: BoxDecoration(
                                color: isSelectedMonth ? activeColor : AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              shortMonthNames[mDate.month - 1],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelectedMonth ? FontWeight.bold : FontWeight.w500,
                                color: isSelectedMonth ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Analisis Kategori Header & fl_chart Pie Chart
            const Text(
              'Analisis Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            if (categoryTotals.isNotEmpty) ...[
              // fl_chart Interactive Pie Chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 42,
                      sections: categoryTotals.entries.map((entry) {
                        final catName = entry.key;
                        final amount = entry.value;
                        final percent = currentTotal > 0 ? (amount / currentTotal) : 0.0;
                        final color = categoryColors[catName] ?? activeColor;
                        return PieChartSectionData(
                          color: color,
                          value: amount,
                          title: '${(percent * 100).toInt()}%',
                          radius: 46,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Category Breakdown Items or Empty Placeholder
            categoryTotals.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.pie_chart_outline, size: 40, color: AppTheme.textLight),
                        const SizedBox(height: 10),
                        Text(
                          "Belum Ada ${isExpenseMode ? 'Pengeluaran' : 'Pemasukan'}",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tidak ada transaksi pada bulan ${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: categoryTotals.entries.map((entry) {
                      final catName = entry.key;
                      final amount = entry.value;
                      final percent = currentTotal > 0 ? (amount / currentTotal) : 0.0;
                      final color = categoryColors[catName] ?? activeColor;
                      final icon = categoryIcons[catName] ?? Icons.category;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        catName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        CurrencyFormatter.format(amount),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(percent * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 6,
                                backgroundColor: AppTheme.surfaceContainerLow,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
