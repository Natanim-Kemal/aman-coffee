import 'package:flutter/foundation.dart';
import '../models/worker_model.dart';
import '../services/worker_service.dart';

class WorkerProvider with ChangeNotifier {
  final WorkerService _workerService = WorkerService();
  
  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'busy', 'offline'

  // Statistics
  int _totalWorkers = 0;
  int _activeToday = 0;
  double _totalRevenue = 0.0;
  double _avgPerformance = 0.0;

  List<Worker> get workers => _filteredWorkers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  int get totalWorkers => _totalWorkers;
  int get activeToday => _activeToday;
  double get totalRevenue => _totalRevenue;
  double get avgPerformance => _avgPerformance;

  WorkerProvider() {
    _initializeWorkers();
  }

  /// Initialize workers stream
  void _initializeWorkers() {
    _isLoading = true;
    notifyListeners();

    _workerService.getWorkersStream().listen(
      (workersList) {
        _workers = workersList;
        _applyFilters();
        _updateStatistics();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        print('Worker stream error: $error');
        // Parse error for user-friendly message
        String friendlyMessage = 'Unable to load workers.';
        
        if (error.toString().contains('permission-denied') || 
            error.toString().contains('PERMISSION_DENIED')) {
          friendlyMessage = 'Database access denied. Please enable Firestore in your Firebase project.';
        } else if (error.toString().contains('unavailable')) {
          friendlyMessage = 'Database is unavailable. Please check your internet connection.';
        } else if (error.toString().contains('unauthenticated')) {
          friendlyMessage = 'Authentication required. Please sign in again.';
        }
        
        _errorMessage = friendlyMessage;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Apply search and filter
  void _applyFilters() {
    _filteredWorkers = _workers.where((worker) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          worker.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _statusFilter == 'all' ||
          worker.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  /// Update statistics
  void _updateStatistics() {
    _totalWorkers = _workers.length;
    _activeToday = _workers.where((w) => w.status == 'active').length;
    _totalRevenue = _workers.fold<double>(
      0.0,
      (sum, worker) => sum + worker.totalCoffeePurchased,
    );
    _avgPerformance = _workers.isNotEmpty
        ? _workers.fold<double>(0.0, (sum, worker) => sum + worker.performanceRating) /
            _workers.length
        : 0.0;
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Set status filter
  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = 'all';
    _applyFilters();
    notifyListeners();
  }

  /// Get worker by ID
  Future<Worker?> getWorkerById(String id) async {
    return await _workerService.getWorkerById(id);
  }

  /// Add new worker
  Future<bool> addWorker(Worker worker) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _workerService.addWorker(worker);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update worker
  Future<bool> updateWorker(String id, Worker worker) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _workerService.updateWorker(id, worker);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete worker
  Future<bool> deleteWorker(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _workerService.deleteWorker(id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update worker status
  Future<bool> updateWorkerStatus(String id, String status) async {
    try {
      await _workerService.updateWorkerStatus(id, status);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    _initializeWorkers();
  }
}
