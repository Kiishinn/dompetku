import 'package:flutter/material.dart';
import '../../models/app_state.dart';
import '../../screens/dompet_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../sheets/tambah_dompet_sheet.dart';
import '../sheets/sesuaikan_saldo_sheet.dart';

class WalletCarouselCard extends StatefulWidget {
  const WalletCarouselCard({super.key});

  @override
  State<WalletCarouselCard> createState() => _WalletCarouselCardState();
}

class _WalletCarouselCardState extends State<WalletCarouselCard> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final wallets = appState.wallets;
        final int totalSlides = wallets.length + 1; // 0 = Total Saldo, 1..N = Dompet individual

        // Jika halaman saat ini melebihi jumlah dompet setelah ada penghapusan dompet
        if (_currentPage >= totalSlides && totalSlides > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentPage = 0;
                _pageController.jumpToPage(0);
              });
            }
          });
        }

        final double totalBalance = appState.totalBalance;
        final bool isDeficit = totalBalance < 0;

        return Column(
          children: [
            // PageView untuk Kartu Dompet Bergeser (Carousel)
            SizedBox(
              height: 182,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                itemCount: totalSlides,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTotalBalanceSlide(context, appState, totalBalance, isDeficit, wallets.length);
                  } else {
                    final wallet = wallets[index - 1];
                    return _buildWalletSlide(context, appState, wallet, totalBalance, index - 1, wallets.length);
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // Modern Interactive Capsule Indicator (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSlides, (index) {
                final isSelected = _currentPage == index;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.outlineVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  // Slide 0: Kartu Utama Total Saldo Gabungan
  Widget _buildTotalBalanceSlide(
    BuildContext context,
    AppState appState,
    double totalBalance,
    bool isDeficit,
    int walletCount,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.fromLTRB(22, 20, 20, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A365D), Color(0xFF0F2942)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.primaryCardShadow,
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris Atas: Label & Tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 15),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TOTAL SALDO',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textOnPrimary.withOpacity(0.9),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Tombol Tambah Dompet Cepat
                    InkWell(
                      onTap: () => TambahDompetSheet.show(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              'Dompet',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textOnPrimary.withOpacity(0.95),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Tombol Privasi Mata
                    InkWell(
                      onTap: () => appState.toggleBalanceHidden(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Icon(
                          appState.isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.textOnPrimary.withOpacity(0.85),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Tengah: Nominal Angka Saldo
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                Text(
                  appState.isBalanceHidden
                      ? 'Rp •••••••••'
                      : (isDeficit
                          ? CurrencyFormatter.format(0, showPrefix: true)
                          : CurrencyFormatter.format(totalBalance, showPrefix: true)),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textOnPrimary,
                    letterSpacing: -0.6,
                  ),
                ),
                if (isDeficit && !appState.isBalanceHidden)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.expenseRed.withOpacity(0.95),
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

            // Baris Bawah: Petunjuk Geser & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.swipe_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Geser kiri lihat rincian $walletCount dompet Anda',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textOnPrimary.withOpacity(0.75),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Gabungan',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textOnPrimary.withOpacity(0.85),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Slide 1..N: Kartu Per Dompet
  Widget _buildWalletSlide(
    BuildContext context,
    AppState appState,
    WalletItem wallet,
    double totalBalance,
    int index,
    int totalWallets,
  ) {
    // Kurasi Palet Gradien Ala Sultan Fintech Tier-1 berdasarkan urutan atau warna dompet
    final List<List<Color>> executiveGradients = [
      const [Color(0xFF0A5C36), Color(0xFF032817)], // Emerald Green (Bank BCA / Mandiri / Syariah)
      const [Color(0xFF6B21A8), Color(0xFF2A0D45)], // Royal Purple (OVO / Jenius)
      const [Color(0xFF991B1B), Color(0xFF450A0A)], // Crimson Ruby (Tunai / CIMB)
      const [Color(0xFF0D9488), Color(0xFF073C37)], // Teal Diamond (Gopay / Jago)
      const [Color(0xFFB45309), Color(0xFF451E03)], // Sunset Amber (DANA / ShopeePay)
      const [Color(0xFF334155), Color(0xFF0F172A)], // Slate Onyx (Investasi / Lainnya)
    ];

    final gradient = executiveGradients[index % executiveGradients.length];

    // Hitung persentase porsi saldo dompet dari total seluruh uang
    String percentageText = "Akun Aktif";
    if (totalBalance > 0 && wallet.balance > 0) {
      final percentage = (wallet.balance / totalBalance) * 100;
      percentageText = "${percentage.toStringAsFixed(1)}% dari total uang Anda";
    } else if (wallet.balance < 0) {
      percentageText = "Saldo Minus (Perlu Top-Up)";
    }

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.fromLTRB(22, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.primaryCardShadow,
          border: Border.all(color: Colors.white.withOpacity(0.16), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris Atas: Ikon, Nama Dompet & Tombol Aksi Cepat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(wallet.iconData, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          wallet.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Tombol Sesuaikan Saldo Cepat
                    InkWell(
                      onTap: () => SesuaikanSaldoSheet.show(context, wallet),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tune_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              'Sesuaikan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Tombol Privasi Mata
                    InkWell(
                      onTap: () => appState.toggleBalanceHidden(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Icon(
                          appState.isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.white.withOpacity(0.85),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Tengah: Saldo Khusus Dompet Ini
            Text(
              appState.isBalanceHidden
                  ? 'Rp •••••••••'
                  : CurrencyFormatter.format(wallet.balance, showPrefix: true),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),

            // Baris Bawah: Persentase Porsi & Indikator Urutan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    percentageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Dompet ${index + 1}/$totalWallets',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
