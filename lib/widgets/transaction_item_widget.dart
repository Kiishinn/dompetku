import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionModel transaction;
  final bool showDivider;
  final bool isCalendarStyle;

  const TransactionItemWidget({
    super.key,
    required this.transaction,
    this.showDivider = true,
    this.isCalendarStyle = false,
  });

  void _showDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: transaction.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(transaction.icon, color: transaction.iconColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${transaction.categoryName} • ${transaction.displayWallet}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: AppTheme.outlineVariant.withOpacity(0.5)),
            const SizedBox(height: 14),
            _buildDetailRow("Nominal", CurrencyFormatter.format(transaction.amount, isIncome: transaction.isIncome, withSign: true), isValueBold: true, valueColor: transaction.amountColor),
            const SizedBox(height: 10),
            _buildDetailRow("Tipe Transaksi", transaction.isIncome ? "Pemasukan (+)" : "Pengeluaran (-)"),
            const SizedBox(height: 10),
            _buildDetailRow("Waktu & Tanggal", "${transaction.formattedDateLabel} (${transaction.date.day}/${transaction.date.month}/${transaction.date.year})"),
            const SizedBox(height: 10),
            _buildDetailRow("Dompet / Akun", transaction.displayWallet),
            if (transaction.note.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(color: AppTheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 10),
              const Text("Catatan Opsional:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  transaction.note,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (confirmCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text("Hapus Transaksi?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          content: Text("Transaksi '${transaction.title}' sebesar ${CurrencyFormatter.format(transaction.amount)} akan dihapus dan saldo dompet akan disesuaikan kembali."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmCtx),
                              child: const Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(confirmCtx);
                                Navigator.pop(ctx);
                                AppState.instance.deleteTransaction(transaction.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Transaksi '${transaction.title}' telah dihapus."),
                                    backgroundColor: AppTheme.expenseRed,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.expenseRed,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Ya, Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, color: AppTheme.expenseRed, size: 18),
                    label: const Text("Hapus", style: TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.expenseRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isValueBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletLabel = transaction.displayWallet;
    final dateLabel = transaction.formattedDateLabel;
    final hasNote = transaction.note.trim().isNotEmpty;

    if (isCalendarStyle) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: transaction.isIncome 
                    ? AppTheme.incomeGreen.withOpacity(0.1) 
                    : AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.icon,
                color: transaction.isIncome ? AppTheme.incomeGreen : AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateLabel • ${transaction.categoryName} • $walletLabel',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (hasNote) ...[
                    const SizedBox(height: 2),
                    Text(
                      '📝 ${transaction.note}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(
                transaction.amount,
                isIncome: transaction.isIncome,
                withSign: true,
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: transaction.isIncome ? AppTheme.incomeGreen : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        InkWell(
          onTap: () => _showDetailBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: transaction.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateLabel • ${transaction.categoryName} • $walletLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (hasNote) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.notes, size: 12, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                transaction.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    transaction.amount,
                    isIncome: transaction.isIncome,
                    withSign: true,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: transaction.amountColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Container(
              height: 1,
              color: AppTheme.outlineVariant.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}
