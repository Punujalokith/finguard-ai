import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().signIn(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (ok) _goHome();
  }

  Future<void> _biometric() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok   = await auth.authenticateWithBiometrics();
    if (ok) {
      _goHome();
    } else if (mounted && auth.errorMessage != null) {
      _showSnack(auth.errorMessage!, isError: true);
    }
  }

  Future<void> _guestLogin() async {
    FocusScope.of(context).unfocus();
    final ok = await context.read<AuthProvider>().signInAsGuest();
    if (ok) _goHome();
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.teal,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  void _forgotPassword() {
    final auth     = context.read<AuthProvider>();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    final cPassCtrl = TextEditingController();
    final fKey      = GlobalKey<FormState>();
    int step        = 0;
    bool obscure1   = true;
    bool obscure2   = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(step == 0 ? 'Find Account' : 'New Password',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ]),
          content: SingleChildScrollView(
            child: Form(
              key: fKey,
              child: step == 0
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Enter your registered email address.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDeco('Email', Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter email';
                          if (!v.contains('@')) return 'Invalid email';
                          if (!auth.emailExists(v.trim())) return 'No account found';
                          return null;
                        },
                      ),
                    ])
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Set a new password for ${emailCtrl.text.trim()}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: obscure1,
                        decoration: _inputDecoSuffix(
                          'New Password', Icons.lock_outline,
                          IconButton(
                            icon: Icon(obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                            onPressed: () => setS(() => obscure1 = !obscure1),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter password';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cPassCtrl,
                        obscureText: obscure2,
                        decoration: _inputDecoSuffix(
                          'Confirm Password', Icons.lock_outline,
                          IconButton(
                            icon: Icon(obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                            onPressed: () => setS(() => obscure2 = !obscure2),
                          ),
                        ),
                        validator: (v) {
                          if (v != passCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(90, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (!fKey.currentState!.validate()) return;
                if (step == 0) {
                  setS(() => step = 1);
                } else {
                  final ok = await auth.resetPassword(emailCtrl.text.trim(), passCtrl.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) _showSnack(ok ? 'Password reset! You can sign in now.' : 'Reset failed.', isError: !ok);
                }
              },
              child: Text(step == 0 ? 'Next →' : 'Reset'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  void _googleSignIn() {
    final auth     = context.read<AuthProvider>();
    final emailCtrl = TextEditingController();
    final nameCtrl  = TextEditingController();
    final fKey      = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          // Google header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8)],
                ),
                child: const Icon(Icons.g_mobiledata_rounded,
                    color: Color(0xFF4285F4), size: 32),
              ),
              const SizedBox(height: 10),
              const Text('Sign in with Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Form(
              key: fKey,
              child: Column(children: [
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('Google Email', Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: _inputDeco('Display Name', Icons.person_outline),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (!fKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    final ok = await auth.signInWithGoogle(
                        emailCtrl.text.trim(), nameCtrl.text.trim());
                    if (ok) _goHome();
                  },
                  child: const Text('Sign In'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Input helpers ─────────────────────────────────────────────────────────

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      );

  InputDecoration _inputDecoSuffix(String hint, IconData icon, Widget suffix) =>
      _inputDeco(hint, icon).copyWith(suffixIcon: suffix);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────────────
          Container(
            height: size.height * 0.42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00B894)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Scrollable content ───────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // ── Hero ─────────────────────────────────────────────────
                  SizedBox(
                    height: size.height * 0.28,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withAlpha(80), width: 2),
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded,
                              color: Colors.white, size: 34),
                        ),
                        const SizedBox(height: 12),
                        const Text('FinGuard AI',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        const Text('Smart · Secure · Simple',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),

                  // ── Card ──────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: size.height * 0.66),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        final loading = auth.status == AuthStatus.loading;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome Back 👋',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Sign in to manage your finances',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade500)),
                            const SizedBox(height: 24),

                            // ── Error box ──────────────────────────────────
                            if (auth.errorMessage != null &&
                                auth.status == AuthStatus.error) ...[
                              _ErrorBox(message: auth.errorMessage!),
                              const SizedBox(height: 16),
                            ],

                            // ── Form ───────────────────────────────────────
                            Form(
                              key: _formKey,
                              child: Column(children: [
                                // Email
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: const Icon(
                                        Icons.email_outlined, size: 20),
                                    hintText: 'you@example.com',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _signIn(),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(
                                        Icons.lock_outline, size: 20),
                                    hintText: 'Enter your password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                          () => _obscure = !_obscure),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter your password'
                                      : null,
                                ),
                              ]),
                            ),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 36)),
                                child: const Text('Forgot Password?',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── Sign In Button ─────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: loading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: loading
                                    ? const SizedBox(
                                        width: 22, height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('Sign In',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Divider ────────────────────────────────────
                            Row(children: [
                              Expanded(child: Divider(
                                  color: Theme.of(context).dividerColor)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text('or continue with',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500)),
                              ),
                              Expanded(child: Divider(
                                  color: Theme.of(context).dividerColor)),
                            ]),

                            const SizedBox(height: 20),

                            // ── Social buttons row ─────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(
                                  label: 'Google',
                                  icon: Icons.g_mobiledata_rounded,
                                  color: const Color(0xFF4285F4),
                                  onTap: _googleSignIn,
                                ),
                                const SizedBox(width: 16),
                                _SocialButton(
                                  label: 'Fingerprint',
                                  icon: Icons.fingerprint_rounded,
                                  color: AppColors.primary,
                                  onTap: _biometric,
                                ),
                                const SizedBox(width: 16),
                                _SocialButton(
                                  label: 'Face ID',
                                  icon: Icons.face_rounded,
                                  color: AppColors.teal,
                                  onTap: _biometric,
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                '* Biometric requires signing in once first',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Divider(color: Theme.of(context).dividerColor),
                            const SizedBox(height: 16),

                            // ── Guest mode ─────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: loading ? null : _guestLogin,
                                icon: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 18),
                                label: const Text('Continue as Guest',
                                    style: TextStyle(fontSize: 14)),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Sign Up link ───────────────────────────────
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Don't have an account?  ",
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14)),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen()),
                                    ),
                                    child: const Text('Sign Up',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(50), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 13)),
          ),
        ]),
      );
}
