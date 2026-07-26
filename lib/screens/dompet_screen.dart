import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/sheets/notifikasi_sheet.dart';
import '../widgets/animations/animated_empty_state.dart';

class WalletItem {
  final String name;
  final String type; // Bank, E-Wallet, Cash
  final double balance;
  final String accountNumber;
  final String colorHex;
  final IconData iconData;

  const WalletItem({
    required this.name,
    required this.type,
    required this.balance,
    required this.accountNumber,
    required this.colorHex,
    required this.iconData,
  });

  Color get brandColor {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('0xFF$hex'));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'balance': balance,
      'accountNumber': accountNumber,
      'colorHex': colorHex,
      'iconCodePoint': iconData.codePoint,
    };
  }

  factory WalletItem.fromJson(Map<String, dynamic> json) {
    return WalletItem(
      name: json['name'] ?? '',
      type: json['type'] ?? 'Bank',
      balance: (json['balance'] as num).toDouble(),
      accountNumber: json['accountNumber'] ?? '',
      colorHex: json['colorHex'] ?? '#1A365D',
      iconData: IconData(json['iconCodePoint'] ?? Icons.account_balance.codePoint, fontFamily: 'MaterialIcons'),
    );
  }
}

class DompetScreen extends StatefulWidget {
  const DompetScreen({super.key});

  @override
  State<DompetScreen> createState() => _DompetScreenState();
}

class _DompetScreenState extends State<DompetScreen> {
  bool isBalanceVisible = true;

  void _showAdjustBalanceDialog(WalletItem wallet) {
    final balanceController = TextEditingController();
    double currentActualInput = wallet.balance;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final cleanText = balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
          final parsedInput = double.tryParse(cleanText);
          final double newBalance = parsedInput ?? wallet.balance;
          final double diff = newBalance - wallet.balance;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sesuaikan Saldo ${wallet.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.expenseRed),
                  tooltip: 'Hapus Dompet Ini',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (delCtx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text("Hapus Dompet ${wallet.name}?", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        content: const Text("Dompet ini akan dihapus dari daftar akun Anda."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(delCtx),
                            child: const Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(delCtx);
                              Navigator.pop(ctx);
                              AppState.instance.deleteWallet(wallet.name);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Dompet [${wallet.name}] telah dihapus."),
                                  backgroundColor: AppTheme.expenseRed,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.expenseRed,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Hapus Dompet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo tercatat di aplikasi saat ini:',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(wallet.balance, showPrefix: true),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
                  onChanged: (_) => setDialogState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Saldo Nyata Sekarang (Rp)',
                    hintText: CurrencyFormatter.formatRawDigits(wallet.balance.toInt().toString()),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: diff == 0
                        ? AppTheme.surfaceContainerLow
                        : (diff > 0 ? AppTheme.incomeGreen.withOpacity(0.1) : AppTheme.expenseRed.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: diff == 0
                          ? AppTheme.outlineVariant
                          : (diff > 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        diff == 0 ? Icons.info_outline : (diff > 0 ? Icons.arrow_upward : Icons.arrow_downward),
                        size: 18,
                        color: diff == 0
                            ? AppTheme.textSecondary
                            : (diff > 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diff == 0
                              ? 'Tidak ada selisih saldo.'
                              : (diff > 0
                                  ? 'Selisih Lebih: +${CurrencyFormatter.format(diff)}\n(Akan dicatat sebagai Pemasukan Otomatis)'
                                  : 'Selisih Kurang: -${CurrencyFormatter.format(diff.abs())}\n(Akan dicatat sebagai Pengeluaran Otomatis)'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: diff == 0
                                ? AppTheme.textSecondary
                                : (diff > 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final cleanInput = balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  if (cleanInput.isNotEmpty) {
                    final targetBal = double.parse(cleanInput);
                    AppState.instance.adjustWalletBalance(wallet.name, targetBal);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Saldo [${wallet.name}] disesuaikan menjadi ${CurrencyFormatter.format(targetBal)}!"),
                        backgroundColor: AppTheme.incomeGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Simpan Penyesuaian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final wallets = appState.wallets;
        final totalBalance = appState.totalBalance;
        final isDeficit = totalBalance < 0;

        return SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Header Bar
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
                            'Dompet & Akun',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                            onPressed: () => setState(() => isBalanceVisible = !isBalanceVisible),
                          ),
                          const SizedBox(width: 4),
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
                              if (appState.unreadNotificationCount > 0)
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
                                      '${appState.unreadNotificationCount}',
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
                    ],
                  ),
                ),
              ),

              // Summary Header Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A365D), Color(0xFF0F2942)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.primaryCardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL ASET DI SEMUA DOMPET',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            Text(
                              isBalanceVisible
                                  ? (isDeficit ? CurrencyFormatter.format(0, showPrefix: true) : CurrencyFormatter.format(totalBalance, showPrefix: true))
                                  : 'Rp •••••••••',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (isDeficit && isBalanceVisible)
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.incomeGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${wallets.length} Akun Terhubung',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Section Title + Tambah Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Akun & Dompet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: _showAddWalletDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add_circle, color: AppTheme.primary, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Tambah Dompet',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Wallets List or Empty State
              wallets.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: AnimatedEmptyState(
                          icon: Icons.account_balance_wallet_outlined,
                          title: "Belum Ada Dompet Terhubung",
                          message: "Seluruh data telah di-reset. Tambahkan rekening bank, e-wallet, atau dompet tunai pertama Anda untuk melacak keuangan.",
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final wallet = wallets[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                            child: _buildWalletCard(wallet),
                          );
                        },
                        childCount: wallets.length,
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletCard(WalletItem wallet) {
    return InkWell(
      onTap: () => _showAdjustBalanceDialog(wallet),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: wallet.brandColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      wallet.iconData,
                      color: wallet.brandColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${wallet.type} • ${wallet.accountNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isBalanceVisible
                          ? CurrencyFormatter.format(wallet.balance, showPrefix: true)
                          : 'Rp ••••••',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: wallet.balance < 0 ? AppTheme.expenseRed : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      wallet.balance < 0 ? 'Defisit' : 'Aktif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: wallet.balance < 0 ? AppTheme.expenseRed : AppTheme.incomeGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit_note, color: AppTheme.textSecondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'Bank';
    String colorHex = '#1A365D';
    IconData iconData = Icons.account_balance;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('Tambah Dompet Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Akun / Dompet',
                      hintText: 'Misal: Bank BCA, Gopay, OVO...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
                    decoration: InputDecoration(
                      labelText: 'Saldo Awal (Rp)',
                      hintText: '0',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tipe Akun:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Bank', 'E-Wallet', 'Dompet Fisik'].map((t) {
                      final sel = selectedType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: sel,
                        selectedColor: AppTheme.primaryContainer,
                        labelStyle: TextStyle(color: sel ? AppTheme.textOnPrimary : AppTheme.textPrimary, fontSize: 12),
                        onSelected: (_) => setDialogState(() {
                          selectedType = t;
                          if (t == 'E-Wallet') {
                            iconData = Icons.account_balance_wallet;
                            colorHex = '#00AED6';
                          } else if (t == 'Dompet Fisik') {
                            iconData = Icons.payments;
                            colorHex = '#10B981';
                          } else {
                            iconData = Icons.account_balance;
                            colorHex = '#1A365D';
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final cleanBal = balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final bal = double.tryParse(cleanBal) ?? 0.0;
                    AppState.instance.addWallet(WalletItem(
                      name: name,
                      type: selectedType,
                      balance: bal,
                      accountNumber: selectedType == 'Bank' ? 'Rekening' : 'Akun Utama',
                      colorHex: colorHex,
                      iconData: iconData,
                    ));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Dompet '$name' berhasil dihubungkan!"),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Simpan Dompet', style: TextStyle(color: AppTheme.textOnPrimary)),
              ),
            ],
          );
        },
      ),
    );
  }
}
