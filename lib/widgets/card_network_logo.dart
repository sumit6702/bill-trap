import 'package:flutter/material.dart';
import '../models/credit_card.dart';

class CardNetworkLogo extends StatelessWidget {
  final CardNetwork network;
  final double height;

  const CardNetworkLogo({
    super.key,
    required this.network,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    switch (network) {
      case CardNetwork.mastercard:
        return _buildMastercard();
      case CardNetwork.visa:
        return _buildVisa();
      case CardNetwork.rupay:
        return _buildRuPay();
      case CardNetwork.amex:
        return _buildAmex();
    }
  }

  Widget _buildMastercard() {
    return SizedBox(
      height: height,
      width: height * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: height,
              height: height,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withOpacity(0.92),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: height * 0.75,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildRuPay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ru',
            style: TextStyle(
              color: const Color(0xFF00A859), // Indian green
              fontSize: height * 0.65,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'Pay',
            style: TextStyle(
              color: const Color(0xFFF26522), // Saffron orange
              fontSize: height * 0.65,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.flash_on_rounded,
            color: Color(0xFF00A859),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildAmex() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF006FCF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'AMEX',
        style: TextStyle(
          color: Colors.white,
          fontSize: height * 0.55,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
