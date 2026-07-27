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
import '../widgets/cards/wallet_carousel_card.dart';

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
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // Filter & Pagination state
  String? _filterCategory;
  String? _filterWallet;
  int _visibleGroupCount = 3; // number of date groups to show

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions() {
    final allTx = widget.transactions ?? AppState.instance.transactions;
    var list = allTx;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((tx) {
        return tx.title.toLowerCase().contains(q) ||
            tx.categoryName.toLowerCase().contains(q) ||
            (tx.note.isNotEmpty && tx.note.toLowerCase().contains(q)) ||
            (tx.walletName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Apply category & wallet filters
    if (_filterCategory != null) {
      list = list.where((tx) => tx.categoryName == _filterCategory).toList();
    }
    if (_filterWallet != null) {
      list = list.where((tx) => tx.walletName == _filterWallet).toList();
    }

    final now = DateTime.now();

    switch (selectedPeriod) {
      case TimeRange.harian:
        return list.where((tx) {
          return tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day;
        }).toList();

      case TimeRange.mingguan:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        return list.where((tx) => tx.date.isAfter(sevenDaysAgo)).toList();

      case TimeRange.bulanan:
        return list.where((tx) {
          return tx.date.year == now.year && tx.date.month == now.month;
        }).toList();

      case TimeRange.tahunan:
        return list.where((tx) => tx.date.year == now.year).toList();

      case TimeRange.semua:
        return list;

      case TimeRange.custom:
        if (customDateRange == null) return list;
        final start = customDateRange!.start;
        final end = customDateRange!.end.add(const Duration(days: 1));
        return list.where((tx) {
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
            colorScheme: ColorScheme.light(
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
        final periodIncome = filteredTxList.where((t) => (t.isIncome == true) && !t.isRealTransfer).fold<double>(0.0, (s, t) => s + t.amount);
        final periodExpense = filteredTxList.where((t) => (t.isIncome != true) && !t.isRealTransfer).fold<double>(0.0, (s, t) => s + t.amount);

        // Pre-filter list (before category/wallet filters) for deriving chip labels
        final preFilterTxList = (() {
          final saved = (_filterCategory, _filterWallet);
          _filterCategory = null;
          _filterWallet = null;
          final result = _getFilteredTransactions();
          _filterCategory = saved.$1;
          _filterWallet = saved.$2;
          return result;
        })();

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
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
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
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
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
                                decoration: BoxDecoration(
                                  color: AppTheme.expenseRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadNotifCount',
                                  style: TextStyle(
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
                      SizedBox(height: 4),

                      // Interactive Swipeable Wallet Carousel Card (Sultan Fintech Tier-1)
                      const WalletCarouselCard(),

                      SizedBox(height: 20),

                      // Filter Periode Selector Pills (Hari Ini, 7 Hari, Bulan Ini, Tahun Ini, Semua, Pilih Tanggal...)
                      Row(
                        children: [
                          Text(
                            "Periode:",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(width: 8),
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
                                                SizedBox(width: 4),
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

                      SizedBox(height: 14),

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
                                        child: Icon(
                                          Icons.arrow_downward,
                                          color: AppTheme.incomeGreen,
                                          size: 18,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Pemasukan',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    appState.isBalanceHidden ? 'Rp ••••••' : CurrencyFormatter.format(periodIncome, showPrefix: true),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
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
                                        child: Icon(
                                          Icons.arrow_upward,
                                          color: AppTheme.expenseRed,
                                          size: 18,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Pengeluaran',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    appState.isBalanceHidden ? 'Rp ••••••' : CurrencyFormatter.format(periodExpense, showPrefix: true),
                                    style: TextStyle(
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

                      SizedBox(height: 24),

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
                                  children: [
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
                                  child: Text(
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
                            SizedBox(height: 14),

                            if (categoryBudgets.isEmpty)
                              Text(
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
                                              style: TextStyle(
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
                                        SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 7,
                                            backgroundColor: AppTheme.surfaceContainerLow,
                                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Terpakai Rp ${CurrencyFormatter.formatRawDigits(spent.toInt().toString())} ($percentInt%)",
                                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                            ),
                                            Text(
                                              "Limit Rp ${CurrencyFormatter.formatRawDigits(limit.toInt().toString())}",
                                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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

                      SizedBox(height: 28),

                      // Recent Transactions Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
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
                              child: Text(
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
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Transaction List: Grouped by Date with Load More
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: filteredTxList.isEmpty
                      ? AnimatedEmptyState(
                          icon: Icons.history_toggle_off,
                          title: allTransactions.isEmpty
                              ? "Belum Ada Transaksi"
                              : "Tidak Ada Transaksi yang Cocok",
                          message: allTransactions.isEmpty
                              ? "Tekan tombol (+) di bawah untuk mencatat pengeluaran atau pemasukan pertama Anda!"
                              : "Coba ubah kata kunci pencarian atau ganti filter periode di atas.",
                        )
                      : RepaintBoundary(
                          child: Builder(builder: (context) {
                            // Group transactions by date
                            final now = DateTime.now();
                            final Map<String, List<TransactionModel>> groupedTx = {};
                            final Map<String, DateTime> groupDateMap = {};

                            for (final tx in filteredTxList) {
                              final dateKey = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';
                              groupedTx.putIfAbsent(dateKey, () => []);
                              groupedTx[dateKey]!.add(tx);
                              groupDateMap.putIfAbsent(dateKey, () => DateTime(tx.date.year, tx.date.month, tx.date.day));
                            }

                            // Sort date keys descending (newest first)
                            final sortedKeys = groupedTx.keys.toList()
                              ..sort((a, b) => b.compareTo(a));

                            final totalGroups = sortedKeys.length;
                            final visibleKeys = sortedKeys.take(_visibleGroupCount).toList();

                            String _dateGroupLabel(DateTime date) {
                              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                              final yesterday = now.subtract(const Duration(days: 1));
                              final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
                              final months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"];
                              final days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
                              final dayName = days[date.weekday - 1];

                              if (isToday) return "HARI INI, ${date.day} ${months[date.month - 1]}";
                              if (isYesterday) return "KEMARIN, ${date.day} ${months[date.month - 1]}";
                              return "$dayName, ${date.day} ${months[date.month - 1]} ${date.year}".toUpperCase();
                            }

                            return Column(
                              children: [
                                ...visibleKeys.map((dateKey) {
                                  final txGroup = groupedTx[dateKey]!;
                                  final groupDate = groupDateMap[dateKey]!;
                                  final label = _dateGroupLabel(groupDate);

                                  // Sum for the date group
                                  final dayIncome = txGroup.where((t) => t.isIncome == true && !t.isRealTransfer).fold<double>(0, (s, t) => s + t.amount);
                                  final dayExpense = txGroup.where((t) => t.isIncome != true && !t.isRealTransfer).fold<double>(0, (s, t) => s + t.amount);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Date Group Header
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.textSecondary.withOpacity(0.7),
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (dayIncome > 0)
                                                    Text(
                                                      '+${CurrencyFormatter.format(dayIncome)}',
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.incomeGreen),
                                                    ),
                                                  if (dayIncome > 0 && dayExpense > 0)
                                                    Text(' / ', style: TextStyle(fontSize: 10, color: AppTheme.textLight)),
                                                  if (dayExpense > 0)
                                                    Text(
                                                      '-${CurrencyFormatter.format(dayExpense)}',
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.expenseRed),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Transaction cards for this date
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.surface,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: AppTheme.cardShadow,
                                          ),
                                          child: Column(
                                            children: List.generate(txGroup.length, (i) {
                                              return TransactionItemWidget(
                                                transaction: txGroup[i],
                                                showDivider: i != txGroup.length - 1,
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                // Load More Button
                                if (_visibleGroupCount < totalGroups)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _visibleGroupCount += 3;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.expand_more_rounded, color: AppTheme.primary, size: 20),
                                            SizedBox(width: 6),
                                            Text(
                                              'Muat Lebih Banyak (${totalGroups - _visibleGroupCount} grup lagi)',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
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
