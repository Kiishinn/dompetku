import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/recurring_bill_model.dart';
import '../utils/currency_formatter.dart';
import '../services/export_service.dart';
import '../services/storage_service.dart';
import '../widgets/sheets/atur_anggaran_sheet.dart';
import '../widgets/sheets/skor_kesehatan_sheet.dart';
import '../widgets/sheets/pilih_kategori_sheet.dart';
import '../widgets/sheets/notifikasi_sheet.dart';
import '../widgets/sheets/panduan_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _backupDataJson() async {
    final jsonStr = await StorageService.instance.generateBackupJson();
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Backup_Dompetku_${DateTime.now().millisecondsSinceEpoch}.json',
    );
  }

  void _restoreDataJson() {
    final jsonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Pulihkan Data Cadangan (JSON)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tempelkan teks data cadangan JSON Anda di bawah ini:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: jsonController,
              maxLines: 6,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: '{\n  "app": "Dompetku",\n  "transactions": [...]\n}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              final jsonText = jsonController.text.trim();
              if (jsonText.isNotEmpty) {
                final success = await StorageService.instance.restoreFromBackupJson(jsonText);
                if (success) {
                  await AppState.instance.loadSavedData();
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("🎉 Data cadangan JSON berhasil dipulihkan 100%!"),
                      backgroundColor: AppTheme.incomeGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ Format teks JSON tidak valid. Harap periksa kembali."),
                      backgroundColor: AppTheme.expenseRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Pulihkan Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  void _showEditProfileDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    final appState = AppState.instance;
    final nameController = TextEditingController(text: appState.userName);
    final emailController = TextEditingController(text: appState.userEmail);
    final initialNotifier = ValueNotifier<String>(
      appState.userName.isNotEmpty ? appState.userName[0].toUpperCase() : 'P',
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppTheme.surface,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Title & Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, color: AppTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Edit Profil Saya',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Avatar Preview Circle with ValueListenableBuilder
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A365D), Color(0xFF0F2942)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: ValueListenableBuilder<String>(
                    valueListenable: initialNotifier,
                    builder: (context, initialStr, _) {
                      return Text(
                        initialStr,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pratinjau Avatar',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 18),

              // Name Input Field
              TextField(
                controller: nameController,
                onChanged: (text) {
                  final trimmed = text.trim();
                  initialNotifier.value = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'P';
                },
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap / Panggilan',
                  hintText: 'Masukkan nama Anda...',
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Email Input Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  hintText: 'contoh@email.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Action Buttons Row: Batal & Simpan Profil
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppTheme.outlineVariant),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          appState.updateUserProfile(
                            nameController.text.trim(),
                            emailController.text.trim().isNotEmpty ? emailController.text.trim() : appState.userEmail,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✨ Profil berhasil diperbarui & tersimpan!'),
                              backgroundColor: AppTheme.incomeGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Simpan Profil',
                        style: TextStyle(
                          fontSize: 14,
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
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.file_download_outlined, color: AppTheme.primary, size: 26),
            SizedBox(width: 10),
            Text('Ekspor Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih format file laporan keuangan yang ingin Anda unduh:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppTheme.incomeGreen),
              title: const Text('Format CSV (Excel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Cocok untuk diolah di Microsoft Excel / Google Sheets', style: TextStyle(fontSize: 11)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppTheme.surfaceContainerLow,
              onTap: () async {
                Navigator.pop(ctx);
                await ExportService.instance.exportCsvReport(AppState.instance.transactions);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppTheme.expenseRed),
              title: const Text('Format PDF (Ringkasan Resmi)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Format cetak resmi laporan arus kas bulanan', style: TextStyle(fontSize: 11)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppTheme.surfaceContainerLow,
              onTap: () async {
                Navigator.pop(ctx);
                final appState = AppState.instance;
                await ExportService.instance.exportPdfReport(
                  appState.transactions,
                  appState.totalIncome,
                  appState.totalExpense,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showRecurringTransactionsDialog() {
    bool isAddingNew = false;
    int selectedIconIndex = 0;
    int selectedDay = 5;
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    final List<Map<String, dynamic>> availableIcons = [
      {'icon': Icons.wifi, 'label': 'WiFi', 'color': AppTheme.primary},
      {'icon': Icons.tv, 'label': 'Streaming', 'color': AppTheme.accentBlue},
      {'icon': Icons.flash_on, 'label': 'Listrik', 'color': Colors.amber.shade800},
      {'icon': Icons.water_drop, 'label': 'Air/PAM', 'color': Colors.blue.shade700},
      {'icon': Icons.phone_android, 'label': 'Pulsa/Data', 'color': Colors.purple},
      {'icon': Icons.school, 'label': 'Pendidikan', 'color': Colors.teal},
      {'icon': Icons.credit_card, 'label': 'Cicilan', 'color': Colors.redAccent},
      {'icon': Icons.home, 'label': 'Sewa/Kos', 'color': Colors.indigo},
      {'icon': Icons.shield, 'label': 'Asuransi', 'color': Colors.green.shade700},
      {'icon': Icons.work, 'label': 'Gaji', 'color': AppTheme.incomeGreen},
      {'icon': Icons.directions_car, 'label': 'Transport', 'color': Colors.orange.shade800},
      {'icon': Icons.shopping_bag, 'label': 'Belanja', 'color': Colors.pink},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetCtx, setSheetState) {
            final bills = AppState.instance.recurringBills;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppTheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!isAddingNew) ...[
                    // LIST MODE HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.update, color: AppTheme.primary, size: 24),
                            SizedBox(width: 10),
                            Text(
                              "Pengelola Tagihan Rutin",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            setSheetState(() {
                              isAddingNew = true;
                              titleController.clear();
                              amountController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "+ Tambah Tagihan",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Jadwalkan tagihan bulanan, langganan streaming, atau pengingat gaji otomatis secara terpusat.",
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // List of Recurring Bills
                    Expanded(
                      child: bills.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textSecondary),
                                  SizedBox(height: 12),
                                  Text("Belum Ada Tagihan Rutin", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                  SizedBox(height: 4),
                                  Text("Tekan '+ Tambah Tagihan' di atas untuk mendaftarkan tagihan bulanan.", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: bills.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (itemCtx, index) {
                                final bill = bills[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: bill.isActive ? AppTheme.surfaceContainerLow : AppTheme.surfaceContainerLow.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: bill.color.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(bill.icon, color: bill.color, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bill.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: bill.isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Jatuh tempo tgl ${bill.dueDateDay} • ${bill.repeatInterval}',
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            CurrencyFormatter.format(bill.amount),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: bill.isActive ? AppTheme.primary : AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Switch.adaptive(
                                                value: bill.isActive,
                                                activeColor: AppTheme.primary,
                                                onChanged: (val) {
                                                  AppState.instance.toggleRecurringBill(bill.id);
                                                  setSheetState(() {});
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: AppTheme.expenseRed, size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () {
                                                  AppState.instance.deleteRecurringBill(bill.id);
                                                  setSheetState(() {});
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("🗑️ Tagihan '${bill.title}' telah dihapus"),
                                                      backgroundColor: AppTheme.expenseRed,
                                                      behavior: SnackBarBehavior.floating,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Tutup"),
                      ),
                    ),
                  ] else ...[
                    // ADD FORM INLINE MODE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => setSheetState(() => isAddingNew = false),
                          child: Row(
                            children: const [
                              Icon(Icons.arrow_back, color: AppTheme.primary, size: 20),
                              SizedBox(width: 6),
                              Text("Kembali", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ],
                          ),
                        ),
                        const Text(
                          "Tambah Tagihan Rutin",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category-Style Icon Selector
                            const Text('Pilih Ikon Tagihan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: List.generate(availableIcons.length, (idx) {
                                final item = availableIcons[idx];
                                final isSelected = selectedIconIndex == idx;
                                final color = item['color'] as Color;
                                return InkWell(
                                  onTap: () => setSheetState(() => selectedIconIndex = idx),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(isSelected ? 0.25 : 0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? color : Colors.transparent,
                                            width: 2.5,
                                          ),
                                        ),
                                        child: Icon(item['icon'] as IconData, color: color, size: 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['label'] as String,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? color : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 18),

                            // Name Field
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Nama Tagihan / Transaksi',
                                hintText: 'Misal: WiFi IndiHome, Netflix...',
                                prefixIcon: const Icon(Icons.edit_note, color: AppTheme.primary),
                                filled: true,
                                fillColor: AppTheme.surfaceContainerLow,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Amount Field with Real-Time Thousands Separator Format & Prefix Rp
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                                if (clean.isEmpty) {
                                  amountController.value = const TextEditingValue(text: '');
                                  return;
                                }
                                final numVal = double.tryParse(clean) ?? 0.0;
                                final formatted = CurrencyFormatter.format(numVal).replaceAll('Rp ', '');
                                amountController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              },
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Nominal Tagihan',
                                hintText: '0',
                                prefixText: 'Rp ',
                                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16),
                                prefixIcon: const Icon(Icons.payments_outlined, color: AppTheme.primary),
                                filled: true,
                                fillColor: AppTheme.surfaceContainerLow,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Visual Day Selector Grid (1 to 31)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Jatuh Tempo Bulanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Tanggal $selectedDay',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: 31,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final day = index + 1;
                                  final isSelected = selectedDay == day;
                                  return InkWell(
                                    onTap: () => setSheetState(() => selectedDay = day),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primary : AppTheme.outlineVariant.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$day',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

                          if (title.isNotEmpty && amount > 0) {
                            final selIcon = availableIcons[selectedIconIndex];
                            final newBill = RecurringBillModel(
                              id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
                              title: title,
                              amount: amount,
                              categoryName: 'Tagihan & Langganan',
                              dueDateDay: selectedDay,
                              repeatInterval: 'Bulanan',
                              isActive: true,
                              icon: selIcon['icon'] as IconData,
                              color: selIcon['color'] as Color,
                            );
                            AppState.instance.addRecurringBill(newBill);
                            setSheetState(() => isAddingNew = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("🎉 Tagihan '$title' berhasil ditambahkan!"),
                                backgroundColor: AppTheme.incomeGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Simpan Tagihan"),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final unreadNotifCount = appState.unreadNotificationCount;
        final userName = appState.userName;
        final userEmail = appState.userEmail;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
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
                            Icons.person,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Profil Saya',
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
                        if (unreadNotifCount > 0)
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
                                '$unreadNotifCount',
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
                const SizedBox(height: 20),

                // VIP Hero Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A365D), Color(0xFF0F2942)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.primaryCardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Avatar with Ring Effect
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _showEditProfileDialog,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.incomeGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.incomeGreen.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.workspace_premium_rounded, color: AppTheme.incomeGreen, size: 14),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Akun Premium • Dompetku Pro',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.incomeGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      const SizedBox(height: 14),
                      // Live Financial Health Score Banner inside Hero Card!
                      InkWell(
                        onTap: () => SkorKesehatanSheet.show(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.health_and_safety_outlined,
                                    color: appState.financialHealthScore > 0 ? appState.financialHealthColor : Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kesehatan Finansial: ${appState.financialHealthTitle}${appState.financialHealthScore > 0 ? ' (${appState.financialHealthScore}/100)' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Text(
                  'Pengaturan & Fitur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Section: Pengaturan Keuangan Card
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.pie_chart_outline,
                        title: 'Batas Anggaran Bulanan',
                        subtitle: 'Atur limit pengeluaran per kategori',
                        onTap: () {
                          AturAnggaranSheet.show(
                            context,
                            categoryName: 'Makanan & Minuman',
                            currentLimit: 3500000.0,
                            onSaveBudget: (catName, limit, warningPercent, isNotif) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Anggaran [$catName] disetor ke Rp ${limit.toInt()} (Peringatan di $warningPercent%)",
                                  ),
                                  backgroundColor: AppTheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.category_outlined,
                        title: 'Kelola Kategori Custom',
                        subtitle: 'Tambah ikon dan warna kategori baru',
                        onTap: () {
                          PilihKategoriSheet.show(
                            context,
                            isManageOnly: true,
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.health_and_safety_outlined,
                        title: 'Skor Kesehatan Finansial',
                        subtitle: 'Lihat analisis dan saran rasio tabungan',
                        onTap: () {
                          SkorKesehatanSheet.show(context);
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.update,
                        title: 'Transaksi Berulang & Tagihan Rutin',
                        subtitle: 'Kelola jadwal otomatis (Gaji, Tagihan & Langganan)',
                        onTap: () {
                          _showRecurringTransactionsDialog();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Text(
                  'Sistem & Keamanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Section: Sistem & Keamanan Card
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.surfaceContainerLow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active_outlined,
                                      color: AppTheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Notifikasi & Peringatan',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Pengingat overbudget & laporan harian',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: appState.isNotificationEnabled,
                              onChanged: (val) {
                                appState.toggleNotifications(val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(val ? "Notifikasi & Peringatan Diaktifkan" : "Notifikasi Dinonaktifkan secara total"),
                                    backgroundColor: val ? AppTheme.primary : AppTheme.expenseRed,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              activeColor: AppTheme.textOnPrimary,
                              activeTrackColor: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.file_download_outlined,
                        title: 'Ekspor Laporan Keuangan',
                        subtitle: 'Unduh format CSV atau PDF',
                        onTap: _showExportDialog,
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.cloud_upload_outlined,
                        title: 'Cadangkan Data (Backup JSON)',
                        subtitle: 'Simpan file cadangan transaksi & dompet',
                        onTap: _backupDataJson,
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.cloud_download_outlined,
                        title: 'Pulihkan Data (Restore JSON)',
                        subtitle: 'Pulihkan data dari file cadangan',
                        onTap: _restoreDataJson,
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.menu_book_rounded,
                        title: 'Buku Panduan & Bantuan',
                        subtitle: 'Pelajari cara menggunakan seluruh fitur',
                        onTap: () {
                          PanduanSheet.show(context);
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: 'Tentang Dompetku v1.0',
                        subtitle: 'Aplikasi Catatan Keuangan Indonesia',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Dompetku',
                            applicationVersion: 'v1.0.0 (Flutter M3)',
                            applicationIcon: const Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.primary,
                              size: 40,
                            ),
                            children: const [
                              Text(
                                "Dompetku adalah aplikasi keuangan pribadi bergaya Financial Serenity modern, dibangun untuk kemanfaatan literasi dan pemantauan finansial Indonesia.",
                              ),
                            ],
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.outlineVariant.withOpacity(0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        icon: Icons.delete_forever_outlined,
                        title: 'Reset & Hapus Seluruh Data',
                        subtitle: 'Hapus riwayat transaksi dan reset saldo',
                        iconColor: AppTheme.expenseRed,
                        titleColor: AppTheme.expenseRed,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (confirmCtx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text("⚠️ Reset Seluruh Data?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.expenseRed)),
                              content: const Text("Apakah Anda yakin ingin menghapus seluruh riwayat transaksi, mereset saldo dompet, dan mengembalikan profil ke awal? Tindakan ini tidak dapat dibatalkan."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(confirmCtx),
                                  child: const Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(confirmCtx);
                                    AppState.instance.removeAllData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("🗑️ Seluruh data & profil telah di-reset dari awal!"),
                                        backgroundColor: AppTheme.expenseRed,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.expenseRed,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("Ya, Reset Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppTheme.primary).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor ?? AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: titleColor ?? AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
