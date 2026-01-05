class Worker {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role; // 'Senior Tailor', 'Junior Tailor', etc.
  final int yearsOfExperience;
  final String status; // 'active', 'busy', 'offline'
  final double performanceRating; // 0-100
  final String? photoUrl;
  final double currentBalance; // money currently held
  final double totalDistributed; // lifetime total
  final double totalReturned; // lifetime total
  final double totalCoffeePurchased; // lifetime total
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isActive;

  Worker({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.yearsOfExperience = 0,
    this.status = 'active',
    this.performanceRating = 0.0,
    this.photoUrl,
    this.currentBalance = 0.0,
    this.totalDistributed = 0.0,
    this.totalReturned = 0.0,
    this.totalCoffeePurchased = 0.0,
    required this.createdAt,
    this.lastActiveAt,
    this.isActive = true,
  });

  /// Create Worker from Firestore document
  factory Worker.fromFirestore(Map<String, dynamic> data, String id) {
    return Worker(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      role: data['role'] ?? 'Worker',
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      status: data['status'] ?? 'active',
      performanceRating: (data['performanceRating'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'],
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      totalDistributed: (data['totalDistributed'] ?? 0.0).toDouble(),
      totalReturned: (data['totalReturned'] ?? 0.0).toDouble(),
      totalCoffeePurchased: (data['totalCoffeePurchased'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      lastActiveAt: data['lastActiveAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastActiveAt'])
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert Worker to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'yearsOfExperience': yearsOfExperience,
      'status': status,
      'performanceRating': performanceRating,
      'photoUrl': photoUrl,
      'currentBalance': currentBalance,
      'totalDistributed': totalDistributed,
      'totalReturned': totalReturned,
      'totalCoffeePurchased': totalCoffeePurchased,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActiveAt': lastActiveAt?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  /// Create a copy of Worker with updated fields
  Worker copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    int? yearsOfExperience,
    String? status,
    double? performanceRating,
    String? photoUrl,
    double? currentBalance,
    double? totalDistributed,
    double? totalReturned,
    double? totalCoffeePurchased,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isActive,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      status: status ?? this.status,
      performanceRating: performanceRating ?? this.performanceRating,
      photoUrl: photoUrl ?? this.photoUrl,
      currentBalance: currentBalance ?? this.currentBalance,
      totalDistributed: totalDistributed ?? this.totalDistributed,
      totalReturned: totalReturned ?? this.totalReturned,
      totalCoffeePurchased: totalCoffeePurchased ?? this.totalCoffeePurchased,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get display status text
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'busy':
        return 'Busy';
      case 'offline':
        return 'Offline';
      default:
        return status;
    }
  }

  /// Get rating as percentage (0-100)
  int get ratingPercentage => performanceRating.round();

  /// Get rating as stars (0-5)
  double get ratingStars => (performanceRating / 20.0);
}
