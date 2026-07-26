import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../screens/dompet_screen.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  static const String _keyTransactions = 'dompetku_transactions';
  static const String _keyWallets = 'dompetku_wallets';
  static const String _keyBudgets = 'dompetku_budgets';
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

  // Category Budgets
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

  // Settings
  Future<void> saveNotificationEnabled(bool enabled) async {
    await init();
    await _prefs?.setBool(_keyNotifEnabled, enabled);
  }

  Future<bool> loadNotificationEnabled() async {
    await init();
    return _prefs?.getBool(_keyNotifEnabled) ?? true;
  }
}
