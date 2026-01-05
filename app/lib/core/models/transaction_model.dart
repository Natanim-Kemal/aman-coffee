class MoneyTransaction {
  final String id;
  final String workerId;
  final String workerName;
  final String type; // 'distribution', 'return', 'purchase'
  final double amount;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;
  final String createdBy; // user ID who created it

  MoneyTransaction({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.type,
    required this.amount,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    required this.createdBy,
  });

  /// Create MoneyTransaction from Firestore document
  factory MoneyTransaction.fromFirestore(Map<String, dynamic> data, String id) {
    return MoneyTransaction(
      id: id,
      workerId: data['workerId'] ?? '',
      workerName: data['workerName'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      notes: data['notes'],
      receiptUrl: data['receiptUrl'],
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  /// Convert MoneyTransaction to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'type': type,
      'amount': amount,
      'notes': notes,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
    };
  }

  /// Get display type
  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'distribution':
        return 'Money Distributed';
      case 'return':
        return 'Money Returned';
      case 'purchase':
        return 'Coffee Purchase';
      default:
        return type;
    }
  }

  /// Get icon for transaction type
  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'distribution':
        return '💰';
      case 'return':
        return '↩️';
      case 'purchase':
        return '☕';
      default:
        return '📝';
    }
  }

  /// Check if transaction increases balance
  bool get increasesBalance {
    return type.toLowerCase() == 'distribution';
  }

  /// Check if transaction decreases balance
  bool get decreasesBalance {
    return type.toLowerCase() == 'return' || type.toLowerCase() == 'purchase';
  }
}
