import 'package:flutter/material.dart';
import '../models/credit_card.dart';
import '../models/monthly_bill.dart';
import '../widgets/credit_card_widget.dart';

class EditCardScreen extends StatefulWidget {
  final CreditCard? initialCard;
  final Function(CreditCard card) onSave;
  final VoidCallback? onDelete;

  const EditCardScreen({
    super.key,
    this.initialCard,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bankController;
  late TextEditingController _subtitleController;
  late TextEditingController _last4Controller;
  late TextEditingController _cardHolderController;

  late int _dueDay;
  late int _billDay;
  late CardNetwork _network;
  late int _selectedColorPresetIndex;

  final List<({String name, List<int> gradient, int accent})> _colorPresets = [
    (
      name: 'Axis Crimson & Navy',
      gradient: [0xFF7E0E2B, 0xFF2A0845, 0xFF141E30],
      accent: 0xFFFF8008,
    ),
    (
      name: 'Amazon Charcoal & Orange',
      gradient: [0xFF1F2937, 0xFF111827, 0xFFE65100],
      accent: 0xFFFF9900,
    ),
    (
      name: 'IDFC Ruby & Gold',
      gradient: [0xFF8B0000, 0xFF4A0000, 0xFF1A1A1A],
      accent: 0xFFFFB300,
    ),
    (
      name: 'Coral Gemstone Cyan',
      gradient: [0xFFE65C40, 0xFF870000, 0xFF1E272C],
      accent: 0xFFFF6F61,
    ),
    (
      name: 'Millennia Deep Ocean',
      gradient: [0xFF0B486B, 0xFF003056, 0xFF1F1C2C],
      accent: 0xFF00D2FF,
    ),
    (
      name: 'Royal Midnight Gold',
      gradient: [0xFF141E30, 0xFF243B55, 0xFFB8860B],
      accent: 0xFFFFD700,
    ),
    (
      name: 'Cyberpunk Violet',
      gradient: [0xFF4A00E0, 0xFF8E2DE2, 0xFF1A0826],
      accent: 0xFFE040FB,
    ),
    (
      name: 'Emerald Forest Wealth',
      gradient: [0xFF0575E6, 0xFF00F260, 0xFF0B301A],
      accent: 0xFF00E676,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final card = widget.initialCard;
    _nameController =
        TextEditingController(text: card?.name ?? 'Axis Flipkart Card');
    _bankController = TextEditingController(text: card?.bank ?? 'AXIS BANK');
    _subtitleController =
        TextEditingController(text: card?.cardSubtitle ?? 'Cashback Card');
    _last4Controller =
        TextEditingController(text: card?.cardNumberLast4 ?? '7104');
    _cardHolderController =
        TextEditingController(text: card?.cardHolder ?? 'CARD HOLDER');

    _dueDay = card?.dueDay ?? 3;
    _billDay = card?.billDay ?? 13;
    _network = card?.network ?? CardNetwork.mastercard;

    _selectedColorPresetIndex = 0;
    if (card != null) {
      for (int i = 0; i < _colorPresets.length; i++) {
        if (_colorPresets[i].accent == card.accentColor) {
          _selectedColorPresetIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankController.dispose();
    _subtitleController.dispose();
    _last4Controller.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  CreditCard _buildPreviewCard() {
    final preset = _colorPresets[_selectedColorPresetIndex];
    return CreditCard(
      id: widget.initialCard?.id ??
          'card_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim().isEmpty
          ? 'Card Name'
          : _nameController.text.trim(),
      bank: _bankController.text.trim().isEmpty
          ? 'BANK'
          : _bankController.text.trim().toUpperCase(),
      cardSubtitle: _subtitleController.text.trim(),
      cardNumberLast4: _last4Controller.text.trim().isEmpty
          ? '0000'
          : _last4Controller.text.trim(),
      cardHolder: _cardHolderController.text.trim().isEmpty
          ? 'CARD HOLDER'
          : _cardHolderController.text.trim().toUpperCase(),
      dueDay: _dueDay,
      billDay: _billDay,
      network: _network,
      gradientColors: preset.gradient,
      accentColor: preset.accent,
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a card name')),
      );
      return;
    }

    widget.onSave(_buildPreviewCard());
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${_nameController.text}?'),
        content: const Text(
          'Are you sure you want to remove this card and all its billing history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call();
              Navigator.pop(context);
            },
            child: const Text('Remove Card'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewCard = _buildPreviewCard();
    final dummyBill = MonthlyBill(
      id: 'preview',
      cardId: previewCard.id,
      year: DateTime.now().year,
      month: DateTime.now().month,
      amount: 25000.0,
      isPaid: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialCard == null ? 'Add Credit Card' : 'Edit Card Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              tooltip: 'Remove Card',
              icon: Icon(Icons.delete_outline_rounded,
                  color: theme.colorScheme.error),
              onPressed: () => _confirmDelete(context),
            ),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live Interactive Card Preview
            Text(
              'LIVE CARD PREVIEW',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            CreditCardWidget(
              card: previewCard,
              bill: dummyBill,
              selectedYear: DateTime.now().year,
              selectedMonth: DateTime.now().month,
              onEdit: () {},
              onTogglePaid: () {},
            ),

            const SizedBox(height: 24),

            // Card Dates Section (Key Requirement)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Monthly Billing Schedule',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Due Date Picker
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _dueDay,
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            helperText: 'Day of each month',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(width: 14),
                      // Bill Date Picker
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _billDay,
                          decoration: InputDecoration(
                            labelText: 'Bill Date',
                            helperText: 'Statement day',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card Identity Fields
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Card Name',
                hintText: 'e.g. Axis Flipkart Card',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _bankController,
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      hintText: 'e.g. AXIS BANK',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _last4Controller,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Last 4 Digits',
                      hintText: '7104',
                      counterText: '',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: 'Card Subtitle / Category',
                hintText: 'e.g. Flipkart Cashback, Prime Rewards',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'e.g. OWLIS',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            // Card Network
            Text(
              'CARD NETWORK',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<CardNetwork>(
              segments: const [
                ButtonSegment(
                  value: CardNetwork.mastercard,
                  label: Text('Mastercard'),
                ),
                ButtonSegment(
                  value: CardNetwork.visa,
                  label: Text('VISA'),
                ),
                ButtonSegment(
                  value: CardNetwork.rupay,
                  label: Text('RuPay'),
                ),
                ButtonSegment(
                  value: CardNetwork.amex,
                  label: Text('Amex'),
                ),
              ],
              selected: {_network},
              onSelectionChanged: (val) {
                setState(() => _network = val.first);
              },
            ),

            const SizedBox(height: 24),

            // Card Color Preset
            Text(
              'CARD COLOR & THEME',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colorPresets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (ctx, index) {
                  final preset = _colorPresets[index];
                  final isSelected = _selectedColorPresetIndex == index;

                  return InkWell(
                    onTap: () =>
                        setState(() => _selectedColorPresetIndex = index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: preset.gradient.map((c) => Color(c)).toList(),
                        ),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(preset.accent).withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(Icons.check_rounded,
                                  color: Colors.white, size: 20),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _save,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Save Card Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.onDelete != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(
                    color: theme.colorScheme.error.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text(
                  'Remove This Card',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
