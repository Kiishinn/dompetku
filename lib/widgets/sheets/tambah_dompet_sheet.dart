import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../utils/currency_formatter.dart';
import '../../screens/dompet_screen.dart';

class TambahDompetSheet extends StatefulWidget {
  final Function(WalletItem)? onWalletAdded;

  const TambahDompetSheet({super.key, this.onWalletAdded});

  static void show(BuildContext context, {Function(WalletItem)? onWalletAdded}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TambahDompetSheet(onWalletAdded: onWalletAdded),
    );
  }

  @override
  State<TambahDompetSheet> createState() => _TambahDompetSheetState();
}

class _TambahDompetSheetState extends State<TambahDompetSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedType = 'Bank';
  String _colorHex = '#1A365D';
  IconData _iconData = Icons.account_balance;
  Color _activeThemeColor = AppTheme.primary;

  final List<Map<String, dynamic>> _accountTypes = [
    {
      'type': 'Bank',
      'label': 'Rekening Bank',
      'icon': Icons.account_balance,
      'colorHex': '#1A365D',
      'color': AppTheme.primary,
    },
    {
      'type': 'E-Wallet',
      'label': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'colorHex': '#00AED6',
      'color': const Color(0xFF00AED6),
    },
    {
      'type': 'Dompet Fisik',
      'label': 'Uang Tunai',
      'icon': Icons.payments,
      'colorHex': '#10B981',
      'color': AppTheme.incomeGreen,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _selectType(Map<String, dynamic> item) {
    setState(() {
      _selectedType = item['type'] as String;
      _iconData = item['icon'] as IconData;
      _colorHex = item['colorHex'] as String;
      _activeThemeColor = item['color'] as Color;
    });
  }

  void _saveWallet() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama akun / dompet terlebih dahulu.'),
          backgroundColor: AppTheme.expenseRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cleanBal = _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final bal = double.tryParse(cleanBal) ?? 0.0;

    final newWallet = WalletItem(
      name: name,
      type: _selectedType,
      balance: bal,
      accountNumber: _selectedType == 'Bank' ? 'Rekening' : 'Akun Utama',
      colorHex: _colorHex,
      iconData: _iconData,
    );

    AppState.instance.addWallet(newWallet);

    if (widget.onWalletAdded != null) {
      widget.onWalletAdded!(newWallet);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Dompet '$name' berhasil dihubungkan!"),
        backgroundColor: _activeThemeColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Avoid keyboard overlap gracefully
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
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

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _activeThemeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_iconData, color: _activeThemeColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Tambah Dompet Baru",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Kelola rekening bank, E-Wallet, atau kas",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainerLow,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // 1. Pilih Tipe Akun (Interactive Cards)
            const Text(
              "TIPE AKUN & DOMPET",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _accountTypes.map((item) {
                final isSelected = _selectedType == item['type'];
                final cardColor = item['color'] as Color;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _selectType(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: item != _accountTypes.last ? 10 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? cardColor.withOpacity(0.08) : AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? cardColor : AppTheme.outlineVariant.withOpacity(0.6),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: cardColor.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected ? cardColor.withOpacity(0.15) : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: isSelected ? cardColor : AppTheme.textSecondary,
                                  size: 24,
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: Icon(Icons.check_circle, size: 16, color: cardColor),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? cardColor : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 2. Input Nama Akun / Dompet
            const Text(
              "NAMA AKUN / DOMPET",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: _selectedType == 'Bank'
                    ? 'Misal: Bank BCA, Mandiri, BNI...'
                    : (_selectedType == 'E-Wallet' ? 'Misal: Gopay, OVO, DANA, ShopeePay...' : 'Misal: Kas Tunai, Dompet Harian...'),
                hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.normal),
                filled: true,
                fillColor: AppTheme.surfaceContainerLow,
                prefixIcon: Icon(_iconData, color: _activeThemeColor, size: 22),
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
                  borderSide: BorderSide(color: _activeThemeColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Input Saldo Awal
            const Text(
              "SALDO AWAL (RP)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.normal),
                filled: true,
                fillColor: AppTheme.surfaceContainerLow,
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.centerLeft,
                  width: 60,
                  child: Text(
                    'Rp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _activeThemeColor,
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
                  borderSide: BorderSide(color: _activeThemeColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
            ),

            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saveWallet,
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.textOnPrimary, size: 22),
                label: const Text(
                  "Simpan & Hubungkan Dompet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textOnPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeThemeColor,
                  elevation: 4,
                  shadowColor: _activeThemeColor.withOpacity(0.4),
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
