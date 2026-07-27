import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_item_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int selectedDay = 14;

  @override
  Widget build(BuildContext context) {
    // We show the transactions for selected day from AppState
    final displayTx = AppState.instance.transactions.where((t) => t.date.day == selectedDay).toList();

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
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.person,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Month Selector (Juli 2026)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.textPrimary),
                    onPressed: () {},
                  ),
                  Text(
                    'Juli 2026',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Day Names header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((day) {
                  return SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Calendar Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildWeekRow([null, null, null, 1, 2, 3, 4], [null, null, null, false, false, false, false]),
                  SizedBox(height: 8),
                  _buildWeekRow([5, 6, 7, 8, 9, 10, 11], [true, false, false, false, true, false, false]), // Dots on 5 and 9
                  SizedBox(height: 8),
                  _buildWeekRow([12, 13, 14, 15, 16, 17, 18], [false, false, false, false, false, false, false]),
                  SizedBox(height: 8),
                  _buildWeekRow([19, 20, 21, 22, 23, 24, 25], [false, false, false, false, false, false, false]),
                  SizedBox(height: 8),
                  _buildWeekRow([26, 27, 28, 29, 30, 31, null], [false, false, false, false, false, false, null]),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Transaction Breakdown for selected date
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$selectedDay Juli 2026',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${displayTx.length} Transaksi',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...displayTx.map((tx) => TransactionItemWidget(
                    transaction: tx,
                    isCalendarStyle: true,
                  )),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekRow(List<int?> days, List<bool?> dots) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = days[index];
        final hasDot = dots[index] == true;
        final isSelected = day == selectedDay;

        if (day == null) {
          return SizedBox(width: 38, height: 44);
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = day;
            });
          },
          child: Container(
            width: 38,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.textOnPrimary : AppTheme.textPrimary,
                  ),
                ),
                if (hasDot)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.incomeGreen,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  SizedBox(height: 5),
              ],
            ),
          ),
        );
      }),
    );
  }
}
