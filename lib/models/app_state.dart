import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'category_model.dart';
import '../screens/dompet_screen.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.icon = Icons.notifications_active,
    this.iconColor = AppTheme.primary,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} j yang lalu';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal() {
    NotificationService.instance.init();
    loadSavedData();
  }

  bool isNotificationEnabled = true;

  // Reactive Category List (Re-orderable by User!)
  final List<CategoryModel> _categories = List.from(AppCategories.allCategories);

  // Category Budget Limits (Map of Category Name -> Limit Amount)
  Map<String, double> _categoryBudgets = {};

  // Notification items list
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'notif_welcome',
      title: 'Sistem Dompetku Aktif',
      message: 'Notifikasi & Peringatan Overbudget telah aktif untuk memantau kesehatan finansial Anda.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      icon: Icons.shield_outlined,
      iconColor: AppTheme.primary,
    ),
  ];

  // Initial state: empty transactions, starting clean!
  List<TransactionModel> _transactions = [];
  
  // Initial state: empty wallets, starting clean!
  List<WalletItem> _wallets = [];

  Future<void> loadSavedData() async {
    final savedTxs = await StorageService.instance.loadTransactions();
    final savedWallets = await StorageService.instance.loadWallets();
    final savedBudgets = await StorageService.instance.loadCategoryBudgets();
    final notifEnabled = await StorageService.instance.loadNotificationEnabled();

    _transactions = savedTxs;
    _wallets = savedWallets;
    _categoryBudgets = savedBudgets;
    isNotificationEnabled = notifEnabled;
    notifyListeners();
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<CategoryModel> get quickCategories => _categories.take(4).toList();

  Map<String, double> get categoryBudgets => Map.unmodifiable(_categoryBudgets);

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<WalletItem> get wallets => List.unmodifiable(_wallets);

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  double get totalBalance => _wallets.fold(0.0, (sum, item) => sum + item.balance);
  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpense => _transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

  double get totalBudgetedLimit => _categoryBudgets.values.fold(0.0, (sum, v) => sum + v);

  void toggleNotifications(bool enabled) {
    isNotificationEnabled = enabled;
    StorageService.instance.saveNotificationEnabled(enabled);
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    
    // Trigger System Native Notification Pop-up on Android/iOS Status Bar!
    if (isNotificationEnabled) {
      NotificationService.instance.showNotification(
        id: item.id.hashCode.abs(),
        title: item.title,
        body: item.message,
      );
    }
    
    notifyListeners();
  }

  double getCategorySpentThisMonth(String categoryName) {
    final now = DateTime.now();
    final targetNorm = categoryName.toLowerCase().replaceAll('an', '').replaceAll(' ', '');
    return _transactions.where((t) {
      if (t.isIncome) return false;
      if (t.date.year != now.year || t.date.month != now.month) return false;
      final txNorm = t.categoryName.toLowerCase().replaceAll('an', '').replaceAll(' ', '');
      return txNorm == targetNorm || t.categoryName.toLowerCase() == categoryName.toLowerCase();
    }).fold(0.0, (sum, t) => sum + t.amount);
  }

  void setCategoryBudget(String categoryName, double limit) {
    if (limit <= 0) {
      _categoryBudgets.remove(categoryName);
    } else {
      _categoryBudgets[categoryName] = limit;
      checkBudgetAlertForCategory(categoryName);
    }
    StorageService.instance.saveCategoryBudgets(_categoryBudgets);
    notifyListeners();
  }

  void checkBudgetAlertForCategory(String categoryName) {
    if (!isNotificationEnabled) return;
    final limit = _categoryBudgets[categoryName] ?? 0.0;
    if (limit <= 0) return;

    final spent = getCategorySpentThisMonth(categoryName);
    final ratio = spent / limit;

    if (spent > limit) {
      final over = spent - limit;
      final notifId = 'notif_over_${categoryName}_${DateTime.now().month}';
      if (!_notifications.any((n) => n.id == notifId)) {
        addNotification(NotificationItem(
          id: notifId,
          title: '⚠️ Overbudget: $categoryName',
          message: 'Pengeluaran [$categoryName] mencapai ${CurrencyFormatter.format(spent)} (Melampaui limit ${CurrencyFormatter.format(limit)} sebesar ${CurrencyFormatter.format(over)})!',
          timestamp: DateTime.now(),
          icon: Icons.error_outline,
          iconColor: AppTheme.expenseRed,
        ));
      }
    } else if (ratio >= 0.8) {
      final percentInt = (ratio * 100).toInt();
      final notifId = 'notif_warn_${categoryName}_${DateTime.now().month}';
      if (!_notifications.any((n) => n.id == notifId)) {
        addNotification(NotificationItem(
          id: notifId,
          title: '🔔 Peringatan Anggaran ($percentInt%)',
          message: 'Pengeluaran [$categoryName] telah terpakai $percentInt% (${CurrencyFormatter.format(spent)} dari ${CurrencyFormatter.format(limit)}).',
          timestamp: DateTime.now(),
          icon: Icons.warning_amber_rounded,
          iconColor: AppTheme.warningAmber,
        ));
      }
    }
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    notifyListeners();
  }

  void addCustomCategory(CategoryModel cat) {
    _categories.insert(0, cat);
    notifyListeners();
  }

  void adjustWalletBalance(String walletName, double newActualBalance) {
    int targetIndex = _wallets.indexWhere((w) => w.name == walletName);
    if (targetIndex == -1) return;

    final wallet = _wallets[targetIndex];
    final diff = newActualBalance - wallet.balance;

    if (diff == 0) return;

    final oldBal = wallet.balance;

    // Update wallet balance to new actual balance
    _wallets[targetIndex] = WalletItem(
      name: wallet.name,
      type: wallet.type,
      balance: newActualBalance,
      accountNumber: wallet.accountNumber,
      colorHex: wallet.colorHex,
      iconData: wallet.iconData,
    );

    // Automatically record a Balance Adjustment Transaction for transparency!
    final isInc = diff > 0;
    final absDiff = diff.abs();

    final tx = TransactionModel(
      id: 'tx_adj_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Penyesuaian Saldo (${isInc ? 'Selisih Lebih' : 'Selisih Kurang'})',
      categoryName: 'Penyesuaian Saldo',
      walletName: walletName,
      amount: absDiff,
      isIncome: isInc,
      icon: Icons.tune,
      iconColor: isInc ? AppTheme.incomeGreen : AppTheme.expenseRed,
      date: DateTime.now(),
      timeText: '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} WIB',
      note: 'Penyesuaian otomatis dari ${CurrencyFormatter.format(oldBal)} menjadi ${CurrencyFormatter.format(newActualBalance)}.',
    );

    _transactions.insert(0, tx);
    StorageService.instance.saveTransactions(_transactions);
    StorageService.instance.saveWallets(_wallets);

    if (isNotificationEnabled) {
      addNotification(NotificationItem(
        id: 'notif_adj_${DateTime.now().millisecondsSinceEpoch}',
        title: '✏️ Penyesuaian Saldo [$walletName]',
        message: 'Saldo $walletName disesuaikan dari ${CurrencyFormatter.format(oldBal)} menjadi ${CurrencyFormatter.format(newActualBalance)}.',
        timestamp: DateTime.now(),
        icon: Icons.tune,
        iconColor: AppTheme.primary,
      ));
    }

    notifyListeners();
  }

  void addTransaction(TransactionModel tx) {
    _transactions.insert(0, tx); // Insert at top of list (latest first)

    // Update the balance of the specific selected wallet
    int targetIndex = _wallets.indexWhere((w) => w.name == tx.walletName);
    if (targetIndex == -1 && _wallets.isNotEmpty) {
      targetIndex = 0; // Fallback to first wallet if not matched
    }

    if (targetIndex != -1) {
      final target = _wallets[targetIndex];
      final newBalance = tx.isIncome ? (target.balance + tx.amount) : (target.balance - tx.amount);
      _wallets[targetIndex] = WalletItem(
        name: target.name,
        type: target.type,
        balance: newBalance,
        accountNumber: target.accountNumber,
        colorHex: target.colorHex,
        iconData: target.iconData,
      );
    }

    StorageService.instance.saveTransactions(_transactions);
    StorageService.instance.saveWallets(_wallets);

    // Run automatic budget notification check for this category!
    if (!tx.isIncome) {
      checkBudgetAlertForCategory(tx.categoryName);
    }

    notifyListeners();
  }

  void deleteTransaction(String txId) {
    int targetIdx = _transactions.indexWhere((t) => t.id == txId);
    if (targetIdx == -1) return;

    final tx = _transactions[targetIdx];

    // Revert wallet balance changes
    int wIdx = _wallets.indexWhere((w) => w.name == tx.walletName);
    if (wIdx != -1) {
      final w = _wallets[wIdx];
      // If deleted tx was expense, add back amount. If income, subtract amount.
      final newBal = tx.isIncome ? (w.balance - tx.amount) : (w.balance + tx.amount);
      _wallets[wIdx] = WalletItem(
        name: w.name,
        type: w.type,
        balance: newBal,
        accountNumber: w.accountNumber,
        colorHex: w.colorHex,
        iconData: w.iconData,
      );
    }

    _transactions.removeAt(targetIdx);
    StorageService.instance.saveTransactions(_transactions);
    StorageService.instance.saveWallets(_wallets);
    notifyListeners();
  }

  void deleteWallet(String walletName) {
    _wallets.removeWhere((w) => w.name == walletName);
    StorageService.instance.saveWallets(_wallets);
    notifyListeners();
  }

  void addWallet(WalletItem wallet) {
    _wallets.add(wallet);
    StorageService.instance.saveWallets(_wallets);
    notifyListeners();
  }

  void removeAllData() {
    _transactions.clear();
    _wallets.clear();
    _categoryBudgets.clear();
    _notifications.clear();
    StorageService.instance.saveTransactions(_transactions);
    StorageService.instance.saveWallets(_wallets);
    StorageService.instance.saveCategoryBudgets(_categoryBudgets);
    notifyListeners();
  }
}
