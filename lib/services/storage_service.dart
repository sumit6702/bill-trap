import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/credit_card.dart';
import '../models/monthly_bill.dart';

class StorageService {
  static const String _keyCards = 'bt_cards';
  static const String _keyBills = 'bt_bills';
  static const String _keyThemeMode = 'bt_theme_mode';
  static const String _keyAccentColor = 'bt_accent_color';

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // In environments where SharedPreferences isn't yet ready, will fallback gracefully
    }
  }

  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (_) {
        return null;
      }
    }
    return _prefs;
  }

  // Cards
  Future<List<CreditCard>> loadCards() async {
    final prefs = await _getPrefs();
    if (prefs == null) return CreditCard.defaultCards();

    final data = prefs.getString(_keyCards);
    if (data == null || data.isEmpty) {
      final defaults = CreditCard.defaultCards();
      await saveCards(defaults);
      return defaults;
    }

    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((item) => CreditCard.fromJson(item)).toList();
    } catch (e) {
      return CreditCard.defaultCards();
    }
  }

  Future<bool> saveCards(List<CreditCard> cards) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    final jsonList = cards.map((c) => c.toJson()).toList();
    return prefs.setString(_keyCards, jsonEncode(jsonList));
  }

  // Monthly Bills
  Future<List<MonthlyBill>> loadBills() async {
    final prefs = await _getPrefs();
    if (prefs == null) return [];

    final data = prefs.getString(_keyBills);
    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((item) => MonthlyBill.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveBills(List<MonthlyBill> bills) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    final jsonList = bills.map((b) => b.toJson()).toList();
    return prefs.setString(_keyBills, jsonEncode(jsonList));
  }

  // Theme Mode
  Future<String> loadThemeMode() async {
    final prefs = await _getPrefs();
    return prefs?.getString(_keyThemeMode) ?? 'system';
  }

  Future<bool> saveThemeMode(String mode) async {
    final prefs = await _getPrefs();
    return prefs?.setString(_keyThemeMode, mode) ?? false;
  }

  // Accent Color
  Future<int> loadAccentColor() async {
    final prefs = await _getPrefs();
    return prefs?.getInt(_keyAccentColor) ?? 0xFF6366F1; // Default Indigo
  }

  Future<bool> saveAccentColor(int colorValue) async {
    final prefs = await _getPrefs();
    return prefs?.setInt(_keyAccentColor, colorValue) ?? false;
  }

  // Export Data to JSON String
  Future<String> exportBackupData() async {
    final cards = await loadCards();
    final bills = await loadBills();
    final themeMode = await loadThemeMode();
    final accentColor = await loadAccentColor();

    final backup = {
      'app': 'BillTrackerApp',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'themeMode': themeMode,
      'accentColor': accentColor,
      'cards': cards.map((c) => c.toJson()).toList(),
      'bills': bills.map((b) => b.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  // Import Data from JSON String
  Future<({bool success, String message, int cardsCount, int billsCount})>
      importBackupData(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return (
          success: false,
          message: 'Invalid backup format. Root must be a JSON object.',
          cardsCount: 0,
          billsCount: 0
        );
      }

      final cardsRaw = decoded['cards'] as List<dynamic>?;
      final billsRaw = decoded['bills'] as List<dynamic>?;

      if (cardsRaw == null) {
        return (
          success: false,
          message: 'Backup missing "cards" array.',
          cardsCount: 0,
          billsCount: 0
        );
      }

      final List<CreditCard> parsedCards = [];
      for (final item in cardsRaw) {
        parsedCards.add(CreditCard.fromJson(item as Map<String, dynamic>));
      }

      final List<MonthlyBill> parsedBills = [];
      if (billsRaw != null) {
        for (final item in billsRaw) {
          parsedBills.add(MonthlyBill.fromJson(item as Map<String, dynamic>));
        }
      }

      await saveCards(parsedCards);
      await saveBills(parsedBills);

      if (decoded['themeMode'] is String) {
        await saveThemeMode(decoded['themeMode'] as String);
      }
      if (decoded['accentColor'] is num) {
        await saveAccentColor((decoded['accentColor'] as num).toInt());
      }

      return (
        success: true,
        message: 'Successfully imported ${parsedCards.length} cards and ${parsedBills.length} monthly bill records!',
        cardsCount: parsedCards.length,
        billsCount: parsedBills.length,
      );
    } catch (e) {
      return (
        success: false,
        message: 'Failed to parse JSON backup: $e',
        cardsCount: 0,
        billsCount: 0
      );
    }
  }

  // Reset to Defaults
  Future<void> resetToDefaults() async {
    final prefs = await _getPrefs();
    if (prefs == null) return;
    await prefs.remove(_keyCards);
    await prefs.remove(_keyBills);
    await prefs.remove(_keyThemeMode);
    await prefs.remove(_keyAccentColor);
  }
}
