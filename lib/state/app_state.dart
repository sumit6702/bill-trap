import 'package:flutter/material.dart';
import '../models/credit_card.dart';
import '../models/monthly_bill.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<CreditCard> _cards = [];
  List<MonthlyBill> _bills = [];
  bool _isLoading = true;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = const Color(0xFF6366F1); // Indigo

  List<CreditCard> get cards => List.unmodifiable(_cards);
  List<MonthlyBill> get bills => List.unmodifiable(_bills);
  bool get isLoading => _isLoading;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  AppState() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _storage.init();
    _cards = await _storage.loadCards();
    _bills = await _storage.loadBills();

    // If cards were empty, initialize defaults
    if (_cards.isEmpty) {
      _cards = CreditCard.defaultCards();
      await _storage.saveCards(_cards);
    }

    // Seed realistic sample amounts if bills are completely empty
    if (_bills.isEmpty) {
      _seedSampleBills();
      await _storage.saveBills(_bills);
    }

    // Load theme
    final modeStr = await _storage.loadThemeMode();
    _themeMode = switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final colorVal = await _storage.loadAccentColor();
    _accentColor = Color(colorVal);

    _isLoading = false;
    notifyListeners();
  }

  void _seedSampleBills() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;

    final sampleAmounts = {
      'axis_flipkart': 14850.0,
      'icici_amazon': 26400.0,
      'idfc_power': 7230.0,
      'icici_coral': 18950.0,
      'hdfc_millennia': 31200.0,
    };

    for (final card in _cards) {
      final amount = sampleAmounts[card.id] ?? 12500.0;
      _bills.add(MonthlyBill(
        id: MonthlyBill.generateId(card.id, y, m),
        cardId: card.id,
        year: y,
        month: m,
        amount: amount,
        isPaid: card.id == 'icici_coral', // Just one pre-marked paid for nice initial UI feel
      ));
    }
  }

  // Month Navigation
  void setSelectedMonth(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    notifyListeners();
  }

  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedYear += 1;
      _selectedMonth = 1;
    } else {
      _selectedMonth += 1;
    }
    notifyListeners();
  }

  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedYear -= 1;
      _selectedMonth = 12;
    } else {
      _selectedMonth -= 1;
    }
    notifyListeners();
  }

  // Bills for selected month
  MonthlyBill getBillForCard(String cardId) {
    try {
      return _bills.firstWhere(
        (b) =>
            b.cardId == cardId &&
            b.year == _selectedYear &&
            b.month == _selectedMonth,
      );
    } catch (_) {
      // Return default unpaid 0.0 bill if none exists yet
      return MonthlyBill(
        id: MonthlyBill.generateId(cardId, _selectedYear, _selectedMonth),
        cardId: cardId,
        year: _selectedYear,
        month: _selectedMonth,
        amount: 0.0,
        isPaid: false,
      );
    }
  }

  Future<void> updateBillAmount({
    required String cardId,
    required double amount,
    bool? isPaid,
    String? note,
  }) async {
    final billId = MonthlyBill.generateId(cardId, _selectedYear, _selectedMonth);
    final existingIndex = _bills.indexWhere((b) => b.id == billId);

    if (existingIndex >= 0) {
      final old = _bills[existingIndex];
      _bills[existingIndex] = old.copyWith(
        amount: amount,
        isPaid: isPaid ?? old.isPaid,
        note: note ?? old.note,
        paidDate: (isPaid == true && !old.isPaid) ? DateTime.now() : old.paidDate,
      );
    } else {
      _bills.add(MonthlyBill(
        id: billId,
        cardId: cardId,
        year: _selectedYear,
        month: _selectedMonth,
        amount: amount,
        isPaid: isPaid ?? false,
        note: note,
        paidDate: isPaid == true ? DateTime.now() : null,
      ));
    }

    notifyListeners();
    await _storage.saveBills(_bills);
  }

  Future<void> toggleBillPaid(String cardId) async {
    final currentBill = getBillForCard(cardId);
    final newPaid = !currentBill.isPaid;
    await updateBillAmount(
      cardId: cardId,
      amount: currentBill.amount,
      isPaid: newPaid,
      note: currentBill.note,
    );
  }

  // Card Management
  Future<void> updateCard(CreditCard updatedCard) async {
    final index = _cards.indexWhere((c) => c.id == updatedCard.id);
    if (index >= 0) {
      _cards[index] = updatedCard;
      notifyListeners();
      await _storage.saveCards(_cards);
    }
  }

  Future<void> addCard(CreditCard newCard) async {
    _cards.add(newCard);
    notifyListeners();
    await _storage.saveCards(_cards);
  }

  Future<void> deleteCard(String cardId) async {
    _cards.removeWhere((c) => c.id == cardId);
    _bills.removeWhere((b) => b.cardId == cardId);
    notifyListeners();
    await _storage.saveCards(_cards);
    await _storage.saveBills(_bills);
  }

  // Theme Management
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _storage.saveThemeMode(modeStr);
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    await _storage.saveAccentColor(color.value);
  }

  // Calculations for current selected month
  double get totalDueAmount {
    double total = 0.0;
    for (final card in _cards) {
      final bill = getBillForCard(card.id);
      total += bill.amount;
    }
    return total;
  }

  double get totalPaidAmount {
    double total = 0.0;
    for (final card in _cards) {
      final bill = getBillForCard(card.id);
      if (bill.isPaid) {
        total += bill.amount;
      }
    }
    return total;
  }

  double get totalPendingAmount {
    final diff = totalDueAmount - totalPaidAmount;
    return diff > 0 ? diff : 0.0;
  }

  int get paidCardsCount {
    int count = 0;
    for (final card in _cards) {
      final bill = getBillForCard(card.id);
      if (bill.isPaid) count++;
    }
    return count;
  }

  int get totalCardsCount => _cards.length;

  // Export / Import
  Future<String> exportBackup() async {
    return _storage.exportBackupData();
  }

  Future<({bool success, String message})> importBackup(String jsonStr) async {
    final result = await _storage.importBackupData(jsonStr);
    if (result.success) {
      await init();
    }
    return (success: result.success, message: result.message);
  }

  Future<void> resetToDefaults() async {
    await _storage.resetToDefaults();
    _cards = CreditCard.defaultCards();
    _bills = [];
    _seedSampleBills();
    await _storage.saveCards(_cards);
    await _storage.saveBills(_bills);
    _themeMode = ThemeMode.system;
    _accentColor = const Color(0xFF6366F1);
    notifyListeners();
  }
}
