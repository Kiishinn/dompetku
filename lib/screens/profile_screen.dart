import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../services/export_service.dart';
import '../widgets/sheets/atur_anggaran_sheet.dart';
import '../widgets/sheets/skor_kesehatan_sheet.dart';
import '../widgets/sheets/pilih_kategori_sheet.dart';
import '../widgets/sheets/notifikasi_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationEnabled = true;

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
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("📄 Laporan Format CSV berhasil diunduh ke folder Download!"),
                    backgroundColor: AppTheme.incomeGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
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
                    if (AppState.instance.unreadNotificationCount > 0)
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
                            '${AppState.instance.unreadNotificationCount}',
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

            // Profile Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nabil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'nabilsyawaludin@gmail.com',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.incomeGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Akun Premium • Dompetku Pro',
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
                        onSelectCategory: (cat) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Kategori '${cat.name}' terpilih!"),
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
                    icon: Icons.health_and_safety_outlined,
                    title: 'Skor Kesehatan Finansial',
                    subtitle: 'Lihat analisis dan saran rasio tabungan',
                    onTap: () {
                      SkorKesehatanSheet.show(context);
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
                          value: isNotificationEnabled,
                          onChanged: (val) {
                            setState(() => isNotificationEnabled = val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val ? "Notifikasi & Peringatan Diaktifkan" : "Notifikasi Dinonaktifkan"),
                                backgroundColor: AppTheme.primary,
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
                        children: [
                          const Text(
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
                          content: const Text("Apakah Anda yakin ingin menghapus seluruh riwayat transaksi dan mereset saldo dompet? Tindakan ini tidak dapat dibatalkan."),
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
                                    content: Text("🗑️ Seluruh data telah di-reset dari awal!"),
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
