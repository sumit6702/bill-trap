import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bill_tracker_app/models/credit_card.dart';
import 'package:bill_tracker_app/state/app_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CreditCard Model Tests', () {
    test('Default 5 cards match user requirements', () {
      final defaults = CreditCard.defaultCards();
      expect(defaults.length, 5);

      final flipkart = defaults.firstWhere((c) => c.id == 'axis_flipkart');
      expect(flipkart.name, 'Axis Flipkart Card');
      expect(flipkart.dueDay, 3);
      expect(flipkart.billDay, 13);

      final amazon = defaults.firstWhere((c) => c.id == 'icici_amazon');
      expect(amazon.name, 'ICICI Amazon Card');
      expect(amazon.dueDay, 30);
      expect(amazon.billDay, 12);

      final power = defaults.firstWhere((c) => c.id == 'idfc_power');
      expect(power.name, 'IDFC Power Card');
      expect(power.dueDay, 4);
      expect(power.billDay, 19);

      final coral = defaults.firstWhere((c) => c.id == 'icici_coral');
      expect(coral.name, 'ICICI Coral Card');
      expect(coral.dueDay, 20);
      expect(coral.billDay, 2);

      final slice = defaults.firstWhere((c) => c.id == 'slice_card');
      expect(slice.name, 'Slice Card');
      expect(slice.dueDay, 5);
      expect(slice.billDay, 21);

      // Verify HDFC Millennia is not in defaults
      expect(defaults.any((c) => c.id == 'hdfc_millennia'), isFalse);
    });

    test('Date calculation handles leap years and shorter months correctly', () {
      final card = const CreditCard(
        id: 'test',
        name: 'Test Card',
        bank: 'TEST BANK',
        dueDay: 31,
        billDay: 30,
        gradientColors: [0xFF000000, 0xFFFFFFFF],
        accentColor: 0xFFFFFFFF,
      );

      // In February (non leap year 2025 has 28 days)
      final dueFeb2025 = card.calculateDueDate(2025, 2);
      expect(dueFeb2025.day, 28);

      // In February (leap year 2024 has 29 days)
      final dueFeb2024 = card.calculateDueDate(2024, 2);
      expect(dueFeb2024.day, 29);

      // In April (has 30 days)
      final dueApr = card.calculateDueDate(2026, 4);
      expect(dueApr.day, 30);
    });

    test('JSON serialization round-trip works seamlessly', () {
      final card = CreditCard.defaultCards().first;
      final json = card.toJson();
      final revived = CreditCard.fromJson(json);

      expect(revived.id, card.id);
      expect(revived.name, card.name);
      expect(revived.dueDay, card.dueDay);
      expect(revived.billDay, card.billDay);
      expect(revived.network, card.network);
    });
  });

  group('AppState Business Logic Tests', () {
    test('Calculates total due, total paid, and pending accurately', () async {
      final state = AppState();
      await state.init();

      expect(state.cards.length, 5);

      final initialDue = state.totalDueAmount;
      expect(initialDue, greaterThan(0));

      // Mark all cards paid
      for (final card in state.cards) {
        final bill = state.getBillForCard(card.id);
        if (!bill.isPaid) {
          await state.toggleBillPaid(card.id);
        }
      }

      expect(state.totalPendingAmount, 0.0);
      expect(state.paidCardsCount, 5);
      expect(state.totalPaidAmount, state.totalDueAmount);
    });

    test('Remove card option deletes card and its billing data', () async {
      final state = AppState();
      await state.init();

      expect(state.cards.length, 5);
      await state.deleteCard('slice_card');
      expect(state.cards.length, 4);
      expect(state.cards.any((c) => c.id == 'slice_card'), isFalse);
    });

    test('Export and import backup restores data cleanly', () async {
      final state = AppState();
      await state.init();

      final exportedJson = await state.exportBackup();
      expect(exportedJson.contains('BillTrackerApp'), isTrue);

      final decoded = jsonDecode(exportedJson);
      expect(decoded['cards'], isA<List>());
      expect(decoded['bills'], isA<List>());

      final importResult = await state.importBackup(exportedJson);
      expect(importResult.success, isTrue);
    });
  });
}
