import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import 'worker_service.dart';
import 'notification_trigger_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WorkerService _workerService = WorkerService();
  final NotificationTriggerService _notificationService = NotificationTriggerService();
  static const String _transactionsCollection = 'transactions';

  /// Get transactions for a specific worker
  Stream<List<MoneyTransaction>> getWorkerTransactionsStream(String workerId) {
    return _firestore
        .collection(_transactionsCollection)
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs.map((doc) {
        return MoneyTransaction.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Sort by date (newest first)
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return transactions;
    });
  }

  /// Get all transactions
  Stream<List<MoneyTransaction>> getAllTransactionsStream() {
    return _firestore
        .collection(_transactionsCollection)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs.map((doc) {
        return MoneyTransaction.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Sort by date (newest first)
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return transactions;
    });
  }

  /// Get all transactions (One-time fetch)
  Future<List<MoneyTransaction>> getAllTransactions() async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => MoneyTransaction.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching all transactions: $e');
      return [];
    }
  }

  /// Add transaction and update worker balance
  Future<String?> addTransaction(MoneyTransaction transaction) async {
    try {
      // For purchase and return transactions, validate balance first
      if (transaction.type.toLowerCase() == 'purchase' || 
          transaction.type.toLowerCase() == 'return') {
        final workerDoc = await _firestore
            .collection('workers')
            .doc(transaction.workerId)
            .get();
        
        if (!workerDoc.exists) {
          throw 'Worker not found';
        }
        
        final currentBalance = (workerDoc.data()?['currentBalance'] ?? 0.0).toDouble();
        
        if (transaction.amount > currentBalance) {
          throw 'Insufficient balance. Available: ETB ${currentBalance.toStringAsFixed(2)}, Required: ETB ${transaction.amount.toStringAsFixed(2)}';
        }
      }

      // Start a batch write
      final batch = _firestore.batch();

      // Add transaction
      final transactionRef = _firestore.collection(_transactionsCollection).doc();
      batch.set(transactionRef, transaction.toFirestore());

      // Update worker balance
      final workerRef = _firestore.collection('workers').doc(transaction.workerId);
      
      // Calculate balance change
      double balanceChange = 0;
      Map<String, dynamic> updates = {};

      switch (transaction.type.toLowerCase()) {
        case 'distribution':
          balanceChange = transaction.amount;
          updates = {
            'currentBalance': FieldValue.increment(transaction.amount),
            'totalDistributed': FieldValue.increment(transaction.amount),
            'lastActiveAt': DateTime.now().millisecondsSinceEpoch,
          };
          break;
        case 'return':
          balanceChange = -transaction.amount;
          updates = {
            'currentBalance': FieldValue.increment(-transaction.amount),
            'totalReturned': FieldValue.increment(transaction.amount),
            'lastActiveAt': DateTime.now().millisecondsSinceEpoch,
          };
          break;
        case 'purchase':
          balanceChange = -transaction.amount;
          updates = {
            'currentBalance': FieldValue.increment(-transaction.amount),
            'totalCoffeePurchased': FieldValue.increment(transaction.amount),
            'lastActiveAt': DateTime.now().millisecondsSinceEpoch,
          };
          // Also update totalCommissionEarned if commission was calculated
          if (transaction.commissionAmount != null && transaction.commissionAmount! > 0) {
            updates['totalCommissionEarned'] = FieldValue.increment(transaction.commissionAmount!);
          }
          break;
      }

      batch.update(workerRef, updates);

      // Commit the batch
      await batch.commit();

      // Trigger notifications after successful transaction
      await _triggerTransactionNotifications(
        transaction: transaction,
        balanceChange: balanceChange,
      );

      print('Transaction added successfully: ${transactionRef.id}');
      return transactionRef.id;
    } on FirebaseException catch (e) {
      print('Firestore error adding transaction: ${e.code} - ${e.message}');
      throw _handleFirestoreError(e);
    } catch (e) {
      print('Error adding transaction: $e');
      throw 'Failed to add transaction. Please try again.';
    }
  }

  /// Trigger notifications based on transaction type
  Future<void> _triggerTransactionNotifications({
    required MoneyTransaction transaction,
    required double balanceChange,
  }) async {
    try {
      // Get worker data to check userId and new balance
      final workerDoc = await _firestore
          .collection('workers')
          .doc(transaction.workerId)
          .get();
      
      if (!workerDoc.exists) return;
      
      final workerData = workerDoc.data()!;
      final workerUserId = workerData['userId'] as String?;
      final workerName = workerData['name'] as String? ?? 'Worker';
      final newBalance = (workerData['currentBalance'] ?? 0.0).toDouble();
      final totalCommission = (workerData['totalCommissionEarned'] ?? 0.0).toDouble();
      
      // Only send notifications if worker has a user account
      if (workerUserId == null || workerUserId.isEmpty) return;
      
      switch (transaction.type.toLowerCase()) {
        case 'distribution':
          // Notify worker they received money
          await _notificationService.notifyMoneyDistributed(
            workerId: transaction.workerId,
            workerUserId: workerUserId,
            workerName: workerName,
            amount: transaction.amount,
            adminName: null, 
          );
          break;
          
        case 'purchase':
          // Check for low balance
          await _notificationService.checkLowBalance(
            workerId: transaction.workerId,
            workerUserId: workerUserId,
            workerName: workerName,
            newBalance: newBalance,
          );
          
          // Notify commission earned
          if (transaction.commissionAmount != null && transaction.commissionAmount! > 0) {
            await _notificationService.notifyCommissionEarned(
              workerUserId: workerUserId,
              workerName: workerName,
              commission: transaction.commissionAmount!,
              totalCommission: totalCommission,
            );
          }
          
          // Check for large purchase (notify admins)
          await _notificationService.checkLargePurchase(
            workerId: transaction.workerId,
            workerName: workerName,
            amount: transaction.amount,
            coffeeType: transaction.coffeeType,
            weight: transaction.coffeeWeight,
          );
          break;
          
        case 'return':
          // Could add notification for returns if needed
          break;
      }
    } catch (e) {
      // Don't fail the transaction if notification fails
      print('Error triggering notifications: $e');
    }
  }

  /// Get recent transactions (limit)
  Future<List<MoneyTransaction>> getRecentTransactions({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .limit(limit)
          .get();

      final transactions = snapshot.docs
          .map((doc) => MoneyTransaction.fromFirestore(doc.data(), doc.id))
          .toList();

      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return transactions;
    } catch (e) {
      print('Error getting recent transactions: $e');
      return [];
    }
  }

  /// Get worker transactions (limit)
  Future<List<MoneyTransaction>> getWorkerTransactions(
    String workerId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('workerId', isEqualTo: workerId)
          .limit(limit)
          .get();

      final transactions = snapshot.docs
          .map((doc) => MoneyTransaction.fromFirestore(doc.data(), doc.id))
          .toList();

      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return transactions;
    } catch (e) {
      print('Error getting worker transactions: $e');
      return [];
    }
  }

  /// Get transactions by type
  Future<List<MoneyTransaction>> getTransactionsByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('type', isEqualTo: type)
          .get();

      final transactions = snapshot.docs
          .map((doc) => MoneyTransaction.fromFirestore(doc.data(), doc.id))
          .toList();

      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return transactions;
    } catch (e) {
      print('Error getting transactions by type: $e');
      return [];
    }
  }

  /// Calculate total for today
  Future<Map<String, double>> getTodayTotals() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startTimestamp = startOfDay.millisecondsSinceEpoch;

      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .get();

      double totalDistributed = 0;
      double totalReturned = 0;
      double totalPurchased = 0;

      for (var doc in snapshot.docs) {
        final transaction = MoneyTransaction.fromFirestore(doc.data(), doc.id);
        switch (transaction.type.toLowerCase()) {
          case 'distribution':
            totalDistributed += transaction.amount;
            break;
          case 'return':
            totalReturned += transaction.amount;
            break;
          case 'purchase':
            totalPurchased += transaction.amount;
            break;
        }
      }

      return {
        'distributed': totalDistributed,
        'returned': totalReturned,
        'purchased': totalPurchased,
      };
    } catch (e) {
      print('Error getting today totals: $e');
      return {
        'distributed': 0.0,
        'returned': 0.0,
        'purchased': 0.0,
      };
    }
  }

  /// Handle Firestore exceptions with user-friendly messages
  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Database access denied. Please check your permissions.';
      case 'unavailable':
        return 'Database is currently unavailable. Please check your internet connection.';
      case 'not-found':
        return 'Transaction not found in database.';
      case 'already-exists':
        return 'This transaction already exists.';
      default:
        return 'Database error: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Upload receipt image
  Future<String?> uploadReceipt(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('receipts/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading receipt: $e');
      throw 'Failed to upload receipt image';
    }
  }
}
