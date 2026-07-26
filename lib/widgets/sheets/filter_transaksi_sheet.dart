import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/transaction_item_widget.dart';

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
  FilterType activeTab = FilterType.semua;
  TimeRangeFilter activeTimeRange = TimeRangeFilter.bulanan;
  DateTimeRange? customDateRange;

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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final filteredTransactions = widget.allTransactions.where((tx) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = tx.title.toLowerCase().contains(q);
        final matchCat = tx.categoryName.toLowerCase().contains(q);
        if (!matchTitle && !matchCat) return false;
      }

      // Tab filter (Semua, Pemasukan, Pengeluaran)
      if (activeTab == FilterType.pemasukan && !tx.isIncome) return false;
      if (activeTab == FilterType.pengeluaran && tx.isIncome) return false;

      // Time range filter
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

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
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
                "Riwayat & Filter Transaksi",
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
          const SizedBox(height: 12),

          // Search Bar Input
          TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: "Cari judul, kategori, atau dompet...",
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

          // Filter Type Tabs: SEMUA, PEMASUKAN, PENGELUARAN
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: FilterType.values.map((type) {
                final isSelected = activeTab == type;
                String label;
                switch (type) {
                  case FilterType.semua:
                    label = "Semua";
                    break;
                  case FilterType.pemasukan:
                    label = "Pemasukan";
                    break;
                  case FilterType.pengeluaran:
                    label = "Pengeluaran";
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surfaceContainerLow,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide.none,
                    onSelected: (_) => setState(() => activeTab = type),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Date Range Filter Pills
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
                    labelText = "7 Hari";
                    break;
                  case TimeRangeFilter.bulanan:
                    labelText = "Bulan Ini";
                    break;
                  case TimeRangeFilter.tahunan:
                    labelText = "Tahun Ini";
                    break;
                  case TimeRangeFilter.semua:
                    labelText = "Semua";
                    break;
                  case TimeRangeFilter.custom:
                    labelText = customDateRange != null
                        ? "${customDateRange!.start.day}/${customDateRange!.start.month} - ${customDateRange!.end.day}/${customDateRange!.end.month}"
                        : "📅 Pilih Tanggal...";
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        labelText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Transaction Result Header
          Text(
            "Ditemukan ${filteredTransactions.length} Transaksi",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Filtered Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history_toggle_off, size: 48, color: AppTheme.textLight),
                        SizedBox(height: 8),
                        Text(
                          "Tidak ada transaksi ditemukan",
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
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
