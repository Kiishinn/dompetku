import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../utils/currency_formatter.dart';
import '../../screens/dompet_screen.dart';

class SesuaikanSaldoSheet extends StatefulWidget {
  final WalletItem wallet;

  const SesuaikanSaldoSheet({super.key, required this.wallet});

  static void show(BuildContext context, WalletItem wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SesuaikanSaldoSheet(wallet: wallet),
    );
  }

  @override
  State<SesuaikanSaldoSheet> createState() => _SesuaikanSaldoSheetState();
}

class _SesuaikanSaldoSheetState extends State<SesuaikanSaldoSheet> {
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (delCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: AppTheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.expenseRed.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever_rounded, color: AppTheme.expenseRed, size: 40),
              ),
              SizedBox(height: 18),
              Text(
                "Hapus Dompet '${widget.wallet.name}'?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Dompet ini akan dihapus dari daftar akun & dompet Anda. Anda dapat menambahkannya kembali di masa mendatang.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(delCtx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.8), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(delCtx);
                        Navigator.pop(context); // Tutup sheet utama juga
                        AppState.instance.deleteWallet(widget.wallet.name);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Dompet '${widget.wallet.name}' telah berhasil dihapus."),
                            backgroundColor: AppTheme.expenseRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.expenseRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        "Ya, Hapus",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAdjustment() {
    final cleanInput = _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Silakan masukkan saldo nyata terbaru terlebih dahulu."),
          backgroundColor: AppTheme.warningAmber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final targetBal = double.tryParse(cleanInput) ?? widget.wallet.balance;
    if (targetBal == widget.wallet.balance) {
      Navigator.pop(context);
      return;
    }

    AppState.instance.adjustWalletBalance(widget.wallet.name, targetBal);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Saldo [${widget.wallet.name}] disesuaikan menjadi ${CurrencyFormatter.format(targetBal)}!"),
        backgroundColor: AppTheme.incomeGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final brandColor = widget.wallet.brandColor;

    // Kalkulasi real-time selisih saldo
    final cleanText = _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final parsedInput = double.tryParse(cleanText);
    final double newBalance = parsedInput ?? widget.wallet.balance;
    final double diff = newBalance - widget.wallet.balance;
    final bool isUserInputted = cleanText.isNotEmpty && parsedInput != null;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: brandColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.wallet.iconData, color: brandColor, size: 26),
                    ),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sesuaikan Saldo",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Akun: ${widget.wallet.name} • ${widget.wallet.type}",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _showDeleteConfirmation,
                      tooltip: "Hapus Dompet Ini",
                      icon: Icon(Icons.delete_outline_rounded, color: AppTheme.expenseRed, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.expenseRed.withOpacity(0.1),
                        shape: CircleBorder(),
                      ),
                    ),
                    SizedBox(width: 6),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerLow,
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24),

            // Kartu Saldo Saat Ini (Current Balance Display)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    brandColor.withOpacity(0.08),
                    AppTheme.surfaceContainerLow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: brandColor.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.isDarkMode ? AppTheme.surfaceVariant : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: brandColor.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.account_balance_wallet, color: brandColor, size: 22),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SALDO TERCATAT SAAT INI",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(widget.wallet.balance, showPrefix: true),
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: brandColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 26),

            // Input Saldo Nyata Sekarang
            Text(
              "MASUKKAN SALDO NYATA SEKARANG",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: CurrencyFormatter.formatRawDigits(widget.wallet.balance.toInt().toString()),
                hintStyle: TextStyle(fontSize: 20, color: AppTheme.textLight.withOpacity(0.6), fontWeight: FontWeight.w500),
                filled: true,
                fillColor: AppTheme.surfaceContainerLow,
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  width: 66,
                  child: Text(
                    'Rp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: brandColor,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: brandColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              ),
            ),

            SizedBox(height: 16),

            // Real-time Difference Banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (!isUserInputted || diff == 0)
                    ? AppTheme.surfaceContainerLow
                    : (diff > 0 ? AppTheme.incomeGreen.withOpacity(0.1) : AppTheme.expenseRed.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (!isUserInputted || diff == 0)
                      ? AppTheme.outlineVariant.withOpacity(0.7)
                      : (diff > 0 ? AppTheme.incomeGreen.withOpacity(0.6) : AppTheme.expenseRed.withOpacity(0.6)),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (!isUserInputted || diff == 0)
                          ? (AppTheme.isDarkMode ? AppTheme.surfaceVariant : Colors.white)
                          : (diff > 0 ? AppTheme.incomeGreen.withOpacity(0.15) : AppTheme.expenseRed.withOpacity(0.15)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      (!isUserInputted || diff == 0)
                          ? Icons.info_outline
                          : (diff > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded),
                      size: 20,
                      color: (!isUserInputted || diff == 0)
                          ? AppTheme.textSecondary
                          : (diff > 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (!isUserInputted || diff == 0)
                              ? 'Tidak Ada Selisih Saldo'
                              : (diff > 0
                                  ? 'Selisih Lebih: +${CurrencyFormatter.format(diff)}'
                                  : 'Selisih Kurang: -${CurrencyFormatter.format(diff.abs())}'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: (!isUserInputted || diff == 0)
                                ? AppTheme.textPrimary
                                : (diff > 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          (!isUserInputted || diff == 0)
                              ? 'Saldo nyata saat ini senilai dengan catatan sistem. Belum ada koreksi transaksi.'
                              : (diff > 0
                                  ? 'Selisih ini akan otomatis dicatat sebagai Pemasukan (Penyesuaian Saldo) agar riwayat tetap jujur & akurat.'
                                  : 'Selisih ini akan otomatis dicatat sebagai Pengeluaran (Penyesuaian Saldo) agar riwayat tetap jujur & akurat.'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withOpacity(0.9),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saveAdjustment,
                icon: Icon(Icons.task_alt_rounded, color: AppTheme.textOnPrimary, size: 22),
                label: Text(
                  "Simpan Penyesuaian Saldo",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textOnPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  elevation: 4,
                  shadowColor: brandColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
