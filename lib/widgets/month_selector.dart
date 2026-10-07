import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelectorWidget extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(int year, int month) onSelect;

  const MonthSelectorWidget({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final date = DateTime(selectedYear, selectedMonth, 1);
    final monthName = DateFormat('MMMM yyyy').format(date);

    final now = DateTime.now();
    final isCurrentMonth = now.year == selectedYear && now.month == selectedMonth;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E232A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Month button
          IconButton.filledTonal(
            tooltip: 'Previous Month',
            visualDensity: VisualDensity.compact,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),

          // Clickable Month & Year Pill
          InkWell(
            onTap: () => _showMonthPicker(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (isCurrentMonth) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Current',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Next Month button
          IconButton.filledTonal(
            tooltip: 'Next Month',
            visualDensity: VisualDensity.compact,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        int tempYear = selectedYear;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final months = [
              'Jan', 'Feb', 'Mar', 'Apr',
              'May', 'Jun', 'Jul', 'Aug',
              'Sep', 'Oct', 'Nov', 'Dec'
            ];

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => setModalState(() => tempYear--),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Text(
                        '$tempYear',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        onPressed: () => setModalState(() => tempYear++),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: 12,
                    itemBuilder: (ctx, index) {
                      final monthIndex = index + 1;
                      final isSelected = tempYear == selectedYear &&
                          monthIndex == selectedMonth;

                      return FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: isSelected
                              ? Theme.of(ctx).colorScheme.primary
                              : null,
                          foregroundColor: isSelected
                              ? Theme.of(ctx).colorScheme.onPrimary
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          onSelect(tempYear, monthIndex);
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          months[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Jump to Current Month button
                  OutlinedButton.icon(
                    onPressed: () {
                      final now = DateTime.now();
                      onSelect(now.year, now.month);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.today_rounded, size: 18),
                    label: const Text('Jump to Current Month'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
