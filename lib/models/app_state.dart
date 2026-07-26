import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'category_model.dart';
import 'savings_goal_model.dart';
import 'recurring_bill_model.dart';
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'iconCodePoint': icon.codePoint,
        'iconColorValue': iconColor.value,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      isRead: json['isRead'] ?? false,
      icon: IconData(json['iconCodePoint'] ?? Icons.notifications_active.codePoint, fontFamily: 'MaterialIcons'),
      iconColor: Color(json['iconColorValue'] ?? AppTheme.primary.value),
    );
  }
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal() {
    NotificationService.instance.init();
    loadSavedData();
  }

  bool isNotificationEnabled = true;

  // User Profile
  String userName = 'Pengguna Dompetku';
  String userEmail = 'Email belum diatur';

  // Reactive Category List (Re-orderable by User!)
  final List<CategoryModel> _categories = List.from(AppCategories.allCategories);

  // Category Budget Limits (Map of Category Name -> Limit Amount)
  Map<String, double> _categoryBudgets = {};

  // Notification items list
  List<NotificationItem> _notifications = [];

  // Initial state: empty transactions, starting clean!
  List<TransactionModel> _transactions = [];
  
  // Initial state: empty wallets, starting clean!
  List<WalletItem> _wallets = [];

  Future<void> loadSavedData() async {
    final savedTxs = await StorageService.instance.loadTransactions();
    final savedWallets = await StorageService.instance.loadWallets();
    final savedBudgets = await StorageService.instance.loadCategoryBudgets();
    final notifEnabled = await StorageService.instance.loadNotificationEnabled();
    final userProfile = await StorageService.instance.loadUserProfile();

    final savedGoals = await StorageService.instance.loadSavingsGoals();
    final savedBills = await StorageService.instance.loadRecurringBills();
    final savedNotifiedKeys = await StorageService.instance.loadNotifiedKeys();

    final savedNotifsRaw = await StorageService.instance.loadNotificationsRaw();
    if (savedNotifsRaw.isNotEmpty) {
      _notifications = savedNotifsRaw.map((j) => NotificationItem.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      _notifications = [
        NotificationItem(
          id: 'notif_welcome',
          title: 'Sistem Dompetku Aktif',
          message: 'Notifikasi & Peringatan Overbudget telah aktif untuk memantau kesehatan finansial Anda.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: true,
          icon: Icons.shield_outlined,
          iconColor: AppTheme.primary,
        ),
      ];
      await StorageService.instance.saveNotifications(_notifications);
    }

    _transactions = savedTxs;
    _wallets = savedWallets;
    _categoryBudgets = savedBudgets;
    _savingsGoals = savedGoals;
    _recurringBills = savedBills.where((b) => b.id != 'rec_wifi' && b.id != 'rec_netflix').toList();
    _notifiedKeys = savedNotifiedKeys;
    await StorageService.instance.saveRecurringBills(_recurringBills);
    isNotificationEnabled = notifEnabled;
    userName = userProfile['name'] ?? 'Pengguna Dompetku';
    userEmail = userProfile['email'] ?? 'Email belum diatur';
    _autoPurgeOldNotifications();
    _checkRecurringBillNotifications();
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    StorageService.instance.saveNotifications(_notifications);
    notifyListeners();
  }

  void _autoPurgeOldNotifications() {
    final now = DateTime.now();
    _notifications.removeWhere((n) => now.difference(n.timestamp).inDays > 30);
    StorageService.instance.saveNotifications(_notifications);
  }

  void updateUserProfile(String name, String email) {
    userName = name;
    userEmail = email;
    StorageService.instance.saveUserProfile(name, email);
    notifyListeners();
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<CategoryModel> get quickCategories => _categories.take(4).toList();

  Map<String, double> get categoryBudgets => Map.unmodifiable(_categoryBudgets);

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<WalletItem> get wallets => List.unmodifiable(_wallets);

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  // Savings Goals Impian List (Starts clean!)
  List<SavingsGoalModel> _savingsGoals = [];

  List<SavingsGoalModel> get savingsGoals => List.unmodifiable(_savingsGoals);

  void addSavingsGoal(SavingsGoalModel goal) {
    _savingsGoals.add(goal);
    StorageService.instance.saveSavingsGoals(_savingsGoals);
    notifyListeners();
  }

  void depositToSavingsGoal(String goalId, double amount) {
    int idx = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      _savingsGoals[idx].currentAmount += amount;
      StorageService.instance.saveSavingsGoals(_savingsGoals);
      notifyListeners();
    }
  }

  List<RecurringBillModel> _recurringBills = [];
  List<String> _notifiedKeys = [];

  void _checkRecurringBillNotifications() {
    final now = DateTime.now();
    bool hasNewNotif = false;
    for (final bill in _recurringBills) {
      if (bill.isActive && bill.dueDateDay == now.day) {
        final notifId = 'notif_rec_${bill.id}_${now.day}_${now.month}_${now.year}';
        
        // 1. In-App Notification Center Sync (Always visible in Bell 🔔)
        final existsInList = _notifications.any((n) => n.id == notifId);
        if (!existsInList) {
          final formattedAmount = CurrencyFormatter.format(bill.amount);
          final titleStr = 'Pengingat Tagihan: ${bill.title}';
          final msgStr = 'Tagihan ${bill.title} sebesar $formattedAmount jatuh tempo hari ini!';

          _notifications.insert(
            0,
            NotificationItem(
              id: notifId,
              title: titleStr,
              message: msgStr,
              timestamp: now,
              icon: Icons.update,
              iconColor: bill.color,
            ),
          );
          hasNewNotif = true;
        }

        // 2. Push Notification HP Lock (Rings ONLY 1x per day!)
        if (!_notifiedKeys.contains(notifId)) {
          _notifiedKeys.add(notifId);
          StorageService.instance.saveNotifiedKeys(_notifiedKeys);

          if (isNotificationEnabled) {
            final formattedAmount = CurrencyFormatter.format(bill.amount);
            final titleStr = 'Pengingat Tagihan: ${bill.title}';
            final msgStr = 'Tagihan ${bill.title} sebesar $formattedAmount jatuh tempo hari ini!';

            NotificationService.instance.showNotification(
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              title: titleStr,
              body: msgStr,
            );
          }
        }
      }
    }
    if (hasNewNotif) {
      StorageService.instance.saveNotifications(_notifications);
    }
  }

  List<RecurringBillModel> get recurringBills => List.unmodifiable(_recurringBills);

  void addRecurringBill(RecurringBillModel bill) {
    _recurringBills.add(bill);
    StorageService.instance.saveRecurringBills(_recurringBills);
    _checkRecurringBillNotifications();
    notifyListeners();
  }

  void toggleRecurringBill(String billId) {
    int idx = _recurringBills.indexWhere((b) => b.id == billId);
    if (idx != -1) {
      _recurringBills[idx].isActive = !_recurringBills[idx].isActive;
      StorageService.instance.saveRecurringBills(_recurringBills);
      _checkRecurringBillNotifications();
      notifyListeners();
    }
  }

  void deleteRecurringBill(String billId) {
    _recurringBills.removeWhere((b) => b.id == billId);
    StorageService.instance.saveRecurringBills(_recurringBills);
    notifyListeners();
  }

  double get totalBalance => _wallets.fold(0.0, (sum, item) => sum + item.balance);
  double get totalIncome => _transactions.where((t) => (t.isIncome == true) && !t.isRealTransfer).fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpense => _transactions.where((t) => (t.isIncome != true) && !t.isRealTransfer).fold(0.0, (sum, t) => sum + t.amount);

  double get totalBudgetedLimit => _categoryBudgets.values.fold(0.0, (sum, v) => sum + v);

  int get financialHealthScore {
    if (totalIncome == 0 && totalExpense == 0) {
      return 0; // Fresh install / no transactions yet
    }

    if (totalIncome > 0) {
      final savings = totalIncome - totalExpense;
      final savingsRatio = savings / totalIncome;

      int points = 30; // base
      if (savingsRatio >= 0.3) {
        points += 40;
      } else if (savingsRatio >= 0.1) {
        points += 25;
      } else if (savingsRatio > 0) {
        points += 10;
      } else {
        points -= 15;
      }

      if (totalBalance > 0) points += 15;
      if (totalBudgetedLimit > 0 && totalExpense <= totalBudgetedLimit) {
        points += 14;
      }

      return points.clamp(35, 98);
    } else if (totalExpense > 0) {
      return 65;
    }
    return 0;
  }

  String get financialHealthTitle {
    final score = financialHealthScore;
    if (score == 0) return "Belum Teranalisis";
    if (score >= 80) return "Sangat Sehat";
    if (score >= 60) return "Cukup Baik";
    return "Perlu Perhatian";
  }

  Color get financialHealthColor {
    final score = financialHealthScore;
    if (score == 0) return AppTheme.textSecondary;
    if (score >= 80) return AppTheme.incomeGreen;
    if (score >= 60) return AppTheme.warningAmber;
    return AppTheme.expenseRed;
  }

  void toggleNotifications(bool enabled) {
    isNotificationEnabled = enabled;
    StorageService.instance.saveNotificationEnabled(enabled);
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    StorageService.instance.saveNotifications(_notifications);
    
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

  void transferBetweenWallets({
    required String fromWalletName,
    required String toWalletName,
    required double amount,
    String? note,
  }) {
    int fromIdx = _wallets.indexWhere((w) => w.name == fromWalletName);
    int toIdx = _wallets.indexWhere((w) => w.name == toWalletName);

    if (fromIdx == -1 || toIdx == -1 || amount <= 0) return;

    final fromW = _wallets[fromIdx];
    final toW = _wallets[toIdx];

    _wallets[fromIdx] = WalletItem(
      name: fromW.name,
      type: fromW.type,
      balance: fromW.balance - amount,
      accountNumber: fromW.accountNumber,
      colorHex: fromW.colorHex,
      iconData: fromW.iconData,
    );

    _wallets[toIdx] = WalletItem(
      name: toW.name,
      type: toW.type,
      balance: toW.balance + amount,
      accountNumber: toW.accountNumber,
      colorHex: toW.colorHex,
      iconData: toW.iconData,
    );

    final tx = TransactionModel(
      id: 'tx_trf_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer $fromWalletName ➔ $toWalletName',
      categoryName: 'Transfer Dana',
      walletName: fromWalletName,
      amount: amount,
      isIncome: false,
      isTransfer: true,
      icon: Icons.swap_horiz,
      iconColor: AppTheme.accentBlue,
      date: DateTime.now(),
      timeText: '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} WIB',
      note: (note != null && note.trim().isNotEmpty) ? note.trim() : 'Transfer dana dari $fromWalletName ke $toWalletName.',
    );

    _transactions.insert(0, tx);
    StorageService.instance.saveTransactions(_transactions);
    StorageService.instance.saveWallets(_wallets);

    if (isNotificationEnabled) {
      addNotification(NotificationItem(
        id: 'notif_trf_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transfer Dana Berhasil',
        message: 'Transfer ${CurrencyFormatter.format(amount)} dari $fromWalletName ke $toWalletName.',
        timestamp: DateTime.now(),
        icon: Icons.swap_horiz,
        iconColor: AppTheme.accentBlue,
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
    if (tx.isRealTransfer) {
      try {
        final rawStr = tx.title.replaceFirst('Transfer ', '');
        final parts = rawStr.split(' ➔ ');
        if (parts.length == 2) {
          final fromWalletName = parts[0].trim();
          final toWalletName = parts[1].trim();

          // Revert fromWallet (+ amount)
          int fromIdx = _wallets.indexWhere((w) => w.name == fromWalletName);
          if (fromIdx != -1) {
            final w = _wallets[fromIdx];
            _wallets[fromIdx] = WalletItem(
              name: w.name,
              type: w.type,
              balance: w.balance + tx.amount,
              accountNumber: w.accountNumber,
              colorHex: w.colorHex,
              iconData: w.iconData,
            );
          }

          // Revert toWallet (- amount)
          int toIdx = _wallets.indexWhere((w) => w.name == toWalletName);
          if (toIdx != -1) {
            final w = _wallets[toIdx];
            _wallets[toIdx] = WalletItem(
              name: w.name,
              type: w.type,
              balance: w.balance - tx.amount,
              accountNumber: w.accountNumber,
              colorHex: w.colorHex,
              iconData: w.iconData,
            );
          }
        }
      } catch (_) {}
    } else {
      int wIdx = _wallets.indexWhere((w) => w.name == tx.walletName);
      if (wIdx != -1) {
        final w = _wallets[wIdx];
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
    }

    _transactions.removeAt(targetIdx);
    StorageService.instance.saveTransactions(_transactions);
    StorageService.instance.saveWallets(_wallets);
    notifyListeners();
  }

  void restoreTransaction(TransactionModel tx, [int? originalIndex]) {
    if (_transactions.any((t) => t.id == tx.id)) return;

    if (originalIndex != null && originalIndex >= 0 && originalIndex <= _transactions.length) {
      _transactions.insert(originalIndex, tx);
    } else {
      _transactions.insert(0, tx);
    }

    if (tx.isRealTransfer) {
      try {
        final rawStr = tx.title.replaceFirst('Transfer ', '');
        final parts = rawStr.split(' ➔ ');
        if (parts.length == 2) {
          final fromWalletName = parts[0].trim();
          final toWalletName = parts[1].trim();

          int fromIdx = _wallets.indexWhere((w) => w.name == fromWalletName);
          if (fromIdx != -1) {
            final w = _wallets[fromIdx];
            _wallets[fromIdx] = WalletItem(name: w.name, type: w.type, balance: w.balance - tx.amount, accountNumber: w.accountNumber, colorHex: w.colorHex, iconData: w.iconData);
          }

          int toIdx = _wallets.indexWhere((w) => w.name == toWalletName);
          if (toIdx != -1) {
            final w = _wallets[toIdx];
            _wallets[toIdx] = WalletItem(name: w.name, type: w.type, balance: w.balance + tx.amount, accountNumber: w.accountNumber, colorHex: w.colorHex, iconData: w.iconData);
          }
        }
      } catch (_) {}
    } else {
      int wIdx = _wallets.indexWhere((w) => w.name == tx.walletName);
      if (wIdx != -1) {
        final w = _wallets[wIdx];
        final newBal = tx.isIncome ? (w.balance + tx.amount) : (w.balance - tx.amount);
        _wallets[wIdx] = WalletItem(
          name: w.name,
          type: w.type,
          balance: newBal,
          accountNumber: w.accountNumber,
          colorHex: w.colorHex,
          iconData: w.iconData,
        );
      }
    }

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

    if (wallet.balance > 0) {
      final initialTx = TransactionModel(
        id: 'tx_init_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Saldo Awal [${wallet.name}]',
        categoryName: 'Gaji & Pendapatan',
        walletName: wallet.name,
        amount: wallet.balance,
        isIncome: true,
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppTheme.incomeGreen,
        date: DateTime.now(),
        timeText: '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} WIB',
        note: 'Pemasukan otomatis saat membuat dompet ${wallet.name}.',
      );
      _transactions.insert(0, initialTx);
      StorageService.instance.saveTransactions(_transactions);
    }

    notifyListeners();
  }

  void removeAllData() {
    _transactions.clear();
    _wallets.clear();
    _categoryBudgets.clear();
    _notifications.clear();
    userName = 'Pengguna Dompetku';
    userEmail = 'Email belum diatur';
    StorageService.instance.saveTransactions(_transactions);
    StorageService.instance.saveWallets(_wallets);
    StorageService.instance.saveCategoryBudgets(_categoryBudgets);
    StorageService.instance.saveUserProfile(userName, userEmail);
    notifyListeners();
  }
}
