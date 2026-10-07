import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/credit_card.dart';
import '../models/monthly_bill.dart';
import 'card_chip.dart';
import 'card_network_logo.dart';

class CreditCardWidget extends StatefulWidget {
  final CreditCard card;
  final MonthlyBill bill;
  final int selectedYear;
  final int selectedMonth;
  final VoidCallback onEdit;
  final VoidCallback onTogglePaid;

  const CreditCardWidget({
    super.key,
    required this.card,
    required this.bill,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onEdit,
    required this.onTogglePaid,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _tiltResetController;

  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();

    // Continuous subtle holographic shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Tilt reset spring
    _tiltResetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _tiltResetController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _tiltX += details.delta.dx * 0.0012;
      _tiltY -= details.delta.dy * 0.0012;
      _tiltX = _tiltX.clamp(-0.2, 0.2);
      _tiltY = _tiltY.clamp(-0.2, 0.2);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final startX = _tiltX;
    final startY = _tiltY;

    _tiltResetController.reset();
    final animation = CurvedAnimation(
      parent: _tiltResetController,
      curve: Curves.easeOutBack,
    );

    animation.addListener(() {
      setState(() {
        _tiltX = startX * (1 - animation.value);
        _tiltY = startY * (1 - animation.value);
      });
    });

    _tiltResetController.forward();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }

  String _getDueDateStatus(DateTime dueDate) {
    if (widget.bill.isPaid) return 'PAID';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue by ${-difference}d';
    } else if (difference == 0) {
      return 'Due Today!';
    } else if (difference == 1) {
      return 'Due Tomorrow';
    } else {
      return 'In $difference days';
    }
  }

  Color _getDueDateStatusColor(DateTime dueDate) {
    if (widget.bill.isPaid) return const Color(0xFF10B981); // Emerald Green

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return const Color(0xFFEF4444); // Red Overdue
    } else if (difference <= 3) {
      return const Color(0xFFF59E0B); // Amber Warning
    } else {
      return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDate =
        widget.card.calculateDueDate(widget.selectedYear, widget.selectedMonth);
    final billDate =
        widget.card.calculateBillDate(widget.selectedYear, widget.selectedMonth);

    final dueFormat = DateFormat('d MMM');
    final dueString = dueFormat.format(dueDate);
    final billString = dueFormat.format(billDate);

    final statusText = _getDueDateStatus(dueDate);
    final statusColor = _getDueDateStatusColor(dueDate);
    final primaryColor = Color(widget.card.accentColor);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltY)
          ..rotateY(_tiltX);

        return GestureDetector(
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(minHeight: 228),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.card.gradientColors.map((c) => Color(c)).toList(),
                ),
                boxShadow: [
                  // Dynamic accent glow
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 22,
                    spreadRadius: -2,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.22),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Holographic Shimmer Sweep Light
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CardShimmerPainter(
                          progress: _shimmerController.value,
                          accentColor: primaryColor,
                        ),
                      ),
                    ),

                    // Card Inner Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Row: Bank name, Card title & NFC Contactless Wave
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.card.bank,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.card.name,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // NFC Contactless Wave Symbol
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.wifi_rounded,
                                  color: Colors.white.withOpacity(0.85),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Chip & Paid / Unpaid Status Toggle Pill
                          Row(
                            children: [
                              const CardChipWidget(),
                              const Spacer(),
                              // Paid / Unpaid Status Toggle Pill
                              InkWell(
                                onTap: widget.onTogglePaid,
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: widget.bill.isPaid
                                        ? const Color(0xFF10B981).withOpacity(0.25)
                                        : Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: widget.bill.isPaid
                                          ? const Color(0xFF10B981)
                                          : Colors.white24,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.bill.isPaid
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        color: widget.bill.isPaid
                                            ? const Color(0xFF10B981)
                                            : Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        widget.bill.isPaid ? 'PAID' : 'UNPAID',
                                        style: TextStyle(
                                          color: widget.bill.isPaid
                                              ? const Color(0xFF34D399)
                                              : Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Main Big Size Bill Amount & Edit Button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL BILL AMOUNT',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatCurrency(widget.bill.amount),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        decoration: widget.bill.isPaid
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit Button
                              FilledButton.tonalIcon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                ),
                                onPressed: widget.onEdit,
                                icon: const Icon(Icons.edit_rounded, size: 16),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Bottom Grid: Due Date, Bill Date, Card Number & Network Logo
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Due Date Column with Badge
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DUE DATE',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.55),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          dueString,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Bill Date Column
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BILL DATE',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.55),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      billString,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                // Masked Card Number & Network Logo
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '•••• ${widget.card.cardNumberLast4}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CardNetworkLogo(
                                      network: widget.card.network,
                                      height: 22,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardShimmerPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _CardShimmerPainter({
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double sweepWidth = size.width * 0.45;
    final double startX = (size.width + sweepWidth * 2) * progress - sweepWidth;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.08),
          accentColor.withOpacity(0.12),
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(
        Rect.fromLTWH(startX, -size.height * 0.5, sweepWidth, size.height * 2),
      )
      ..blendMode = BlendMode.screen;

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _CardShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
