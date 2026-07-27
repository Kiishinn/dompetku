import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../utils/currency_formatter.dart';

class SkorKesehatanSheet extends StatelessWidget {
  final int? customScore;

  const SkorKesehatanSheet({super.key, this.customScore});

  static void show(BuildContext context, {int? score}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkorKesehatanSheet(customScore: score),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final categoryBudgets = appState.categoryBudgets;
        final totalIncome = appState.totalIncome;
        final totalExpense = appState.totalExpense;

        final finalScore = customScore ?? appState.financialHealthScore;
        final scoreTitle = appState.financialHealthTitle;
        final scoreColor = appState.financialHealthColor;

        String scoreMessage = "Arus kas & manajemen anggaranmu sangat baik!";
        if (finalScore == 0) {
          scoreMessage = "Belum ada transaksi bulan ini. Catat transaksi pengeluaran dan pemasukan pertama Anda untuk menganalisis skor otomatis!";
        } else if (finalScore >= 80) {
          scoreMessage = "Arus kas & manajemen anggaranmu sangat baik!";
        } else if (finalScore >= 60) {
          scoreMessage = "Keuangan stabil, tingkatkan sisa jatah tabunganmu.";
        } else {
          scoreMessage = "Pengeluaran cukup tinggi, perhatikan limit anggaran.";
        }

        // Generate Dynamic Insights
        final List<Widget> insightWidgets = [];

        // 1. Savings / Income Ratio Insight
        if (totalIncome > 0 && totalExpense < totalIncome) {
          final sisa = totalIncome - totalExpense;
          insightWidgets.add(_buildInsightCard(
            icon: Icons.check_circle,
            iconTint: AppTheme.incomeGreen,
            title: "Cashflow Positif (+${CurrencyFormatter.format(sisa)})",
            subtitle: "Pemasukan Anda bulan ini berhasil menutup seluruh pengeluaran bulanan.",
          ));
        } else if (totalExpense > totalIncome && totalIncome > 0) {
          insightWidgets.add(_buildInsightCard(
            icon: Icons.warning_amber_rounded,
            iconTint: AppTheme.expenseRed,
            title: "Pengeluaran Melebihi Pemasukan",
            subtitle: "Pengeluaran bulan ini lebih tinggi dari pemasukan. Evaluasi kategori pengeluaran Anda.",
          ));
        }

        // 2. Category Budget Alert Insight
        int overbudgetCount = 0;
        categoryBudgets.forEach((catName, limit) {
          final spent = appState.getCategorySpentThisMonth(catName);
          if (limit > 0 && spent > limit) {
            overbudgetCount++;
          }
        });

        if (overbudgetCount > 0) {
          insightWidgets.add(_buildInsightCard(
            icon: Icons.error_outline,
            iconTint: AppTheme.expenseRed,
            title: "$overbudgetCount Kategori Overbudget",
            subtitle: "Ada $overbudgetCount kategori yang telah melampaui limit anggaran bulan ini.",
          ));
        } else if (totalIncome == 0 && totalExpense == 0) {
          insightWidgets.add(_buildInsightCard(
            icon: Icons.lightbulb_outline,
            iconTint: AppTheme.primary,
            title: "Siap Menganalisis Keuangan Anda",
            subtitle: "Tambahkan transaksi pertama Anda melalui tombol (+) untuk mulai memantau kesehatan finansial.",
          ));
        } else {
          insightWidgets.add(_buildInsightCard(
            icon: Icons.trending_up,
            iconTint: AppTheme.primary,
            title: "Anggaran Terkendali Rapi",
            subtitle: "Seluruh limit anggaran kategori masih berada dalam batas aman yang ditentukan.",
          ));
        }

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
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
                  Text(
                    "Skor Kesehatan Finansial",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gauge Ring Card (Hero Navy Card)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.isDarkMode
                              ? const LinearGradient(
                                  colors: [Color(0xFF0C192E), Color(0xFF162B50)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF1A365D), Color(0xFF24477E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppTheme.isDarkMode ? const Color(0xFF3B82F6).withOpacity(0.45) : const Color(0xFF2563EB).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: AppTheme.primaryCardShadow,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: AppTheme.isDarkMode ? const Color(0xFF070E1A) : Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.getAdaptiveColor(scoreColor),
                                  width: 4.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.getAdaptiveColor(scoreColor).withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$finalScore",
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    scoreTitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getAdaptiveColor(scoreColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              scoreMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        "Insight Untukmu",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...insightWidgets,

                      const SizedBox(height: 24),
                      Text(
                        "Status Anggaran Bulan Ini",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (categoryBudgets.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.isDarkMode ? const Color(0xFF111A29) : AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.isDarkMode ? const Color(0xFF233652) : AppTheme.outlineVariant.withOpacity(0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            "Belum ada limit anggaran kategori yang diset.",
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        )
                      else
                        Column(
                          children: categoryBudgets.entries.map((entry) {
                            final catName = entry.key;
                            final limit = entry.value;
                            final spent = appState.getCategorySpentThisMonth(catName);
                            final double rawRatio = limit > 0 ? (spent / limit) : 0.0;
                            final double progress = rawRatio.clamp(0.0, 1.0);
                            final int percentInt = (rawRatio * 100).toInt();

                            bool isOver = spent > limit && limit > 0;
                            bool isWarn = percentInt >= 80;

                            return _buildBudgetBarProgress(
                              title: catName,
                              amountSpent: "${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(limit)}",
                              progress: progress,
                              percentInt: percentInt,
                              isWarning: isWarn,
                              isOverbudget: isOver,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.isDarkMode ? const Color(0xFF2563EB) : AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: AppTheme.isDarkMode ? 6 : 2,
                            shadowColor: AppTheme.isDarkMode ? const Color(0xFF2563EB).withOpacity(0.4) : null,
                          ),
                          child: const Text(
                            "Mengerti",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconTint,
    required String title,
    required String subtitle,
  }) {
    final adaptiveTint = AppTheme.getAdaptiveColor(iconTint);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? const Color(0xFF111A29) : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.isDarkMode ? const Color(0xFF233652) : AppTheme.outlineVariant.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          if (!AppTheme.isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: adaptiveTint.withOpacity(0.14),
              shape: BoxShape.circle,
              border: Border.all(color: adaptiveTint.withOpacity(0.35), width: 1.0),
            ),
            child: Icon(icon, color: adaptiveTint, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBarProgress({
    required String title,
    required String amountSpent,
    required double progress,
    required int percentInt,
    required bool isWarning,
    required bool isOverbudget,
  }) {
    Color progressColor = AppTheme.incomeGreen;
    if (isOverbudget) {
      progressColor = AppTheme.expenseRed;
    } else if (isWarning) {
      progressColor = AppTheme.warningAmber;
    }
    progressColor = AppTheme.getAdaptiveColor(progressColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? const Color(0xFF111A29) : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.isDarkMode ? const Color(0xFF233652) : AppTheme.outlineVariant.withOpacity(0.7),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                "$percentInt%",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.isDarkMode ? const Color(0xFF1E2D44) : AppTheme.outlineVariant.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amountSpent,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
