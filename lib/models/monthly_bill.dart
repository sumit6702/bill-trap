class MonthlyBill {
  final String id;
  final String cardId;
  final int year;
  final int month;
  final double amount;
  final bool isPaid;
  final DateTime? paidDate;
  final String? note;
  final double? minDue;

  const MonthlyBill({
    required this.id,
    required this.cardId,
    required this.year,
    required this.month,
    required this.amount,
    this.isPaid = false,
    this.paidDate,
    this.note,
    this.minDue,
  });

  MonthlyBill copyWith({
    String? id,
    String? cardId,
    int? year,
    int? month,
    double? amount,
    bool? isPaid,
    DateTime? paidDate,
    String? note,
    double? minDue,
  }) {
    return MonthlyBill(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      year: year ?? this.year,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      note: note ?? this.note,
      minDue: minDue ?? this.minDue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'year': year,
      'month': month,
      'amount': amount,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'note': note,
      'minDue': minDue,
    };
  }

  factory MonthlyBill.fromJson(Map<String, dynamic> json) {
    return MonthlyBill(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool? ?? false,
      paidDate: json['paidDate'] != null
          ? DateTime.tryParse(json['paidDate'] as String)
          : null,
      note: json['note'] as String?,
      minDue: (json['minDue'] as num?)?.toDouble(),
    );
  }

  static String generateId(String cardId, int year, int month) {
    return '${cardId}_${year}_$month';
  }
}
