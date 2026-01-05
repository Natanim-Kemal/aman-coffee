import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;
  User? _user;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      final isValid = await _authService.isSessionValid();
      if (!isValid) {
        // Session expired, sign out
        await _authService.signOut();
      }
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('DEBUG: Starting sign in...');
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      print('DEBUG: Credential received: ${credential != null}');
      print('DEBUG: User: ${credential?.user != null}');

      if (credential != null && credential.user != null) {
        _user = credential.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        print('DEBUG: Sign in SUCCESS - returning true');
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Login failed. Please try again.';
        print('DEBUG: Sign in FAILED - credential or user is null');
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('DEBUG: Sign in ERROR: $e');
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authService.signOut();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user email
  String? getUserEmail() {
    return _authService.getUserEmail();
  }

  /// Get user display name
  String? getUserDisplayName() {
    return _authService.getUserDisplayName();
  }

  /// Get user ID
  String? getUserId() {
    return _authService.getUserId();
  }

  /// Check session validity
  Future<bool> isSessionValid() async {
    return await _authService.isSessionValid();
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      await _authService.resetPassword(email: email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
