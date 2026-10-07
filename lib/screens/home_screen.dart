import 'package:flutter/material.dart';
import '../models/credit_card.dart';
import '../models/monthly_bill.dart';
import '../state/app_state.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/edit_bill_dialog.dart';
import '../widgets/month_selector.dart';
import '../widgets/monthly_summary_card.dart';
import 'edit_card_screen.dart';
import 'settings_screen.dart';

enum CardFilter { all, unpaid, paid }

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({
    super.key,
    required this.appState,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CardFilter _filter = CardFilter.all;

  void _openEditBillSheet(BuildContext context, CreditCard card, MonthlyBill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return EditBillDialog(
          card: card,
          bill: bill,
          selectedYear: widget.appState.selectedYear,
          selectedMonth: widget.appState.selectedMonth,
          onSave: (amount, isPaid, note) {
            widget.appState.updateBillAmount(
              cardId: card.id,
              amount: amount,
              isPaid: isPaid,
              note: note,
            );
          },
          onUpdateDates: (dueDay, billDay) {
            widget.appState.updateCard(
              card.copyWith(dueDay: dueDay, billDay: billDay),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        if (widget.appState.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final cards = widget.appState.cards;
        final filteredCards = cards.where((card) {
          final bill = widget.appState.getBillForCard(card.id);
          switch (_filter) {
            case CardFilter.all:
              return true;
            case CardFilter.unpaid:
              return !bill.isPaid;
            case CardFilter.paid:
              return bill.isPaid;
          }
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Bill Tracker',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Settings & Dates',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(appState: widget.appState),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await widget.appState.init();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Month Navigation Selector
                MonthSelectorWidget(
                  selectedYear: widget.appState.selectedYear,
                  selectedMonth: widget.appState.selectedMonth,
                  onPrevious: widget.appState.previousMonth,
                  onNext: widget.appState.nextMonth,
                  onSelect: widget.appState.setSelectedMonth,
                ),

                const SizedBox(height: 16),

                // Monthly Total Due Summary Banner (Key Requirement)
                MonthlySummaryCard(
                  totalDue: widget.appState.totalDueAmount,
                  totalPaid: widget.appState.totalPaidAmount,
                  totalPending: widget.appState.totalPendingAmount,
                  paidCount: widget.appState.paidCardsCount,
                  totalCount: widget.appState.totalCardsCount,
                ),

                const SizedBox(height: 18),

                // Filter Chips Row
                Row(
                  children: [
                    Text(
                      'CREDIT CARDS (${filteredCards.length})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    SegmentedButton<CardFilter>(
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: CardFilter.all,
                          label: Text('All', style: TextStyle(fontSize: 12)),
                        ),
                        ButtonSegment(
                          value: CardFilter.unpaid,
                          label: Text('Due', style: TextStyle(fontSize: 12)),
                        ),
                        ButtonSegment(
                          value: CardFilter.paid,
                          label: Text('Paid', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (set) {
                        setState(() => _filter = set.first);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Cards List (Each Card is Box styled like Credit Card)
                if (filteredCards.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.credit_card_off_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _filter == CardFilter.unpaid
                              ? 'All bills are paid for this month! 🎉'
                              : 'No cards found matching filter',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredCards.map((card) {
                    final bill = widget.appState.getBillForCard(card.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: CreditCardWidget(
                        card: card,
                        bill: bill,
                        selectedYear: widget.appState.selectedYear,
                        selectedMonth: widget.appState.selectedMonth,
                        onEdit: () => _openEditBillSheet(context, card, bill),
                        onTogglePaid: () =>
                            widget.appState.toggleBillPaid(card.id),
                      ),
                    );
                  }),

                const SizedBox(height: 60),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCardScreen(
                    onSave: (newCard) => widget.appState.addCard(newCard),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Card'),
          ),
        );
      },
    );
  }
}
