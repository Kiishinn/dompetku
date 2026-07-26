import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.account_balance_wallet,
      iconBgColors: [Color(0xFF1A365D), Color(0xFF2563EB)],
      title: 'Selamat Datang di Dompetku',
      subtitle: 'Financial Serenity',
      description:
          'Aplikasi keuangan pribadi yang membantu Anda memantau pemasukan, pengeluaran, dan mencapai ketenangan finansial.',
      accentColor: Color(0xFF2563EB),
    ),
    _OnboardingPageData(
      icon: Icons.account_balance,
      iconBgColors: [Color(0xFF10B981), Color(0xFF059669)],
      title: 'Kelola Dompet Anda',
      subtitle: 'Multi-Dompet & Saldo Real-Time',
      description:
          'Buat beberapa dompet (Tunai, BCA, GoPay, dll), pantau saldo masing-masing, dan transfer antar dompet dengan mudah.',
      accentColor: Color(0xFF10B981),
    ),
    _OnboardingPageData(
      icon: Icons.receipt_long,
      iconBgColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      title: 'Catat Transaksi Harian',
      subtitle: 'Pemasukan & Pengeluaran',
      description:
          'Catat setiap pemasukan dan pengeluaran dengan kategori, dompet tujuan, dan catatan. Riwayat transaksi tersimpan otomatis.',
      accentColor: Color(0xFF8B5CF6),
    ),
    _OnboardingPageData(
      icon: Icons.insights,
      iconBgColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      title: 'Statistik & Anggaran',
      subtitle: 'Grafik & Skor Kesehatan Finansial',
      description:
          'Lihat grafik pengeluaran per kategori, atur batas anggaran bulanan, dan pantau skor kesehatan finansial Anda.',
      accentColor: Color(0xFFF59E0B),
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active,
      iconBgColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      title: 'Tagihan & Notifikasi',
      subtitle: 'Pengingat Otomatis Jatuh Tempo',
      description:
          'Atur tagihan rutin bulanan (Wi-Fi, listrik, langganan) dan terima notifikasi pengingat otomatis saat jatuh tempo.',
      accentColor: Color(0xFFEC4899),
    ),
  ];

  void _navigateToMain() async {
    await StorageService.instance.saveFirstLaunchDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FF), Color(0xFFE5EEFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _navigateToMain,
                        child: const Text(
                          'Lewati',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 48),
                  ],
                ),
              ),

              // PageView Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Bottom Section: Dots + Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Page Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? _pages[_currentPage].accentColor
                                : AppTheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _navigateToMain();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pages[_currentPage].accentColor,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor:
                              _pages[_currentPage].accentColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? 'Selanjutnya'
                              : 'Mulai Sekarang',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large Icon Container with Gradient
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.iconBgColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.accentColor.withOpacity(0.35),
                  blurRadius: 40,
                  spreadRadius: 4,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),

          // Subtitle Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: data.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: data.accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final List<Color> iconBgColors;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;

  const _OnboardingPageData({
    required this.icon,
    required this.iconBgColors,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
  });
}
