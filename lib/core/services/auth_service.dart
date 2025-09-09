import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'local_db.dart';

class AuthService {
  static const _keyLoggedIn   = 'logged_in';
  static const _keyUserEmail  = 'user_email';
  static const _keyUserName   = 'user_name';
  static const _keyUserUid    = 'user_uid';

  final _storage   = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  // ── Session ──────────────────────────────────────────────────────────────

  Future<bool> get isLoggedIn async {
    final val = await _storage.read(key: _keyLoggedIn);
    return val == 'true';
  }

  Future<Map<String, String?>> getCurrentUser() async => {
    'uid':   await _storage.read(key: _keyUserUid),
    'name':  await _storage.read(key: _keyUserName),
    'email': await _storage.read(key: _keyUserEmail),
  };

  Future<void> _saveSession(
      {required String uid, required String name, required String email}) async {
    await _storage.write(key: _keyLoggedIn,  value: 'true');
    await _storage.write(key: _keyUserUid,   value: uid);
    await _storage.write(key: _keyUserName,  value: name);
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<void> signOut() async {
    await _storage.write(key: _keyLoggedIn, value: 'false');
  }

  // ── Accounts ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _getAccounts() {
    final raw = LocalDb.user.get('accounts');
    if (raw == null) return {};
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> _saveAccounts(Map<String, dynamic> accounts) async {
    await LocalDb.user.put('accounts', accounts);
  }

  bool get hasAnyAccount => _getAccounts().isNotEmpty;

  // ── Register ──────────────────────────────────────────────────────────────

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final accounts = _getAccounts();
    if (accounts.containsKey(email.toLowerCase())) {
      throw Exception('An account with this email already exists.');
    }
    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    accounts[email.toLowerCase()] = jsonEncode({
      'uid': uid, 'name': name, 'password': password,
    });
    await _saveAccounts(accounts);
    await _saveSession(uid: uid, name: name, email: email.toLowerCase());
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    final accounts = _getAccounts();
    final key = email.toLowerCase();
    if (!accounts.containsKey(key)) {
      throw Exception('No account found with this email.');
    }
    final data = jsonDecode(accounts[key] as String) as Map<String, dynamic>;
    if (data['password'] != password) {
      throw Exception('Incorrect password. Please try again.');
    }
    await _saveSession(
        uid: data['uid'] as String,
        name: data['name'] as String,
        email: key);
  }

  // ── Google-style sign-in (stores locally, no real OAuth) ─────────────────

  Future<void> signInWithGoogle(String googleEmail, String displayName) async {
    final accounts = _getAccounts();
    final key = googleEmail.toLowerCase();
    // Auto-create account if first time
    if (!accounts.containsKey(key)) {
      final uid = 'g_${DateTime.now().millisecondsSinceEpoch}';
      accounts[key] = jsonEncode({
        'uid': uid, 'name': displayName, 'password': '__google__',
      });
      await _saveAccounts(accounts);
    }
    final data = jsonDecode(accounts[key] as String) as Map<String, dynamic>;
    await _saveSession(
        uid: data['uid'] as String,
        name: data['name'] as String,
        email: key);
  }

  // ── Guest ─────────────────────────────────────────────────────────────────

  Future<void> signInAsGuest() async {
    const guestEmail = 'guest@finguard.ai';
    const guestName  = 'Guest User';
    final accounts = _getAccounts();
    if (!accounts.containsKey(guestEmail)) {
      final uid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      accounts[guestEmail] = jsonEncode({
        'uid': uid, 'name': guestName, 'password': '__guest__',
      });
      await _saveAccounts(accounts);
    }
    final data = jsonDecode(accounts[guestEmail] as String) as Map<String, dynamic>;
    await _saveSession(
        uid: data['uid'] as String,
        name: guestName,
        email: guestEmail);
  }

  // ── Reset Password ────────────────────────────────────────────────────────

  Future<void> resetPassword(String email, String newPassword) async {
    final accounts = _getAccounts();
    final key = email.toLowerCase();
    if (!accounts.containsKey(key)) {
      throw Exception('No account found with this email.');
    }
    final data = jsonDecode(accounts[key] as String) as Map<String, dynamic>;
    data['password'] = newPassword;
    accounts[key] = jsonEncode(data);
    await _saveAccounts(accounts);
  }

  bool emailExists(String email) =>
      _getAccounts().containsKey(email.toLowerCase());

  // ── Biometric ─────────────────────────────────────────────────────────────

  Future<BiometricCheckResult> checkBiometricSupport() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported || !canCheck) {
        return BiometricCheckResult.notSupported;
      }
      final available = await _localAuth.getAvailableBiometrics();
      if (available.isEmpty) {
        return BiometricCheckResult.notEnrolled;
      }
      return BiometricCheckResult.available;
    } catch (_) {
      return BiometricCheckResult.notSupported;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Verify your identity to access FinGuard AI',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN/pattern as fallback
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// After biometric passes, restore or create a session.
  /// Returns the logged-in user map, or null if no account to restore.
  Future<Map<String, dynamic>?> biometricLogin() async {
    // Try restoring last session first
    final loggedIn = await isLoggedIn;
    if (loggedIn) {
      final user = await getCurrentUser();
      if (user['email'] != null) {
        await _saveSession(
            uid: user['uid'] ?? '',
            name: user['name'] ?? 'User',
            email: user['email']!);
        return {'name': user['name'], 'email': user['email']};
      }
    }
    // Fall back to first account in Hive
    final accounts = _getAccounts();
    if (accounts.isEmpty) return null;
    final email = accounts.keys.firstWhere(
        (e) => e != 'guest@finguard.ai', orElse: () => accounts.keys.first);
    final data = jsonDecode(accounts[email] as String) as Map<String, dynamic>;
    await _saveSession(
        uid: data['uid'] as String,
        name: data['name'] as String,
        email: email);
    return {'name': data['name'], 'email': email};
  }
}

enum BiometricCheckResult { available, notEnrolled, notSupported }
