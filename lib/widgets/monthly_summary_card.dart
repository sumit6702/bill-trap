import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlySummaryCard extends StatelessWidget {
  final double totalDue;
  final double totalPaid;
  final double totalPending;
  final int paidCount;
  final int totalCount;

  const MonthlySummaryCard({
    super.key,
    required this.totalDue,
    required this.totalPaid,
    required this.totalPending,
    required this.paidCount,
    required this.totalCount,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₹ ',
      locale: 'en_IN',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = totalDue > 0 ? (totalPaid / totalDue).clamp(0.0, 1.0) : 0.0;
    final allPaid = totalCount > 0 && paidCount == totalCount;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E2638),
                  const Color(0xFF141A29),
                ]
              : [
                  theme.colorScheme.primaryContainer.withOpacity(0.4),
                  theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : theme.colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Label & Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'TOTAL DUE THIS MONTH',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: allPaid
                        ? const Color(0xFF10B981).withOpacity(0.15)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: allPaid
                          ? const Color(0xFF10B981)
                          : theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        allPaid
                            ? Icons.check_circle_rounded
                            : Icons.credit_card_rounded,
                        size: 13,
                        color: allPaid
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        allPaid ? 'All Settled!' : '$paidCount of $totalCount Paid',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: allPaid
                              ? const Color(0xFF10B981)
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Big Size Total Due Amount
            Text(
              _formatCurrency(totalDue),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 14),

            // Animated Linear Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: isDark
                    ? Colors.white10
                    : theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  allPaid ? const Color(0xFF10B981) : theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Breakdown Stats: Paid so far vs Remaining Due
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF10B981).withOpacity(0.08)
                          : const Color(0xFF10B981).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paid Amount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(totalPaid),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFEF4444).withOpacity(0.08)
                          : const Color(0xFFEF4444).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remaining Due',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(totalPending),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: totalPending > 0
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
