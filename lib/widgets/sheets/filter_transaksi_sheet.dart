import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/transaction_item_widget.dart';
import '../../utils/currency_formatter.dart';

enum FilterType { semua, pemasukan, pengeluaran }
enum TimeRangeFilter { harian, mingguan, bulanan, tahunan, semua, custom }

class FilterTransaksiSheet extends StatefulWidget {
  final List<TransactionModel> allTransactions;
  final Function(TransactionModel) onTransactionClick;

  const FilterTransaksiSheet({
    super.key,
    required this.allTransactions,
    required this.onTransactionClick,
  });

  static void show(BuildContext context, {
    required List<TransactionModel> allTransactions,
    required Function(TransactionModel) onTransactionClick,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterTransaksiSheet(
        allTransactions: allTransactions,
        onTransactionClick: onTransactionClick,
      ),
    );
  }

  @override
  State<FilterTransaksiSheet> createState() => _FilterTransaksiSheetState();
}

class _FilterTransaksiSheetState extends State<FilterTransaksiSheet> {
  String searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();
  FilterType activeTab = FilterType.semua;
  TimeRangeFilter activeTimeRange = TimeRangeFilter.semua;
  DateTimeRange? customDateRange;

  // State untuk filter Kategori dan Dompet yang dipindahkan dari Beranda
  String? filterCategory;
  String? filterWallet;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  bool _isSameYear(DateTime a, DateTime b) {
    return a.year == b.year;
  }

  bool _isWithinWeek(DateTime date, DateTime now) {
    final difference = now.difference(date).inDays;
    return difference >= 0 && difference < 7;
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: customDateRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
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
        activeTimeRange = TimeRangeFilter.custom;
      });
    }
  }

  void _resetAllFilters() {
    _searchCtrl.clear();
    setState(() {
      searchQuery = "";
      activeTab = FilterType.semua;
      activeTimeRange = TimeRangeFilter.semua;
      customDateRange = null;
      filterCategory = null;
      filterWallet = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Kumpulkan daftar kategori dan dompet unik dari total transaksi
    final uniqueCategories = <String>{};
    final uniqueWallets = <String>{};
    for (final tx in widget.allTransactions) {
      uniqueCategories.add(tx.categoryName);
      if (tx.walletName != null && tx.walletName!.isNotEmpty) {
        uniqueWallets.add(tx.walletName!);
      }
    }
    final categories = uniqueCategories.toList()..sort();
    final wallets = uniqueWallets.toList()..sort();

    final filteredTransactions = widget.allTransactions.where((tx) {
      // Filter kata kunci pencarian
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchTitle = tx.title.toLowerCase().contains(q);
        final matchCat = tx.categoryName.toLowerCase().contains(q);
        final matchWallet = tx.walletName?.toLowerCase().contains(q) ?? false;
        if (!matchTitle && !matchCat && !matchWallet) return false;
      }

      // Filter tab jenis (Semua, Pemasukan, Pengeluaran)
      if (activeTab == FilterType.pemasukan && !tx.isIncome) return false;
      if (activeTab == FilterType.pengeluaran && tx.isIncome) return false;

      // Filter Kategori
      if (filterCategory != null && tx.categoryName != filterCategory) return false;

      // Filter Dompet
      if (filterWallet != null && tx.walletName != filterWallet) return false;

      // Filter rentang waktu
      if (activeTimeRange == TimeRangeFilter.harian && !_isSameDay(tx.date, now)) return false;
      if (activeTimeRange == TimeRangeFilter.mingguan && !_isWithinWeek(tx.date, now)) return false;
      if (activeTimeRange == TimeRangeFilter.bulanan && !_isSameMonth(tx.date, now)) return false;
      if (activeTimeRange == TimeRangeFilter.tahunan && !_isSameYear(tx.date, now)) return false;
      if (activeTimeRange == TimeRangeFilter.custom && customDateRange != null) {
        final start = DateTime(customDateRange!.start.year, customDateRange!.start.month, customDateRange!.start.day);
        final end = DateTime(customDateRange!.end.year, customDateRange!.end.month, customDateRange!.end.day, 23, 59, 59);
        if (tx.date.isBefore(start) || tx.date.isAfter(end)) return false;
      }

      return true;
    }).toList();

    final bool hasActiveFilter = searchQuery.isNotEmpty ||
        activeTab != FilterType.semua ||
        activeTimeRange != TimeRangeFilter.semua ||
        filterCategory != null ||
        filterWallet != null;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar Kapsul
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header Eksekutif & Tombol Reset / Tutup
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Pusat Riwayat & Filter",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (hasActiveFilter)
                    TextButton(
                      onPressed: _resetAllFilters,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.expenseRed,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Kolom Pencarian Cerdas yang Mewah
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.6)),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: "Cari transaksi, kategori, atau dompet...",
                hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 13.5, fontWeight: FontWeight.w400),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => searchQuery = "");
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Dropdown Kategori dan Dompet (Dipindahkan dari Beranda)
          Row(
            children: [
              // Dropdown Filter Kategori
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      filterCategory = (value == '__ALL__') ? null : value;
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppTheme.surface,
                  elevation: 8,
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: '__ALL__',
                      child: Row(
                        children: [
                          if (filterCategory == null)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.primary),
                            ),
                          Text(
                            'Semua Kategori',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: filterCategory == null ? FontWeight.w700 : FontWeight.w500,
                              color: filterCategory == null ? AppTheme.primary : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...categories.map((cat) => PopupMenuItem<String>(
                      value: cat,
                      child: Row(
                        children: [
                          if (filterCategory == cat)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.primary),
                            ),
                          Expanded(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: filterCategory == cat ? FontWeight.w700 : FontWeight.w500,
                                color: filterCategory == cat ? AppTheme.primary : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: filterCategory != null ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: filterCategory != null ? AppTheme.primary.withOpacity(0.5) : AppTheme.outlineVariant.withOpacity(0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.category_outlined, size: 18, color: filterCategory != null ? AppTheme.primary : AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filterCategory ?? 'Semua Kategori',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: filterCategory != null ? FontWeight.w700 : FontWeight.w600,
                              color: filterCategory != null ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: filterCategory != null ? AppTheme.primary : AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Dropdown Filter Dompet
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      filterWallet = (value == '__ALL__') ? null : value;
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppTheme.surface,
                  elevation: 8,
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: '__ALL__',
                      child: Row(
                        children: [
                          if (filterWallet == null)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.accentBlue),
                            ),
                          Text(
                            'Semua Dompet',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: filterWallet == null ? FontWeight.w700 : FontWeight.w500,
                              color: filterWallet == null ? AppTheme.accentBlue : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...wallets.map((w) => PopupMenuItem<String>(
                      value: w,
                      child: Row(
                        children: [
                          if (filterWallet == w)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.accentBlue),
                            ),
                          Expanded(
                            child: Text(
                              w,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: filterWallet == w ? FontWeight.w700 : FontWeight.w500,
                                color: filterWallet == w ? AppTheme.accentBlue : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: filterWallet != null ? AppTheme.accentBlue.withOpacity(0.1) : AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: filterWallet != null ? AppTheme.accentBlue.withOpacity(0.5) : AppTheme.outlineVariant.withOpacity(0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 18, color: filterWallet != null ? AppTheme.accentBlue : AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filterWallet ?? 'Semua Dompet',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: filterWallet != null ? FontWeight.w700 : FontWeight.w600,
                              color: filterWallet != null ? AppTheme.accentBlue : AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: filterWallet != null ? AppTheme.accentBlue : AppTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Jenis Transaksi: SEMUA, PEMASUKAN, PENGELUARAN
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: FilterType.values.map((type) {
                final isSelected = activeTab == type;
                String label;
                switch (type) {
                  case FilterType.semua:
                    label = "Semua Jenis";
                    break;
                  case FilterType.pemasukan:
                    label = "Pemasukan";
                    break;
                  case FilterType.pengeluaran:
                    label = "Pengeluaran";
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => setState(() => activeTab = type),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Kapsul Filter Periode Waktu
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: TimeRangeFilter.values.map((range) {
                final isSelected = activeTimeRange == range;
                String labelText;
                switch (range) {
                  case TimeRangeFilter.harian:
                    labelText = "Hari Ini";
                    break;
                  case TimeRangeFilter.mingguan:
                    labelText = "7 Hari Terakhir";
                    break;
                  case TimeRangeFilter.bulanan:
                    labelText = "Bulan Ini";
                    break;
                  case TimeRangeFilter.tahunan:
                    labelText = "Tahun Ini";
                    break;
                  case TimeRangeFilter.semua:
                    labelText = "Semua Waktu";
                    break;
                  case TimeRangeFilter.custom:
                    labelText = customDateRange != null
                        ? "${customDateRange!.start.day}/${customDateRange!.start.month} - ${customDateRange!.end.day}/${customDateRange!.end.month}"
                        : "Pilih Tanggal...";
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      if (range == TimeRangeFilter.custom) {
                        _pickCustomDateRange();
                      } else {
                        setState(() => activeTimeRange = range);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        labelText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Header Hasil Pencarian & Garis Pemisah
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ditemukan ${filteredTransactions.length} Transaksi",
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (hasActiveFilter)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Filter Aktif",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Daftar Transaksi Hasil Filter
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history_toggle_off_rounded, size: 52, color: AppTheme.textLight),
                        SizedBox(height: 12),
                        Text(
                          "Tidak ada transaksi yang cocok",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Coba sesuaikan kata kunci atau atur ulang filter",
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onTransactionClick(tx);
                          Navigator.pop(context);
                        },
                        child: TransactionItemWidget(
                          transaction: tx,
                          showDivider: index < filteredTransactions.length - 1,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
