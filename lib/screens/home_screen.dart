import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_item_widget.dart';
import '../widgets/animations/animated_empty_state.dart';
import '../widgets/sheets/atur_anggaran_sheet.dart';
import '../widgets/sheets/filter_transaksi_sheet.dart';
import '../widgets/sheets/notifikasi_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

enum TimeRange { harian, mingguan, bulanan, tahunan, semua, custom }

class HomeScreen extends StatefulWidget {
  final List<TransactionModel>? transactions;

  const HomeScreen({super.key, this.transactions});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TimeRange selectedPeriod = TimeRange.bulanan;
  DateTimeRange? customDateRange;

  List<TransactionModel> _getFilteredTransactions() {
    final allTx = widget.transactions ?? AppState.instance.transactions;
    final now = DateTime.now();

    switch (selectedPeriod) {
      case TimeRange.harian:
        return allTx.where((tx) {
          return tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day;
        }).toList();

      case TimeRange.mingguan:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        return allTx.where((tx) => tx.date.isAfter(sevenDaysAgo)).toList();

      case TimeRange.bulanan:
        return allTx.where((tx) {
          return tx.date.year == now.year && tx.date.month == now.month;
        }).toList();

      case TimeRange.tahunan:
        return allTx.where((tx) => tx.date.year == now.year).toList();

      case TimeRange.semua:
        return allTx;

      case TimeRange.custom:
        if (customDateRange == null) return allTx;
        final start = customDateRange!.start;
        final end = customDateRange!.end.add(const Duration(days: 1));
        return allTx.where((tx) {
          return tx.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              tx.date.isBefore(end);
        }).toList();
    }
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        customDateRange = picked;
        selectedPeriod = TimeRange.custom;
      });
    }
  }

  String _formatDateRangeLabel(DateTimeRange range) {
    final startStr = "${range.start.day}/${range.start.month}";
    final endStr = "${range.end.day}/${range.end.month}/${range.end.year}";
    return "$startStr - $endStr";
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final allTransactions = widget.transactions ?? appState.transactions;
        final totalBalance = appState.totalBalance;
        final isDeficit = totalBalance < 0;
        final categoryBudgets = appState.categoryBudgets;
        final unreadNotifCount = appState.unreadNotificationCount;

        final filteredTxList = _getFilteredTransactions();
        final periodIncome = filteredTxList.where((t) => (t.isIncome == true) && !t.isRealTransfer).fold(0.0, (s, t) => s + t.amount);
        final periodExpense = filteredTxList.where((t) => (t.isIncome != true) && !t.isRealTransfer).fold(0.0, (s, t) => s + t.amount);

        return SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
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
                              Icons.account_balance_wallet,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Beranda',
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
                ),
              ),

              // Main Body Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      // Total Saldo Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A365D), Color(0xFF0F2942)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.primaryCardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL SALDO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textOnPrimary.withOpacity(0.8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Text(
                                  isDeficit
                                      ? CurrencyFormatter.format(0, showPrefix: true)
                                      : CurrencyFormatter.format(totalBalance, showPrefix: true),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textOnPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (isDeficit)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.expenseRed.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Defisit -${CurrencyFormatter.format(totalBalance.abs(), showPrefix: true)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filter Periode Selector Pills (Hari Ini, 7 Hari, Bulan Ini, Tahun Ini, Semua, Pilih Tanggal...)
                      Row(
                        children: [
                          const Text(
                            "Periode:",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  ...TimeRange.values.map((period) {
                                    final isSel = selectedPeriod == period;
                                    String label;
                                    IconData? icon;

                                    switch (period) {
                                      case TimeRange.harian:
                                        label = "Hari Ini";
                                        break;
                                      case TimeRange.mingguan:
                                        label = "7 Hari";
                                        break;
                                      case TimeRange.bulanan:
                                        label = "Bulan Ini";
                                        break;
                                      case TimeRange.tahunan:
                                        label = "Tahun Ini";
                                        break;
                                      case TimeRange.semua:
                                        label = "Semua";
                                        break;
                                      case TimeRange.custom:
                                        label = customDateRange != null
                                            ? _formatDateRangeLabel(customDateRange!)
                                            : "Pilih Tanggal";
                                        icon = Icons.calendar_month;
                                        break;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: InkWell(
                                        onTap: () {
                                          if (period == TimeRange.custom) {
                                            _pickCustomDateRange();
                                          } else {
                                            setState(() => selectedPeriod = period);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isSel ? AppTheme.primary : AppTheme.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(16),
                                            border: isSel
                                                ? null
                                                : Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (icon != null) ...[
                                                Icon(icon, size: 14, color: isSel ? Colors.white : AppTheme.primary),
                                                const SizedBox(width: 4),
                                              ],
                                              Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                                  color: isSel ? Colors.white : AppTheme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Income & Expense Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.incomeGreen.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward,
                                          color: AppTheme.incomeGreen,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Pemasukan',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    CurrencyFormatter.format(periodIncome, showPrefix: true),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.expenseRed.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_upward,
                                          color: AppTheme.expenseRed,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Pengeluaran',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    CurrencyFormatter.format(periodExpense, showPrefix: true),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Dedicated Category Budget Progress Tracker Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.pie_chart_outline, color: AppTheme.primary, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Pantau Jatah Anggaran Bulan Ini',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => AturAnggaranSheet.show(context),
                                  child: const Text(
                                    'Kelola',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (categoryBudgets.isEmpty)
                              const Text(
                                "Belum ada limit anggaran kategori diset. Tekan Kelola untuk mengatur.",
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              )
                            else
                              Column(
                                children: categoryBudgets.entries.map((entry) {
                                  final catName = entry.key;
                                  final limit = entry.value;
                                  final spent = appState.getCategorySpentThisMonth(catName);
                                  final remaining = limit - spent;
                                  final double rawRatio = limit > 0 ? (spent / limit) : 0.0;
                                  final double progress = rawRatio.clamp(0.0, 1.0);
                                  final int percentInt = (rawRatio * 100).toInt();

                                  Color barColor = AppTheme.incomeGreen;
                                  if (percentInt >= 90 || remaining < 0) {
                                    barColor = AppTheme.expenseRed;
                                  } else if (percentInt >= 80) {
                                    barColor = AppTheme.warningAmber;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              catName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              remaining >= 0
                                                  ? "Sisa Rp ${CurrencyFormatter.formatRawDigits(remaining.toInt().toString())}"
                                                  : "Overbudget Rp ${CurrencyFormatter.formatRawDigits(remaining.abs().toInt().toString())}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: remaining >= 0 ? barColor : AppTheme.expenseRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 7,
                                            backgroundColor: AppTheme.surfaceContainerLow,
                                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Terpakai Rp ${CurrencyFormatter.formatRawDigits(spent.toInt().toString())} ($percentInt%)",
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                            ),
                                            Text(
                                              "Limit Rp ${CurrencyFormatter.formatRawDigits(limit.toInt().toString())}",
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Recent Transactions Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaksi Terakhir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (allTransactions.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                FilterTransaksiSheet.show(
                                  context,
                                  allTransactions: allTransactions,
                                  onTransactionClick: (tx) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Detail transaksi: ${tx.title} (${CurrencyFormatter.format(tx.amount)})"),
                                        backgroundColor: AppTheme.primary,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Transaction List or Empty State for selected period
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: filteredTxList.isEmpty
                      ? AnimatedEmptyState(
                          icon: Icons.history_toggle_off,
                          title: allTransactions.isEmpty
                              ? "Belum Ada Transaksi"
                              : "Tidak Ada Transaksi di Periode Ini",
                          message: allTransactions.isEmpty
                              ? "Tekan tombol (+) di bawah untuk mencatat pengeluaran atau pemasukan pertama Anda!"
                              : "Coba ganti filter periode di atas atau pilih rentang tanggal lain.",
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: AnimationLimiter(
                            child: Column(
                              children: List.generate(
                                filteredTxList.length > 5 ? 5 : filteredTxList.length,
                                (index) => AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 20.0,
                                    child: FadeInAnimation(
                                      child: TransactionItemWidget(
                                        transaction: filteredTxList[index],
                                        showDivider: index != (filteredTxList.length - 1) && index != 4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Spacing for bottom nav bar
              ),
            ],
          ),
        );
      },
    );
  }
}
