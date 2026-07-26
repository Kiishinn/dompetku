import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/sheets/notifikasi_sheet.dart';

enum StatsPeriod { harian, mingguan, bulanan, tahunan }
enum ChartType { bar, line }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime selectedMonth = DateTime.now();
  bool isExpenseMode = true;
  StatsPeriod activePeriod = StatsPeriod.bulanan;
  ChartType activeChartType = ChartType.bar;

  final List<String> monthNames = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  final List<String> shortMonthNames = [
    "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
    "Jul", "Agt", "Sep", "Okt", "Nov", "Des"
  ];

  final List<String> dayNames = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Ming"];

  void _previousPeriod() {
    setState(() {
      if (activePeriod == StatsPeriod.harian) {
        selectedMonth = selectedMonth.subtract(const Duration(days: 1));
      } else if (activePeriod == StatsPeriod.mingguan) {
        selectedMonth = selectedMonth.subtract(const Duration(days: 7));
      } else if (activePeriod == StatsPeriod.tahunan) {
        selectedMonth = DateTime(selectedMonth.year - 1, selectedMonth.month, selectedMonth.day);
      } else {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, selectedMonth.day > 28 ? 28 : selectedMonth.day);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (activePeriod == StatsPeriod.harian) {
        selectedMonth = selectedMonth.add(const Duration(days: 1));
      } else if (activePeriod == StatsPeriod.mingguan) {
        selectedMonth = selectedMonth.add(const Duration(days: 7));
      } else if (activePeriod == StatsPeriod.tahunan) {
        selectedMonth = DateTime(selectedMonth.year + 1, selectedMonth.month, selectedMonth.day);
      } else {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, selectedMonth.day > 28 ? 28 : selectedMonth.day);
      }
    });
  }

  void _useCurrentPeriod() {
    setState(() {
      selectedMonth = DateTime.now();
    });
  }

  void _showPeriodPickerSheet() {
    StatsPeriod tempPeriod = activePeriod;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Rentang & Waktu',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    TextButton(
                      onPressed: () {
                        _useCurrentPeriod();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Hari/Bulan Ini', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Period Mode Segmented Selector (Harian, Mingguan, Bulanan, Tahunan)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: StatsPeriod.values.map((period) {
                      final isSelected = tempPeriod == period;
                      String label = "";
                      switch (period) {
                        case StatsPeriod.harian:
                          label = "Harian";
                          break;
                        case StatsPeriod.mingguan:
                          label = "Mingguan";
                          break;
                        case StatsPeriod.bulanan:
                          label = "Bulanan";
                          break;
                        case StatsPeriod.tahunan:
                          label = "Tahunan";
                          break;
                      }
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setSheetState(() => tempPeriod = period);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Dynamic Picker Content with AnimatedSwitcher (Smooth 60/120fps transition)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Container(
                    key: ValueKey(tempPeriod),
                    height: 260,
                    alignment: Alignment.topCenter,
                    child: Builder(
                      builder: (context) {
                        if (tempPeriod == StatsPeriod.harian) {
                          return SizedBox(
                            height: 260,
                            child: CalendarDatePicker(
                              initialDate: selectedMonth,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              onDateChanged: (picked) {
                                setState(() {
                                  activePeriod = StatsPeriod.harian;
                                  selectedMonth = picked;
                                });
                                Navigator.pop(ctx);
                              },
                            ),
                          );
                        } else if (tempPeriod == StatsPeriod.mingguan) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Pilih Minggu dalam Bulan Ini:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                              const SizedBox(height: 12),
                              Column(
                                children: List.generate(4, (index) {
                                  final weekNum = index + 1;
                                  final startDay = (index * 7) + 1;
                                  final endDay = (index + 1) * 7;
                                  final isSelected = activePeriod == StatsPeriod.mingguan && ((selectedMonth.day - 1) ~/ 7) == index;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          activePeriod = StatsPeriod.mingguan;
                                          selectedMonth = DateTime(selectedMonth.year, selectedMonth.month, startDay);
                                        });
                                        Navigator.pop(ctx);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Minggu ke-$weekNum ($startDay - $endDay ${shortMonthNames[selectedMonth.month - 1]})",
                                                style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textPrimary)),
                                            if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          );
                        } else if (tempPeriod == StatsPeriod.bulanan) {
                          return SizedBox(
                            height: 220,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: 12,
                              itemBuilder: (context, index) {
                                final isSelected = activePeriod == StatsPeriod.bulanan && selectedMonth.month == index + 1;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      activePeriod = StatsPeriod.bulanan;
                                      selectedMonth = DateTime(selectedMonth.year, index + 1, 1);
                                    });
                                    Navigator.pop(ctx);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        shortMonthNames[index],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          // Tahunan
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Pilih Tahun:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                              const SizedBox(height: 12),
                              Row(
                                children: [2024, 2025, 2026, 2027].map((yr) {
                                  final isSelected = activePeriod == StatsPeriod.tahunan && selectedMonth.year == yr;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            activePeriod = StatsPeriod.tahunan;
                                            selectedMonth = DateTime(yr, selectedMonth.month, 1);
                                          });
                                          Navigator.pop(ctx);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "$yr",
                                              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textPrimary),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getPeriodDisplayTitle() {
    if (activePeriod == StatsPeriod.harian) {
      return "${selectedMonth.day} ${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}";
    } else if (activePeriod == StatsPeriod.mingguan) {
      final weekNum = ((selectedMonth.day - 1) ~/ 7) + 1;
      return "Minggu ke-$weekNum, ${shortMonthNames[selectedMonth.month - 1]} ${selectedMonth.year}";
    } else if (activePeriod == StatsPeriod.tahunan) {
      return "Tahun ${selectedMonth.year}";
    } else {
      return "${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}";
    }
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
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final allTransactions = appState.transactions.where((t) => !t.isRealTransfer).toList();
        final unreadNotifCount = appState.unreadNotificationCount;

        final now = DateTime.now();

        // Filtered transactions by period
        List<TransactionModel> periodTx = [];
        if (activePeriod == StatsPeriod.harian) {
          periodTx = allTransactions.where((t) =>
              t.date.year == selectedMonth.year &&
              t.date.month == selectedMonth.month &&
              t.date.day == selectedMonth.day
          ).toList();
        } else if (activePeriod == StatsPeriod.mingguan) {
          final weekIndex = ((selectedMonth.day - 1) ~/ 7);
          final startDay = (weekIndex * 7) + 1;
          final endDay = (weekIndex + 1) * 7;
          periodTx = allTransactions.where((t) =>
              t.date.year == selectedMonth.year &&
              t.date.month == selectedMonth.month &&
              t.date.day >= startDay &&
              t.date.day <= endDay
          ).toList();
        } else if (activePeriod == StatsPeriod.tahunan) {
          periodTx = allTransactions.where((t) => t.date.year == selectedMonth.year).toList();
        } else {
          // Bulanan
          periodTx = allTransactions.where((t) => t.date.year == selectedMonth.year && t.date.month == selectedMonth.month).toList();
        }

        // Totals (excluding internal wallet transfers!)
        final totalIncome = periodTx.where((t) => t.isIncome == true).fold(0.0, (sum, t) => sum + t.amount);
        final totalExpense = periodTx.where((t) => t.isIncome != true).fold(0.0, (sum, t) => sum + t.amount);
        final netSavings = totalIncome - totalExpense;
        final double savingsRate;
        if (totalIncome > 0) {
          savingsRate = ((netSavings / totalIncome) * 100).clamp(-100.0, 100.0);
        } else if (totalExpense > 0) {
          savingsRate = -100.0;
        } else {
          savingsRate = 0.0;
        }

        // Specific mode transactions (Expense or Income)
        final modeTx = periodTx.where((t) => (t.isIncome == !isExpenseMode)).toList();
        final currentTotal = isExpenseMode ? totalExpense : totalIncome;

        // Category breakdown calculation
        final Map<String, double> categoryTotals = {};
        final Map<String, Color> categoryColors = {};
        final Map<String, IconData> categoryIcons = {};

        for (var tx in modeTx) {
          categoryTotals[tx.categoryName] = (categoryTotals[tx.categoryName] ?? 0.0) + tx.amount;
          categoryColors[tx.categoryName] = tx.iconColor;
          categoryIcons[tx.categoryName] = tx.icon;
        }

        final sortedCategories = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        // Daily Averages & Peak Day Calculation
        int daysCount = activePeriod == StatsPeriod.harian ? 1 : (activePeriod == StatsPeriod.mingguan ? 7 : (activePeriod == StatsPeriod.tahunan ? 365 : DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day));
        final dailyAverage = currentTotal / (daysCount > 0 ? daysCount : 1);

        // Find peak expense/income day
        Map<String, double> dayTotals = {};
        for (var tx in modeTx) {
          final key = "${tx.date.day}/${tx.date.month}";
          dayTotals[key] = (dayTotals[key] ?? 0.0) + tx.amount;
        }
        String peakDayText = "-";
        double peakDayAmount = 0.0;
        if (dayTotals.isNotEmpty) {
          final topDay = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
          peakDayText = topDay.key;
          peakDayAmount = topDay.value;
        }

        // Projected End of Month Expense
        double projectedMonthTotal = currentTotal;
        if (activePeriod == StatsPeriod.bulanan && now.year == selectedMonth.year && now.month == selectedMonth.month && now.day > 0) {
          projectedMonthTotal = (totalExpense / now.day) * daysCount;
        }

        // AI Basic Insights: Proyeksi Kecepatan Habis Saldo (Burn-Rate Alarm)
        final double dailyBurnRate = activePeriod == StatsPeriod.bulanan && now.year == selectedMonth.year && now.month == selectedMonth.month && now.day > 0
            ? (totalExpense / now.day)
            : (totalExpense / (daysCount > 0 ? daysCount : 1));
        final int estimatedDaysLeft = dailyBurnRate > 0 ? (appState.totalBalance / dailyBurnRate).floor() : 999;
        String burnRateStatus;
        Color burnRateColor;
        IconData burnRateIcon;
        if (dailyBurnRate == 0) {
          burnRateStatus = "Aman • Belum Ada Pengeluaran Berarti";
          burnRateColor = AppTheme.incomeGreen;
          burnRateIcon = Icons.verified_outlined;
        } else if (estimatedDaysLeft < 15 && appState.totalBalance > 0) {
          burnRateStatus = "Siaga • Saldo Habis dalam ~$estimatedDaysLeft Hari";
          burnRateColor = AppTheme.expenseRed;
          burnRateIcon = Icons.warning_amber_rounded;
        } else if (appState.totalBalance <= 0) {
          burnRateStatus = "Kritis • Saldo Defisit / Habis";
          burnRateColor = AppTheme.expenseRed;
          burnRateIcon = Icons.error_outline;
        } else {
          burnRateStatus = "Optimal • Bertahan ~$estimatedDaysLeft Hari (${CurrencyFormatter.format(dailyBurnRate)}/hr)";
          burnRateColor = AppTheme.primary;
          burnRateIcon = Icons.insights_outlined;
        }

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

                // Unified Date Navigator Bar (< 📅 Juli 2026 >)
                InkWell(
                  onTap: _showPeriodPickerSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: _previousPeriod,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.chevron_left, color: AppTheme.primary, size: 22),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 18, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              _getPeriodDisplayTitle(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _nextPeriod,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.chevron_right, color: AppTheme.primary, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Net Cash Flow & Savings Rate Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryColumn("Pemasukan", CurrencyFormatter.format(totalIncome), AppTheme.incomeGreen, Icons.arrow_downward_rounded),
                          Container(width: 1, height: 36, color: AppTheme.outlineVariant.withOpacity(0.5)),
                          _buildSummaryColumn("Pengeluaran", CurrencyFormatter.format(totalExpense), AppTheme.expenseRed, Icons.arrow_upward_rounded),
                          Container(width: 1, height: 36, color: AppTheme.outlineVariant.withOpacity(0.5)),
                          _buildSummaryColumn(
                            netSavings >= 0 ? "Tabungan Bersih" : (totalIncome == 0 ? "Pakai Tabungan" : "Defisit Periode"),
                            netSavings < 0 ? "-${CurrencyFormatter.format(netSavings.abs())}" : CurrencyFormatter.format(netSavings),
                            netSavings >= 0 ? AppTheme.incomeGreen : (totalIncome == 0 ? AppTheme.warningAmber : AppTheme.expenseRed),
                            netSavings >= 0 ? Icons.savings_outlined : (totalIncome == 0 ? Icons.account_balance_wallet_outlined : Icons.warning_amber_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: AppTheme.outlineVariant.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                totalIncome > 0
                                    ? (savingsRate >= 20 ? Icons.stars : (savingsRate >= 0 ? Icons.info_outline : Icons.error_outline))
                                    : (totalExpense > 0 ? Icons.account_balance_wallet_outlined : Icons.info_outline),
                                size: 16,
                                color: totalIncome > 0
                                    ? (savingsRate >= 20 ? AppTheme.incomeGreen : (savingsRate >= 0 ? AppTheme.warningAmber : AppTheme.expenseRed))
                                    : (totalExpense > 0 ? AppTheme.warningAmber : AppTheme.textSecondary),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                totalIncome > 0
                                    ? "Rasio Tabungan (Savings Rate): ${savingsRate.toStringAsFixed(1)}%"
                                    : (totalExpense > 0 ? "Rasio Tabungan: Tanpa Pemasukan" : "Rasio Tabungan: 0.0%"),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (totalIncome > 0
                                      ? (savingsRate >= 20 ? AppTheme.incomeGreen : (savingsRate >= 0 ? AppTheme.warningAmber : AppTheme.expenseRed))
                                      : (totalExpense > 0 ? AppTheme.warningAmber : AppTheme.textSecondary))
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              totalIncome > 0
                                  ? (savingsRate >= 30 ? "Sangat Sehat" : (savingsRate >= 10 ? "Sehat" : (savingsRate >= 0 ? "Waspada" : "Defisit")))
                                  : (totalExpense > 0 ? "Pakai Tabungan" : "Nir Transaksi"),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: totalIncome > 0
                                    ? (savingsRate >= 20 ? AppTheme.incomeGreen : (savingsRate >= 0 ? AppTheme.warningAmber : AppTheme.expenseRed))
                                    : (totalExpense > 0 ? AppTheme.warningAmber : AppTheme.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, duration: 300.ms),

                const SizedBox(height: 18),

                // AI Financial Insights: Burn-Rate Alarm Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [burnRateColor.withOpacity(0.12), AppTheme.surfaceContainerLow],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: burnRateColor.withOpacity(0.4), width: 1.2),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: burnRateColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(burnRateIcon, color: burnRateColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "AI ANALYTICS • BURN RATE",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: burnRateColor, letterSpacing: 1.1),
                                ),
                                Text(
                                  "Proyeksi",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              burnRateStatus,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, duration: 350.ms),

                const SizedBox(height: 20),

                // Toggle Tab (Pengeluaran vs Pemasukan) + Chart Type Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildModeTab('Pengeluaran', isExpenseMode),
                          _buildModeTab('Pemasukan', !isExpenseMode),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() => activeChartType = ChartType.bar),
                          icon: Icon(
                            Icons.bar_chart_rounded,
                            color: activeChartType == ChartType.bar ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                          tooltip: "Grafik Batang",
                        ),
                        IconButton(
                          onPressed: () => setState(() => activeChartType = ChartType.line),
                          icon: Icon(
                            Icons.show_chart_rounded,
                            color: activeChartType == ChartType.line ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                          tooltip: "Grafik Tren Garis",
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Analytics Key Metrics Cards (Rata-rata Harian & Peak Day)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activePeriod == StatsPeriod.harian ? "Total Hari Ini" : "Rata-rata / Hari", style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(dailyAverage),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isExpenseMode ? "Pengeluaran Tertinggi" : "Pemasukan Tertinggi", style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              peakDayText != "-" ? "$peakDayText (${_formatShortCurrency(peakDayAmount)})" : "-",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Chart View (BarChart or LineChart) with RepaintBoundary
                RepaintBoundary(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeChartType == ChartType.bar ? "Grafik Perbandingan" : "Grafik Tren Waktu",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Text(
                              CurrencyFormatter.format(currentTotal),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isExpenseMode ? AppTheme.expenseRed : AppTheme.incomeGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: activeChartType == ChartType.bar
                              ? _buildBarChart(modeTx, isExpenseMode)
                              : _buildLineChart(modeTx, isExpenseMode),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, duration: 400.ms),

                const SizedBox(height: 24),

                // Ranked Category Allocation Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isExpenseMode ? "Alokasi Pengeluaran" : "Sumber Pemasukan",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      "${sortedCategories.length} Kategori",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (sortedCategories.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.pie_chart_outline, size: 48, color: AppTheme.textLight),
                        SizedBox(height: 10),
                        Text(
                          "Belum Ada Data di Periode Ini",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Catat transaksi baru untuk melihat analisis detail.",
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: List.generate(sortedCategories.length, (index) {
                        final entry = sortedCategories[index];
                        final catName = entry.key;
                        final amount = entry.value;
                        final percentage = currentTotal > 0 ? (amount / currentTotal) * 100 : 0.0;
                        final color = categoryColors[catName] ?? AppTheme.primary;
                        final icon = categoryIcons[catName] ?? Icons.category;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(icon, color: color, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            catName,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${percentage.toStringAsFixed(1)}% dari total",
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    CurrencyFormatter.format(amount),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isExpenseMode ? AppTheme.expenseRed : AppTheme.incomeGreen),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (percentage / 100).clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: AppTheme.surfaceContainerLow,
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                const SizedBox(height: 24),

                // Smart Financial Insights & Recommendations Card
                if (sortedCategories.isNotEmpty && isExpenseMode) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lightbulb_outline, color: AppTheme.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Analisis Finansial Cerdas",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4, fontFamily: 'Inter'),
                                  children: [
                                    const TextSpan(text: "Pengeluaran terbesar Anda pada "),
                                    TextSpan(
                                      text: _getPeriodDisplayTitle(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                    const TextSpan(text: " ada pada kategori "),
                                    TextSpan(
                                      text: "[${sortedCategories.first.key}]",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                    TextSpan(
                                      text: " sebesar ${CurrencyFormatter.format(sortedCategories.first.value)} (${((sortedCategories.first.value / (currentTotal > 0 ? currentTotal : 1)) * 100).toStringAsFixed(0)}% dari total).",
                                    ),
                                  ],
                                ),
                              ),
                              if (projectedMonthTotal > currentTotal && activePeriod == StatsPeriod.bulanan) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.expenseRed.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.expenseRed.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.trending_up, color: AppTheme.expenseRed, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Estimasi pengeluaran Anda hingga akhir bulan ini diproyeksikan mencapai ${CurrencyFormatter.format(projectedMonthTotal)}.",
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.expenseRed),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, duration: 500.ms),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryColumn(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildModeTab(String label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => isExpenseMode = label == 'Pengeluaran'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<TransactionModel> transactions, bool isExpense) {
    List<String> labels = [];
    int itemCount = 0;
    Map<int, double> periodData = {};

    if (activePeriod == StatsPeriod.harian || activePeriod == StatsPeriod.mingguan) {
      labels = dayNames;
      itemCount = 7;
      for (int i = 1; i <= itemCount; i++) periodData[i] = 0.0;
      for (var tx in transactions) {
        final dayIndex = tx.date.weekday;
        periodData[dayIndex] = (periodData[dayIndex] ?? 0.0) + tx.amount;
      }
    } else if (activePeriod == StatsPeriod.bulanan) {
      labels = ["Mg 1", "Mg 2", "Mg 3", "Mg 4"];
      itemCount = 4;
      for (int i = 1; i <= itemCount; i++) periodData[i] = 0.0;
      for (var tx in transactions) {
        int weekIdx = ((tx.date.day - 1) ~/ 7) + 1;
        if (weekIdx > 4) weekIdx = 4;
        periodData[weekIdx] = (periodData[weekIdx] ?? 0.0) + tx.amount;
      }
    } else {
      // Tahunan
      labels = shortMonthNames;
      itemCount = 12;
      for (int i = 1; i <= itemCount; i++) periodData[i] = 0.0;
      for (var tx in transactions) {
        final monthIdx = tx.date.month;
        periodData[monthIdx] = (periodData[monthIdx] ?? 0.0) + tx.amount;
      }
    }

    final double maxVal = periodData.values.fold(0.0, (max, v) => v > max ? v : max);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal == 0 ? 100.0 : maxVal * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                CurrencyFormatter.format(rod.toY),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1.0,
              getTitlesWidget: (value, meta) {
                final index = value.toInt() - 1;
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: activePeriod == StatsPeriod.tahunan ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(itemCount, (index) {
          final idx = index + 1;
          final val = periodData[idx] ?? 0.0;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: val,
                color: isExpense ? AppTheme.expenseRed : AppTheme.incomeGreen,
                width: activePeriod == StatsPeriod.tahunan ? 10 : 14,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(List<TransactionModel> transactions, bool isExpense) {
    List<String> labels = [];
    int itemCount = 0;
    Map<int, double> periodData = {};

    if (activePeriod == StatsPeriod.harian || activePeriod == StatsPeriod.mingguan) {
      labels = dayNames;
      itemCount = 7;
      for (int i = 1; i <= itemCount; i++) periodData[i] = 0.0;
      for (var tx in transactions) {
        final dayIndex = tx.date.weekday;
        periodData[dayIndex] = (periodData[dayIndex] ?? 0.0) + tx.amount;
      }
    } else if (activePeriod == StatsPeriod.bulanan) {
      labels = ["Mg 1", "Mg 2", "Mg 3", "Mg 4"];
      itemCount = 4;
      for (int i = 1; i <= itemCount; i++) periodData[i] = 0.0;
      for (var tx in transactions) {
        int weekIdx = ((tx.date.day - 1) ~/ 7) + 1;
        if (weekIdx > 4) weekIdx = 4;
        periodData[weekIdx] = (periodData[weekIdx] ?? 0.0) + tx.amount;
      }
    } else {
      // Tahunan
      labels = shortMonthNames;
      itemCount = 12;
      for (int i = 1; i <= itemCount; i++) periodData[i] = 0.0;
      for (var tx in transactions) {
        final monthIdx = tx.date.month;
        periodData[monthIdx] = (periodData[monthIdx] ?? 0.0) + tx.amount;
      }
    }

    final double maxVal = periodData.values.fold(0.0, (max, v) => v > max ? v : max);

    final spots = List.generate(itemCount, (i) {
      final idx = i + 1;
      return FlSpot(i.toDouble(), periodData[idx] ?? 0.0);
    });

    final activeColor = isExpense ? AppTheme.expenseRed : AppTheme.incomeGreen;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1.0,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        fontSize: activePeriod == StatsPeriod.tahunan ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        minX: 0,
        maxX: (itemCount - 1).toDouble(),
        minY: 0,
        maxY: maxVal == 0 ? 100.0 : maxVal * 1.25,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: activeColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: activeColor.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}
