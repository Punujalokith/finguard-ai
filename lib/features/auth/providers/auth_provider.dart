import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _userName;
  String? _userEmail;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasAnyAccount => _authService.hasAnyAccount;

  AuthProvider() {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await _authService.isLoggedIn;
    if (loggedIn) {
      final user = await _authService.getCurrentUser();
      _userName = user['name'];
      _userEmail = user['email'];
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
      final user = await _authService.getCurrentUser();
      _userName = user['name'];
      _userEmail = user['email'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<bool> register(String name, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.register(name: name, email: email, password: password);
      _userName = name;
      _userEmail = email.toLowerCase();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Google Sign-In (local simulation) ────────────────────────────────────

  Future<bool> signInWithGoogle(String googleEmail, String displayName) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithGoogle(googleEmail, displayName);
      _userName = displayName;
      _userEmail = googleEmail.toLowerCase();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Biometrics ────────────────────────────────────────────────────────────

  Future<bool> authenticateWithBiometrics() async {
    _errorMessage = null;
    notifyListeners();
    try {
      // 1. Check hardware/enrollment support
      final support = await _authService.checkBiometricSupport();
      if (support == BiometricCheckResult.notSupported) {
        _errorMessage = 'Biometrics not supported on this device.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      if (support == BiometricCheckResult.notEnrolled) {
        _errorMessage =
            'No biometrics enrolled. Please set up fingerprint or face ID in your device settings.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      // 2. Require at least one saved account
      if (!_authService.hasAnyAccount) {
        _errorMessage =
            'Please sign in with email first before using biometrics.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      // 3. Run the system biometric prompt
      final ok = await _authService.authenticateWithBiometrics();
      if (!ok) return false;
      // 4. Restore/create session
      final userData = await _authService.biometricLogin();
      if (userData == null) {
        _errorMessage =
            'No account found. Please sign in with email first.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      _userName = userData['name'] as String?;
      _userEmail = userData['email'] as String?;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage =
          'Biometric error: ${e.toString().replaceFirst('Exception: ', '')}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Guest ─────────────────────────────────────────────────────────────────

  Future<bool> signInAsGuest() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInAsGuest();
      _userName = 'Guest User';
      _userEmail = 'guest@finguard.ai';
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Could not enter guest mode.';
      notifyListeners();
      return false;
    }
  }

  // ── Reset Password ────────────────────────────────────────────────────────

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      await _authService.resetPassword(email, newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  bool emailExists(String email) => _authService.emailExists(email);

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
