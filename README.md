# Dompetku

Aplikasi catatan keuangan harian dan manajemen arus kas lokal dengan desain santai, bersih, dan langsung ke intinya. Dibangun menggunakan Flutter.

---

## Tentang Proyek Ini

Kebanyakan aplikasi keuangan pribadi di luar sana butuh koneksi internet aktif, harus mendaftarkan akun, atau terlalu ramai oleh fitur-fitur kompleks yang jarang dipake seharian. **Dompetku** dirancang dengan filosofi kebalikan: memberikan antarmuka pencatatan kas yang cepat, 100% beroperasi secara lokal (*offline-first*), namun tetap sanggup mengelola hal-hal esensial seperti pemantauan banyak rekening sekaligus, mutasi kas, hingga pengingat tagihan bulanan.

---

## Fitur Utama

* **Manajemen Multi-Dompet:**
  Buat berbagai akun dompet (Uang Tunai, rekening bank, atau E-Wallet) lengkap dengan pemantauan saldonya. Kalau ada mutasi antar dompet, fitur *Transfer Dana* akan merapikan mutasi keluar-masuknya, plus ada audit otomatis kalau kamu perlu bikin penyesuaian/selisih saldo manual.

* **Alarm Batas Anggaran (Overbudget Watchdog):**
  Kamu bisa pasang batas maksimal pengeluaran di tiap kategori bulanan (misal: budget jajan atau makan). Kalau penggunaanmu udah sentuh angka 80%, atau malah bablas melampaui limit, aplikasi langsung naikin bendera peringatan (notifikasi instan).

* **Jadwal Tagihan Rutin:**
  Buat nyatat pengeluaran wajib mingguan atau bulanan kayak langganan internet, Netflix, atau bayaran listrik. Sistem bakal ngecek kalender HP tiap kali dibuka dan nerbitin pengingat pas tanggal jatuh temponya tiba (dibatasi 1x per hari biar nggak mengganggu atau nyepam di status bar).

* **Analisis & Skor Kesehatan Finansial:**
  Nggak perlu jago akuntansi. Ada tab statistik buat ngelihat grafik pengeluaran terbesar per kategori (pake grafik batang & lingkaran), ditambah skor evaluasi kesehatan keuangan (0 - 98) berdasarkan persentase uang yang kamu sisakan dibanding pendapatanmu.

* **100% Privasi, Backup JSON & Ekspor Laporan:**
  Semua catatan transaksi sepenuhnya menetap di dalam memori penyimpanan internal HP kamu (*SharedPreferences & filesystem*). Kalau butuh cadangan data buat ganti HP, cukup unduh file *Backup JSON*. Perlu rekapan kas bulanan buat diprint? Bisa langsung di-export jadi berkas **PDF** rapi ataupun format tabel **CSV** buat diolah di Excel.

* **Onboarding & Buku Panduan di Dalam Aplikasi:**
  Pengguna baru dihantar pakai 5 slide tutorial singkat di awal pemasangan. Setelah itu ada menu **"Buku Panduan & Bantuan"** di setting yang merangkum segala cara pakai fitur aplikasinya offline kapan saja.

---

## Teknologi yang Digunakan (Tech Stack)

* **Core:** Flutter 3 & Dart (Dibuat mengikuti pedoman UI *Material Design 3* dengan styling custom bertema *Financial Serenity*).
* **State Management:** Paduan reaktif `ChangeNotifier` dan `ListenableBuilder` (pendekatan natif Flutter modern yang super ringan tanpa library rumit atau boilerplate berlebihan).
* **Local Storage:** `shared_preferences` untuk sinkronisasi kilat state lokal & manipulasi JSON filesystem secara asinkron.
* **UI & Report Module:** 
  * `fl_chart` untuk render grafik statistik modern.
  * `pdf` & `printing` untuk pembuka dan perancang cetakan laporan bulanan.
  * `flutter_local_notifications` untuk integrasi alarm status bar Android/iOS.
  * `flutter_animate` & `flutter_staggered_animations` untuk memberikan responsivitas visual yang hidup dan adem diliat.

---

## Cara Menjalankan di Lokal (Dev Setup)

Pastikan di komputermu sudah terpasang SDK Flutter dan Dart terbaru.

1. **Clone repositori ini:**
   ```bash
   git clone https://github.com/username-anda/dompetku.git
   cd dompetku
   ```

2. **Unduh seluruh dependensi perpustakaan (*package*):**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi di emulator atau perangkat fisik:**
   ```bash
   flutter run
   ```

---

## Lisensi & Kontribusi
Proyek ini bersifat terbuka untuk keperluan belajar, modifikasi, maupun pengembangan lebih lanjut. Kapan saja punya ide baru atau nemuin *bug*, silakan ajukan *Issue* atau kirimkan *Pull Request*! 🛠️☕
