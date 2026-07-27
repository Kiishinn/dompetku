import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_state.dart';
import '../models/savings_goal_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/sheets/notifikasi_sheet.dart';
import '../widgets/sheets/tambah_dompet_sheet.dart';
import '../widgets/sheets/sesuaikan_saldo_sheet.dart';
import '../widgets/animations/animated_empty_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  void _showAddSavingsGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Tambah Target Impian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Nama Target Impian',
                  hintText: 'Misal: Beli Laptop, Dana Darurat',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Target Nominal (Rp)',
                  hintText: '10.000.000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final targetStr = targetController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final target = double.tryParse(targetStr) ?? 0.0;

              if (title.isNotEmpty && target > 0) {
                final newGoal = SavingsGoalModel(
                  id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  targetAmount: target,
                  currentAmount: 0,
                  icon: Icons.stars,
                  color: AppTheme.primary,
                  targetDate: DateTime.now().add(const Duration(days: 90)),
                );
                AppState.instance.addSavingsGoal(newGoal);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Simpan Target', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDepositGoalDialog(SavingsGoalModel goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Setor Tabungan [${goal.title}]', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target: ${CurrencyFormatter.format(goal.targetAmount)} (${goal.percentageInt}% terkumpul)', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Nominal Setoran (Rp)',
                hintText: '500.000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              final cleanStr = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final amount = double.tryParse(cleanStr) ?? 0.0;
              if (amount > 0) {
                AppState.instance.depositToSavingsGoal(goal.id, amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Berhasil menyetor ${CurrencyFormatter.format(amount)} ke target ${goal.title}!"),
                    backgroundColor: AppTheme.incomeGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.incomeGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Setor Tabungan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAdjustBalanceDialog(WalletItem wallet) {
    SesuaikanSaldoSheet.show(context, wallet);
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
                ),
              ),

              // Summary Header Card with RepaintBoundary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RepaintBoundary(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              InkWell(
                                onTap: () => appState.toggleBalanceHidden(),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    appState.isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.white.withOpacity(0.85),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                                Text(
                                  !appState.isBalanceHidden
                                      ? (isDeficit ? CurrencyFormatter.format(0, showPrefix: true) : CurrencyFormatter.format(totalBalance, showPrefix: true))
                                      : 'Rp •••••••••',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (isDeficit && !appState.isBalanceHidden)
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
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 20.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                                  child: _buildWalletCard(wallet),
                                ),
                              ),
                            ),
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
                      !AppState.instance.isBalanceHidden
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
    TambahDompetSheet.show(context);
  }
}
