enum CardNetwork {
  visa,
  mastercard,
  rupay,
  amex,
}

class CreditCard {
  final String id;
  final String name;
  final String bank;
  final String cardSubtitle;
  final String cardNumberLast4;
  final String cardHolder;
  final int dueDay; // e.g. 3 for 3rd of month
  final int billDay; // e.g. 13 for 13th of month
  final CardNetwork network;
  final List<int> gradientColors; // 0xAARRGGBB hex values
  final int accentColor;

  const CreditCard({
    required this.id,
    required this.name,
    required this.bank,
    this.cardSubtitle = 'Credit Card',
    this.cardNumberLast4 = '4820',
    this.cardHolder = 'CARD HOLDER',
    required this.dueDay,
    required this.billDay,
    this.network = CardNetwork.mastercard,
    required this.gradientColors,
    required this.accentColor,
  });

  CreditCard copyWith({
    String? id,
    String? name,
    String? bank,
    String? cardSubtitle,
    String? cardNumberLast4,
    String? cardHolder,
    int? dueDay,
    int? billDay,
    CardNetwork? network,
    List<int>? gradientColors,
    int? accentColor,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      bank: bank ?? this.bank,
      cardSubtitle: cardSubtitle ?? this.cardSubtitle,
      cardNumberLast4: cardNumberLast4 ?? this.cardNumberLast4,
      cardHolder: cardHolder ?? this.cardHolder,
      dueDay: dueDay ?? this.dueDay,
      billDay: billDay ?? this.billDay,
      network: network ?? this.network,
      gradientColors: gradientColors ?? this.gradientColors,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bank': bank,
      'cardSubtitle': cardSubtitle,
      'cardNumberLast4': cardNumberLast4,
      'cardHolder': cardHolder,
      'dueDay': dueDay,
      'billDay': billDay,
      'network': network.name,
      'gradientColors': gradientColors,
      'accentColor': accentColor,
    };
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] as String,
      name: json['name'] as String,
      bank: json['bank'] as String,
      cardSubtitle: json['cardSubtitle'] as String? ?? 'Credit Card',
      cardNumberLast4: json['cardNumberLast4'] as String? ?? '4820',
      cardHolder: json['cardHolder'] as String? ?? 'CARD HOLDER',
      dueDay: (json['dueDay'] as num).toInt(),
      billDay: (json['billDay'] as num).toInt(),
      network: CardNetwork.values.firstWhere(
        (e) => e.name == json['network'],
        orElse: () => CardNetwork.mastercard,
      ),
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0xFF1F1C2C, 0xFF928DAB],
      accentColor: (json['accentColor'] as num?)?.toInt() ?? 0xFF00C9FF,
    );
  }

  /// Calculates actual Due Date for a given month and year
  DateTime calculateDueDate(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final clampedDay = dueDay > daysInMonth ? daysInMonth : dueDay;
    return DateTime(year, month, clampedDay);
  }

  /// Calculates actual Bill Date for a given month and year
  DateTime calculateBillDate(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final clampedDay = billDay > daysInMonth ? daysInMonth : billDay;
    return DateTime(year, month, clampedDay);
  }

  /// Default 5 Cards initialized according to user specifications:
  /// 1. Axis Flipkart Card: Due Date - 3rd, Bill Date: 13th
  /// 2. ICICI Amazon Card: Due Date - 30th, Bill Date: 12th
  /// 3. IDFC Power Card: Due Date - 4th, Bill Date: 19th
  /// 4. ICICI Coral Card: Due Date - 20th, Bill Date: 02nd
  /// 5. HDFC Millennia Card (5th Card): Due Date - 15th, Bill Date: 25th
  static List<CreditCard> defaultCards() {
    return [
      const CreditCard(
        id: 'axis_flipkart',
        name: 'Axis Flipkart Card',
        bank: 'AXIS BANK',
        cardSubtitle: 'Flipkart Cashback',
        cardNumberLast4: '7104',
        cardHolder: 'FLIPKART VIP',
        dueDay: 3,
        billDay: 13,
        network: CardNetwork.mastercard,
        gradientColors: [0xFF7E0E2B, 0xFF2A0845, 0xFF141E30],
        accentColor: 0xFFFF8008,
      ),
      const CreditCard(
        id: 'icici_amazon',
        name: 'ICICI Amazon Card',
        bank: 'ICICI BANK',
        cardSubtitle: 'Amazon Pay Rewards',
        cardNumberLast4: '3829',
        cardHolder: 'PRIME MEMBER',
        dueDay: 30,
        billDay: 12,
        network: CardNetwork.visa,
        gradientColors: [0xFF1F2937, 0xFF111827, 0xFFE65100],
        accentColor: 0xFFFF9900,
      ),
      const CreditCard(
        id: 'idfc_power',
        name: 'IDFC Power Card',
        bank: 'IDFC FIRST',
        cardSubtitle: 'HPCL Power Plus',
        cardNumberLast4: '5561',
        cardHolder: 'POWER SELECT',
        dueDay: 4,
        billDay: 19,
        network: CardNetwork.rupay,
        gradientColors: [0xFF8B0000, 0xFF4A0000, 0xFF1A1A1A],
        accentColor: 0xFFFFB300,
      ),
      const CreditCard(
        id: 'icici_coral',
        name: 'ICICI Coral Card',
        bank: 'ICICI BANK',
        cardSubtitle: 'Coral Gemstone Tier',
        cardNumberLast4: '9012',
        cardHolder: 'CORAL PRIVILEGE',
        dueDay: 20,
        billDay: 2,
        network: CardNetwork.visa,
        gradientColors: [0xFFE65C40, 0xFF870000, 0xFF1E272C],
        accentColor: 0xFFFF6F61,
      ),
      const CreditCard(
        id: 'hdfc_millennia',
        name: 'HDFC Millennia Card',
        bank: 'HDFC BANK',
        cardSubtitle: 'Cashback & Rewards',
        cardNumberLast4: '6453',
        cardHolder: 'MILLENNIA ELITE',
        dueDay: 15,
        billDay: 25,
        network: CardNetwork.visa,
        gradientColors: [0xFF0B486B, 0xFF003056, 0xFF1F1C2C],
        accentColor: 0xFF00D2FF,
      ),
      const CreditCard(
        id: 'slice_card',
        name: 'Slice Card',
        bank: 'SLICE',
        cardSubtitle: 'Slice Super Card',
        cardNumberLast4: '2905',
        cardHolder: 'SLICE MEMBER',
        dueDay: 5,
        billDay: 21,
        network: CardNetwork.visa,
        gradientColors: [0xFF6A11CB, 0xFF2575FC, 0xFF1B003A],
        accentColor: 0xFFB02AEC,
      ),
    ];
  }
}
