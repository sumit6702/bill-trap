import 'package:flutter/material.dart';
import '../models/credit_card.dart';
import '../models/monthly_bill.dart';

class EditBillDialog extends StatefulWidget {
  final CreditCard card;
  final MonthlyBill bill;
  final int selectedYear;
  final int selectedMonth;
  final Function(double amount, bool isPaid, String? note) onSave;
  final Function(int dueDay, int billDay)? onUpdateDates;

  const EditBillDialog({
    super.key,
    required this.card,
    required this.bill,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onSave,
    this.onUpdateDates,
  });

  @override
  State<EditBillDialog> createState() => _EditBillDialogState();
}

class _EditBillDialogState extends State<EditBillDialog> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late bool _isPaid;
  late int _dueDay;
  late int _billDay;
  bool _showDateSettings = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.bill.amount > 0 ? widget.bill.amount.toStringAsFixed(0) : '',
    );
    _noteController = TextEditingController(text: widget.bill.note ?? '');
    _isPaid = widget.bill.isPaid;
    _dueDay = widget.card.dueDay;
    _billDay = widget.card.billDay;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addAmount(double add) {
    final current = double.tryParse(_amountController.text) ?? 0.0;
    final total = current + add;
    _amountController.text = total.toStringAsFixed(0);
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    widget.onSave(
      amount,
      _isPaid,
      _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (_showDateSettings && widget.onUpdateDates != null) {
      widget.onUpdateDates!(_dueDay, _billDay);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card Header Info
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: widget.card.gradientColors
                          .map((c) => Color(c))
                          .toList(),
                    ),
                  ),
                  child: const Icon(Icons.credit_card_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.card.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.card.bank} •••• ${widget.card.cardNumberLast4}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bill Amount Input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Bill Amount',
                prefixText: '₹ ',
                prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Quick Add Preset Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildQuickChip('+₹500', 500),
                _buildQuickChip('+₹1,000', 1000),
                _buildQuickChip('+₹5,000', 5000),
                _buildQuickChip('+₹10,000', 10000),
                ActionChip(
                  label: const Text('Clear'),
                  onPressed: () => _amountController.clear(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Paid Status Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mark as Paid',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                _isPaid ? 'Bill marked as settled' : 'Bill is pending payment',
                style: TextStyle(
                  color: _isPaid ? const Color(0xFF10B981) : Colors.orange,
                  fontSize: 12,
                ),
              ),
              value: _isPaid,
              onChanged: (val) => setState(() => _isPaid = val),
            ),

            const Divider(),

            // Card Due Date & Bill Date Accordion
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: _showDateSettings,
                onExpansionChanged: (exp) =>
                    setState(() => _showDateSettings = exp),
                tilePadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range_rounded),
                title: const Text(
                  'Card Due & Bill Dates',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Due: ${_dueDay}th | Bill: ${_billDay}th of each month',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _dueDay,
                          decoration: InputDecoration(
                            labelText: 'Due Day',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: List.generate(31, (i) => i + 1)
                              .map((day) => DropdownMenuItem(
                                    value: day,
                                    child: Text('${day}th of month'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _dueDay = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _billDay,
                          decoration: InputDecoration(
                            labelText: 'Bill Day',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: List.generate(31, (i) => i + 1)
                              .map((day) => DropdownMenuItem(
                                    value: day,
                                    child: Text('${day}th of month'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _billDay = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Notes / Rewards (Optional)',
                hintText: 'e.g. 5% cashback on Flipkart...',
                prefixIcon: const Icon(Icons.note_alt_outlined),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Save Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, double add) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _addAmount(add),
    );
  }
}
