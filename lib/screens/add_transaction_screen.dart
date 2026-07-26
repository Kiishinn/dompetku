import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/sheets/pilih_kategori_sheet.dart';
import '../widgets/dialogs/success_animation_dialog.dart';
import '../screens/dompet_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  CategoryModel? selectedCategory; // Default null (mandatory selection!)
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedWalletName;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final FocusNode nominalFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final wallets = AppState.instance.wallets;
    if (wallets.isNotEmpty) {
      selectedWalletName = wallets[0].name;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    nominalController.dispose();
    nominalFocusNode.dispose();
    super.dispose();
  }

  void _openCategorySelect() {
    PilihKategoriSheet.show(
      context,
      onSelectCategory: (cat) {
        setState(() {
          selectedCategory = cat;
        });
      },
    );
  }

  Future<void> _pickDateAndTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
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

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
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

      if (pickedTime != null) {
        setState(() {
          selectedTime = pickedTime;
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  void _showAddQuickWalletDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'Bank';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Tambah Dompet Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Akun / Dompet',
                hintText: 'Misal: Bank BCA, Gopay...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
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
          ],
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
                final newWallet = WalletItem(
                  name: name,
                  type: selectedType,
                  balance: bal,
                  accountNumber: 'Akun Utama',
                  colorHex: '#1A365D',
                  iconData: Icons.account_balance,
                );
                AppState.instance.addWallet(newWallet);
                setState(() {
                  selectedWalletName = name;
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan', style: TextStyle(color: AppTheme.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    // MANDATORY WALLET VALIDATION
    if (AppState.instance.wallets.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.account_balance_wallet_outlined, color: AppTheme.expenseRed, size: 24),
              SizedBox(width: 8),
              Text("Belum Ada Dompet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            "Anda belum memiliki dompet/rekening terhubung. Silakan buat dompet terlebih dahulu sebelum mencatat transaksi.",
            style: TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showAddQuickWalletDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("+ Buat Dompet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    final cleanNominal = nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(cleanNominal) ?? 0.0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon masukkan nominal yang valid (> 0)"),
          backgroundColor: AppTheme.expenseRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // MANDATORY CATEGORY VALIDATION
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Harap pilih kategori transaksi terlebih dahulu!"),
          backgroundColor: AppTheme.expenseRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final targetWallet = selectedWalletName ?? AppState.instance.wallets[0].name;

    // OPSI 1: DEFICIT WARNING CONFIRMATION DIALOG IF EXPENSE > CURRENT WALLET BALANCE
    if (isExpense) {
      final walletIndex = AppState.instance.wallets.indexWhere((w) => w.name == targetWallet);
      if (walletIndex != -1) {
        final currentBalance = AppState.instance.wallets[walletIndex].balance;
        if (currentBalance < amount) {
          final deficitAmount = amount - currentBalance;
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.warningAmber, size: 28),
                  SizedBox(width: 8),
                  Text("Peringatan Defisit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Text(
                "Saldo dompet [$targetWallet] saat ini (${CurrencyFormatter.format(currentBalance)}) lebih kecil dari nominal pengeluaran (${CurrencyFormatter.format(amount)}).\n\nApakah Anda yakin ingin melanjutkan? Saldo dompet akan menjadi Defisit ${CurrencyFormatter.format(deficitAmount)}.",
                style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Batal", style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.expenseRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Tetap Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );

          if (confirm != true) return; // User cancelled
        }
      }
    }

    final titleText = titleController.text.trim().isNotEmpty
        ? titleController.text.trim()
        : selectedCategory!.name;

    final formattedHour = selectedTime.hour.toString().padLeft(2, '0');
    final formattedMinute = selectedTime.minute.toString().padLeft(2, '0');

    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: titleText,
      categoryName: selectedCategory!.name,
      walletName: targetWallet,
      amount: amount,
      isIncome: !isExpense,
      icon: selectedCategory!.icon,
      iconColor: selectedCategory!.color,
      date: selectedDate,
      timeText: '$formattedHour:$formattedMinute WIB',
      note: noteController.text.trim(),
    );

    AppState.instance.addTransaction(newTx);

    if (!mounted) return;
    Navigator.pop(context);

    SuccessAnimationDialog.show(
      context,
      title: 'Transaksi Berhasil!',
      message: "Transaksi '${newTx.title}' sebesar ${CurrencyFormatter.format(newTx.amount)} disetor ke [$targetWallet].",
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = AppState.instance.wallets;
    final formattedHour = selectedTime.hour.toString().padLeft(2, '0');
    final formattedMinute = selectedTime.minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Segmented Switcher: Pengeluaran vs Pemasukan
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpense = true;
                            if (selectedCategory != null &&
                                (selectedCategory!.name.toLowerCase() == 'pendapatan' ||
                                    selectedCategory!.name.toLowerCase() == 'gaji')) {
                              selectedCategory = null;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isExpense ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isExpense ? AppTheme.cardShadow : null,
                          ),
                          child: Center(
                            child: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isExpense ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpense = false;
                            selectedCategory = null; // Do not auto select any category!
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isExpense ? AppTheme.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: !isExpense ? AppTheme.cardShadow : null,
                          ),
                          child: Center(
                            child: Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: !isExpense ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nominal Display Box
              GestureDetector(
                onTap: () => nominalFocusNode.requestFocus(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Nominal (Tekan di mana saja pada kotak)',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Rp',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              focusNode: nominalFocusNode,
                              controller: nominalController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                ThousandsSeparatorInputFormatter(),
                              ],
                              autofocus: true,
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: AppTheme.textLight),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // PILIH DOMPET / AKUN (Wallet Selector)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isExpense ? 'Sumber Dana (Dompet):' : 'Dompet Tujuan:',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  InkWell(
                    onTap: _showAddQuickWalletDialog,
                    child: const Text(
                      '+ Tambah Dompet',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              wallets.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.expenseRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.expenseRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: AppTheme.expenseRed, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Belum ada dompet. Tekan '+ Tambah Dompet' di kanan atas untuk membuat dompet terlebih dahulu.",
                              style: TextStyle(fontSize: 12, color: AppTheme.expenseRed, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: wallets.map((wallet) {
                          final isSel = (selectedWalletName ?? wallets.first.name) == wallet.name;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setState(() => selectedWalletName = wallet.name),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSel ? AppTheme.primaryContainer : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppTheme.cardShadow,
                                  border: Border.all(
                                    color: isSel ? AppTheme.primary : AppTheme.outlineVariant.withOpacity(0.5),
                                    width: isSel ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      wallet.iconData,
                                      size: 18,
                                      color: isSel ? AppTheme.textOnPrimary : wallet.brandColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          wallet.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isSel ? AppTheme.textOnPrimary : AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(wallet.balance),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSel ? AppTheme.textOnPrimary.withOpacity(0.9) : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
              const SizedBox(height: 20),

              // Title Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.edit_outlined, color: AppTheme.primary, size: 22),
                    hintText: 'Judul (Misal: Nasi Padang, Gaji Juli...)',
                    hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kategori Selection (Mandatory & Default Unselected!)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kategori Transaksi (Wajib)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    selectedCategory != null ? selectedCategory!.name : 'Belum Dipilih',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedCategory != null ? AppTheme.primary : AppTheme.expenseRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ListenableBuilder(
                listenable: AppState.instance,
                builder: (context, _) {
                  final quickCats = AppState.instance.quickCategories;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...quickCats.map((cat) {
                        final isSelected = selectedCategory?.id == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = cat),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryContainer : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppTheme.cardShadow,
                                  border: isSelected
                                      ? Border.all(color: AppTheme.primary, width: 2)
                                      : Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: isSelected ? AppTheme.textOnPrimary : cat.color,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.name.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Lainnya option
                      GestureDetector(
                        onTap: _openCategorySelect,
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: const Icon(Icons.grid_view, color: AppTheme.primary, size: 26),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Lainnya',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Tanggal & Jam Selector Box (Interactive Date & Time Picker!)
              InkWell(
                onTap: _pickDateAndTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: AppTheme.primary, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal & Jam Transaksi', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            const SizedBox(height: 2),
                            Text(
                              '${selectedDate.day} ${const ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"][selectedDate.month - 1]} ${selectedDate.year}, $formattedHour:$formattedMinute WIB',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_calendar, color: AppTheme.primary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.notes_outlined, color: AppTheme.primary, size: 22),
                    hintText: 'Tambahkan catatan opsional...',
                    hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Simpan Transaksi Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveTransaction,
                  icon: const Icon(Icons.check_circle_outline, color: AppTheme.textOnPrimary),
                  label: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textOnPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
