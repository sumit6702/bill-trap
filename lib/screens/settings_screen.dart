import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/credit_card.dart';
import '../state/app_state.dart';
import 'edit_card_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({
    super.key,
    required this.appState,
  });

  static const List<({String name, Color color})> accentColorOptions = [
    (name: 'Indigo', color: Color(0xFF6366F1)),
    (name: 'Deep Purple', color: Color(0xFF7C3AED)),
    (name: 'Emerald Teal', color: Color(0xFF0D9488)),
    (name: 'Coral Crimson', color: Color(0xFFE11D48)),
    (name: 'Golden Amber', color: Color(0xFFD97706)),
    (name: 'Electric Cyan', color: Color(0xFF0284C7)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Section 1: Credit Cards Due & Bill Dates
              _buildSectionHeader(
                context,
                title: 'Card Due & Bill Dates',
                subtitle:
                    'Manage billing cycles and dates for each of your cards',
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(height: 8),

              // Cards list
              ...appState.cards.map((card) => _buildCardDateTile(context, card)),

              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCardScreen(
                        onSave: (newCard) => appState.addCard(newCard),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Add Another Card'),
              ),

              const SizedBox(height: 28),

              // Section 2: Material 3 Themes & Appearance
              _buildSectionHeader(
                context,
                title: 'Material 3 Theme Options',
                subtitle: 'Personalize appearance, dark mode, and accent colors',
                icon: Icons.palette_rounded,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THEME MODE',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_rounded),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_rounded),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_rounded),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {appState.themeMode},
                        onSelectionChanged: (val) {
                          appState.setThemeMode(val.first);
                        },
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'PRIMARY ACCENT COLOR',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: accentColorOptions.map((opt) {
                          final isSelected =
                              appState.accentColor.value == opt.color.value;
                          return ChoiceChip(
                            avatar: CircleAvatar(
                              backgroundColor: opt.color,
                              radius: 8,
                            ),
                            label: Text(opt.name),
                            selected: isSelected,
                            onSelected: (_) {
                              appState.setAccentColor(opt.color);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Section 3: Data Backup & Restore (Export & Import)
              _buildSectionHeader(
                context,
                title: 'Data Backup & Restore',
                subtitle: 'Export or import your cards and monthly bills as JSON',
                icon: Icons.sync_rounded,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _showExportDialog(context),
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Export JSON'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _showImportDialog(context),
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Import JSON'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 4: Danger Zone / Reset Defaults
              Card(
                elevation: 0,
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.error.withOpacity(0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reset to Default Cards',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Restore initial 5 credit cards & sample data',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        onPressed: () => _confirmReset(context),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardDateTile(BuildContext context, CreditCard card) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: card.gradientColors.map((c) => Color(c)).toList(),
            ),
          ),
          child: Center(
            child: Text(
              card.cardNumberLast4,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        title: Text(
          card.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Due: ${card.dueDay}th',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Bill: ${card.billDay}th',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Edit Dates button
            IconButton(
              tooltip: 'Change Due & Bill Date',
              icon: const Icon(Icons.date_range_rounded, size: 20),
              onPressed: () => _showQuickDateDialog(context, card),
            ),
            // Edit Card Details
            IconButton(
              tooltip: 'Edit Full Card',
              icon: const Icon(Icons.edit_note_rounded, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCardScreen(
                      initialCard: card,
                      onSave: (updated) => appState.updateCard(updated),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickDateDialog(BuildContext context, CreditCard card) {
    int tempDue = card.dueDay;
    int tempBill = card.billDay;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Change Dates for ${card.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: tempDue,
                    decoration: const InputDecoration(
                      labelText: 'Due Date (of each month)',
                      filled: true,
                    ),
                    items: List.generate(31, (i) => i + 1)
                        .map((day) => DropdownMenuItem(
                              value: day,
                              child: Text('${day}th of month'),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => tempDue = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    value: tempBill,
                    decoration: const InputDecoration(
                      labelText: 'Bill Date (statement date)',
                      filled: true,
                    ),
                    items: List.generate(31, (i) => i + 1)
                        .map((day) => DropdownMenuItem(
                              value: day,
                              child: Text('${day}th of month'),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => tempBill = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final updated =
                        card.copyWith(dueDay: tempDue, billDay: tempBill);
                    appState.updateCard(updated);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Dates'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) async {
    final jsonStr = await appState.exportBackup();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.file_upload_outlined),
              SizedBox(width: 8),
              Text('Export Backup JSON'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Copy the JSON backup below to store or transfer your credit cards and bill history:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonStr,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Backup JSON copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy to Clipboard'),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.file_download_outlined),
              SizedBox(width: 8),
              Text('Import Backup JSON'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Paste your JSON backup data below to restore your cards and bills:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 8,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: '{\n  "cards": [...],\n  "bills": [...]\n}',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please paste JSON content')),
                  );
                  return;
                }

                final result = await appState.importBackup(text);
                if (ctx.mounted) Navigator.pop(ctx);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.success ? null : Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.restore_rounded, size: 16),
              label: const Text('Import & Restore'),
            ),
          ],
        );
      },
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset to Defaults?'),
          content: const Text(
            'This will restore the 5 default cards (Axis Flipkart, ICICI Amazon, IDFC Power, ICICI Coral, HDFC Millennia) with their specified Due Dates and Bill Dates.',
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
                appState.resetToDefaults();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset to 5 default cards completed!'),
                  ),
                );
              },
              child: const Text('Confirm Reset'),
            ),
          ],
        );
      },
    );
  }
}
