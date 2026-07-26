import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';
import '../models/recurring_bill_model.dart';
import '../models/category_model.dart';
import '../screens/dompet_screen.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  static const String _keyTransactions = 'dompetku_transactions';
  static const String _keyWallets = 'dompetku_wallets';
  static const String _keyBudgets = 'dompetku_budgets';
  static const String _keyCategories = 'dompetku_categories';
  static const String _keyNotifEnabled = 'dompetku_notif_enabled';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Transactions
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    await init();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await _prefs?.setString(_keyTransactions, jsonEncode(jsonList));
  }

  Future<List<TransactionModel>> loadTransactions() async {
    await init();
    final jsonString = _prefs?.getString(_keyTransactions);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => TransactionModel.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // Wallets
  Future<void> saveWallets(List<WalletItem> wallets) async {
    await init();
    final jsonList = wallets.map((w) => w.toJson()).toList();
    await _prefs?.setString(_keyWallets, jsonEncode(jsonList));
  }

  Future<List<WalletItem>> loadWallets() async {
    await init();
    final jsonString = _prefs?.getString(_keyWallets);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => WalletItem.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // Category Budgets & Categories
  Future<void> saveCategoryBudgets(Map<String, double> budgets) async {
    await init();
    await _prefs?.setString(_keyBudgets, jsonEncode(budgets));
  }

  Future<Map<String, double>> loadCategoryBudgets() async {
    await init();
    final jsonString = _prefs?.getString(_keyBudgets);
    if (jsonString == null || jsonString.isEmpty) return {};

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    await init();
    final jsonList = categories.map((c) => c.toJson()).toList();
    await _prefs?.setString(_keyCategories, jsonEncode(jsonList));
  }

  Future<List<CategoryModel>> loadCategories() async {
    await init();
    final jsonString = _prefs?.getString(_keyCategories);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Settings
  Future<void> saveNotificationEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyNotifEnabled, enabled);
  }

  Future<bool> loadNotificationEnabled() async {
    await init();
    return _prefs?.getBool(_keyNotifEnabled) ?? true;
  }

  // User Profile
  static const String _keyUserName = 'dompetku_user_name';
  static const String _keyUserEmail = 'dompetku_user_email';

  Future<void> saveUserProfile(String name, String email) async {
    await init();
    await _prefs?.setString(_keyUserName, name);
    await _prefs?.setString(_keyUserEmail, email);
  }

  Future<Map<String, String>> loadUserProfile() async {
    await init();
    final name = _prefs?.getString(_keyUserName) ?? 'Pengguna Dompetku';
    final email = _prefs?.getString(_keyUserEmail) ?? 'Email belum diatur';
    return {'name': name, 'email': email};
  }

  // Savings Goals Storage
  static const String _keySavingsGoals = 'dompetku_savings_goals';

  Future<void> saveSavingsGoals(List<SavingsGoalModel> goals) async {
    await init();
    final List<String> encoded = goals.map((g) => jsonEncode(g.toJson())).toList();
    await _prefs?.setStringList(_keySavingsGoals, encoded);
  }

  Future<List<SavingsGoalModel>> loadSavingsGoals() async {
    await init();
    final List<String>? raw = _prefs?.getStringList(_keySavingsGoals);
    if (raw == null || raw.isEmpty) return [];
    try {
      return raw.map<SavingsGoalModel>((str) => SavingsGoalModel.fromJson(jsonDecode(str) as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Recurring Bills Storage
  static const String _keyRecurringBills = 'dompetku_recurring_bills';

  Future<void> saveRecurringBills(List<RecurringBillModel> bills) async {
    await init();
    final List<String> encoded = bills.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs?.setStringList(_keyRecurringBills, encoded);
  }

  Future<List<RecurringBillModel>> loadRecurringBills() async {
    await init();
    final List<String>? raw = _prefs?.getStringList(_keyRecurringBills);
    if (raw == null || raw.isEmpty) return [];
    try {
      return raw.map<RecurringBillModel>((str) => RecurringBillModel.fromJson(jsonDecode(str) as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Persistent Notified Keys Lock
  static const String _keyNotifiedKeys = 'dompetku_notified_keys';

  Future<void> saveNotifiedKeys(List<String> keys) async {
    await init();
    await _prefs?.setStringList(_keyNotifiedKeys, keys);
  }

  Future<List<String>> loadNotifiedKeys() async {
    await init();
    return _prefs?.getStringList(_keyNotifiedKeys) ?? [];
  }

  // Persistent Notifications Storage
  static const String _keyNotifications = 'dompetku_notifications_list';

  Future<void> saveNotifications(List<dynamic> items) async {
    await init();
    final List<String> encoded = items.map((i) => jsonEncode(i.toJson())).toList();
    await _prefs?.setStringList(_keyNotifications, encoded);
  }

  Future<List<dynamic>> loadNotificationsRaw() async {
    await init();
    final List<String>? raw = _prefs?.getStringList(_keyNotifications);
    if (raw == null || raw.isEmpty) return [];
    try {
      return raw.map((str) => jsonDecode(str) as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  // Backup & Restore JSON Data
  Future<String> generateBackupJson() async {
    await init();
    final txs = await loadTransactions();
    final wallets = await loadWallets();
    final budgets = await loadCategoryBudgets();
    final profile = await loadUserProfile();

    final Map<String, dynamic> backupData = {
      'app': 'Dompetku',
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'transactions': txs.map((t) => t.toJson()).toList(),
      'wallets': wallets.map((w) => w.toJson()).toList(),
      'categoryBudgets': budgets,
      'userProfile': profile,
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  Future<bool> restoreFromBackupJson(String jsonString) async {
    try {
      await init();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      if (!decoded.containsKey('transactions') || !decoded.containsKey('wallets')) {
        return false;
      }

      final List<dynamic> txsJson = decoded['transactions'] ?? [];
      final List<dynamic> walletsJson = decoded['wallets'] ?? [];
      final Map<String, dynamic> budgetsJson = decoded['categoryBudgets'] ?? {};
      final Map<String, dynamic> profileJson = decoded['userProfile'] ?? {};

      final List<TransactionModel> txs = txsJson.map((item) => TransactionModel.fromJson(item)).toList();
      final List<WalletItem> wallets = walletsJson.map((item) => WalletItem.fromJson(item)).toList();
      final Map<String, double> budgets = budgetsJson.map((key, value) => MapEntry(key, (value as num).toDouble()));

      await saveTransactions(txs);
      await saveWallets(wallets);
      await saveCategoryBudgets(budgets);
      if (profileJson.containsKey('name')) {
        await saveUserProfile(profileJson['name'] ?? '', profileJson['email'] ?? '');
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // First Launch Detection for Onboarding Tutorial
  static const String _keyFirstLaunchDone = 'dompetku_first_launch_done';

  Future<bool> isFirstLaunch() async {
    await init();
    return !(_prefs?.getBool(_keyFirstLaunchDone) ?? false);
  }

  Future<void> saveFirstLaunchDone() async {
    await init();
    await _prefs?.setBool(_keyFirstLaunchDone, true);
  }
}
