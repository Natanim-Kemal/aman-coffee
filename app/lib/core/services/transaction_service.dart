import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import 'worker_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WorkerService _workerService = WorkerService();
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

  /// Add transaction and update worker balance
  Future<String?> addTransaction(MoneyTransaction transaction) async {
    try {
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
          break;
      }

      batch.update(workerRef, updates);

      // Commit the batch
      await batch.commit();

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
