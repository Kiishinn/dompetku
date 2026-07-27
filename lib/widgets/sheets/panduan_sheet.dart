import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PanduanSheet extends StatelessWidget {
  const PanduanSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PanduanSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A365D), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: Colors.white, size: 22),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buku Panduan & Bantuan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pelajari cara menggunakan seluruh fitur Dompetku',
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
          SizedBox(height: 16),
          Divider(height: 1, color: AppTheme.outlineVariant),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _buildGuideSection(
                  icon: Icons.account_balance_wallet,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Memulai Dompetku',
                  items: [
                    _GuideItem(
                      title: 'Beranda',
                      desc:
                          'Halaman utama menampilkan ringkasan saldo, pemasukan, pengeluaran, dan riwayat transaksi terbaru. Gunakan filter periode (Harian, Mingguan, Bulanan, Tahunan) untuk menyaring data.',
                    ),
                    _GuideItem(
                      title: 'Navigasi Bawah',
                      desc:
                          'Terdapat 4 tab utama: Beranda, Statistik, Dompet, dan Pengaturan. Tombol "+" di tengah bawah untuk menambah transaksi baru.',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildGuideSection(
                  icon: Icons.account_balance,
                  iconColor: const Color(0xFF10B981),
                  title: 'Mengelola Dompet',
                  items: [
                    _GuideItem(
                      title: 'Membuat Dompet Baru',
                      desc:
                          'Buka tab Dompet, ketuk tombol "+" untuk menambah dompet baru. Isi nama dompet (contoh: BCA, GoPay, Tunai), pilih ikon dan warna, lalu tentukan saldo awal.',
                    ),
                    _GuideItem(
                      title: 'Transfer Antar Dompet',
                      desc:
                          'Saat menambah transaksi, pilih dompet sumber dan dompet tujuan untuk melakukan transfer antar dompet. Saldo akan otomatis berkurang dan bertambah.',
                    ),
                    _GuideItem(
                      title: 'Edit & Hapus Dompet',
                      desc:
                          'Ketuk dompet yang ingin diubah untuk mengedit nama, ikon, warna, atau menghapusnya. Perhatian: menghapus dompet tidak menghapus riwayat transaksi.',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildGuideSection(
                  icon: Icons.receipt_long,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Mencatat Transaksi',
                  items: [
                    _GuideItem(
                      title: 'Menambah Transaksi',
                      desc:
                          'Ketuk tombol "+" di navigasi bawah. Pilih jenis (Pemasukan/Pengeluaran), masukkan nominal, pilih kategori dan dompet, tambahkan catatan jika perlu, lalu simpan.',
                    ),
                    _GuideItem(
                      title: 'Kategori Transaksi',
                      desc:
                          'Tersedia berbagai kategori seperti Makanan, Transportasi, Belanja, Hiburan, Tagihan, Gaji, dan lainnya. Anda dapat mengatur ulang urutan kategori di Pengaturan.',
                    ),
                    _GuideItem(
                      title: 'Riwayat Transaksi',
                      desc:
                          'Semua transaksi tercatat di Beranda. Geser transaksi ke kiri untuk menghapus. Gunakan filter periode atau kalender untuk melihat transaksi tertentu.',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildGuideSection(
                  icon: Icons.insights,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Statistik & Anggaran',
                  items: [
                    _GuideItem(
                      title: 'Grafik Pengeluaran',
                      desc:
                          'Tab Statistik menampilkan grafik batang dan lingkaran pengeluaran per kategori. Pantau kategori mana yang paling banyak menghabiskan uang Anda.',
                    ),
                    _GuideItem(
                      title: 'Batas Anggaran Kategori',
                      desc:
                          'Di Pengaturan > Atur Batas Anggaran, tetapkan batas pengeluaran bulanan per kategori. Jika melebihi batas, Anda akan mendapat notifikasi peringatan overbudget.',
                    ),
                    _GuideItem(
                      title: 'Skor Kesehatan Finansial',
                      desc:
                          'Di Pengaturan > Skor Kesehatan Finansial, lihat analisis rasio tabungan dan saran untuk memperbaiki kesehatan keuangan Anda. Targetkan skor di atas 80!',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildGuideSection(
                  icon: Icons.update,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Tagihan Rutin & Notifikasi',
                  items: [
                    _GuideItem(
                      title: 'Tagihan Berulang',
                      desc:
                          'Di Pengaturan > Transaksi Berulang & Tagihan Rutin, tambahkan tagihan bulanan seperti Wi-Fi, Listrik, atau Langganan. Pilih tanggal jatuh tempo dan nominal.',
                    ),
                    _GuideItem(
                      title: 'Notifikasi Pengingat',
                      desc:
                          'Saat tanggal jatuh tempo tiba, Anda akan menerima notifikasi di ikon lonceng dan push notification di HP. Notifikasi jatuh tempo hanya muncul 1x per hari.',
                    ),
                    _GuideItem(
                      title: 'Peringatan Overbudget',
                      desc:
                          'Jika pengeluaran pada suatu kategori melebihi batas anggaran yang telah Anda tetapkan, sistem akan mengirim notifikasi peringatan otomatis.',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildGuideSection(
                  icon: Icons.settings_outlined,
                  iconColor: const Color(0xFF64748B),
                  title: 'Pengaturan Lainnya',
                  items: [
                    _GuideItem(
                      title: 'Cadangkan & Pulihkan Data',
                      desc:
                          'Gunakan fitur Cadangkan Data (Backup JSON) untuk menyimpan seluruh data Anda sebagai file. Gunakan Pulihkan Data (Restore JSON) untuk memulihkan dari file cadangan.',
                    ),
                    _GuideItem(
                      title: 'Ekspor Laporan',
                      desc:
                          'Unduh laporan keuangan dalam format CSV atau PDF untuk keperluan pencatatan, arsip, atau analisis lebih lanjut.',
                    ),
                    _GuideItem(
                      title: 'Reset Data',
                      desc:
                          'Di Pengaturan > Reset & Hapus Seluruh Data, Anda dapat menghapus semua riwayat dan memulai dari awal. Tindakan ini tidak dapat dibatalkan.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<_GuideItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08002045),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: iconColor.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      item.desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _GuideItem {
  final String title;
  final String desc;

  const _GuideItem({required this.title, required this.desc});
}
