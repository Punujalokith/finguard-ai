import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../goals/providers/goal_provider.dart';
import '../../ai_assistant/providers/ai_assistant_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<AuthProvider, TransactionProvider, GoalProvider>(
        builder: (_, auth, tp, gp, __) {
          final name = auth.userName ?? 'User';
          final email = auth.userEmail ?? '';
          final initials = name.trim().split(' ')
              .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, name, email, initials, tp, gp)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppearanceSection(context),
                      const SizedBox(height: 20),
                      _buildAiSection(context),
                      const SizedBox(height: 20),
                      _buildAboutSection(context),
                      const SizedBox(height: 20),
                      _buildLogoutButton(context, auth),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email,
      String initials, TransactionProvider tp, GoalProvider gp) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF00B894)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 28),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(80), width: 2),
            ),
            child: Center(
              child: Text(initials.isEmpty ? 'U' : initials,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              _statPill('Health Score', '${tp.healthScore}', Icons.favorite_rounded),
              const SizedBox(width: 10),
              _statPill('Active Goals', '${gp.activeGoals.length}', Icons.flag_rounded),
              const SizedBox(width: 10),
              _statPill('Saved', Formatters.currencyCompact(tp.balance > 0 ? tp.balance : 0),
                  Icons.savings_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return _SectionCard(
      title: 'Appearance & Region',
      children: [
        // Dark mode
        Consumer<ThemeProvider>(
          builder: (_, tp, __) => _SettingRow(
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xFF6C5CE7),
            title: 'Dark Mode',
            subtitle: tp.isDark ? 'Dark theme active' : 'Light theme active',
            trailing: Switch(
              value: tp.isDark,
              onChanged: (_) => tp.toggle(),
              activeColor: AppColors.primary,
            ),
          ),
        ),
        // Country & Currency
        Consumer<SettingsProvider>(
          builder: (_, settings, __) => _SettingRow(
            icon: Icons.flag_rounded,
            iconColor: AppColors.teal,
            title: 'Country & Currency',
            subtitle:
                '${settings.countryFlag} ${settings.countryName}  •  ${settings.currencyCode} (${settings.currencySymbol})',
            trailing: const Icon(Icons.chevron_right_rounded,
                color: Colors.grey),
            onTap: () => _showCountryPicker(context),
          ),
        ),
        _SettingRow(
          icon: Icons.notifications_rounded,
          iconColor: AppColors.warning,
          title: 'Notifications',
          subtitle: 'Budget alerts & insights',
          trailing: Switch(
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _showCountryPicker(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _CountryPickerSheet(settings: settings),
    );
  }

  Widget _buildAiSection(BuildContext context) {
    return _SectionCard(
      title: 'AI Settings',
      children: [
        _SettingRow(
          icon: Icons.key_rounded,
          iconColor: AppColors.teal,
          title: 'Claude API Key',
          subtitle: 'Required for AI chat features',
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: () => _showApiKeySheet(context),
        ),
        _SettingRow(
          icon: Icons.auto_awesome_rounded,
          iconColor: AppColors.pink,
          title: 'AI Model',
          subtitle: 'claude-sonnet-4-6 (latest)',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.teal.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Active', style: TextStyle(color: AppColors.teal, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _SectionCard(
      title: 'About',
      children: [
        _SettingRow(
          icon: Icons.info_outline_rounded,
          iconColor: Colors.grey,
          title: 'App Version',
          subtitle: 'FinGuard AI v1.0.0',
          trailing: const SizedBox.shrink(),
        ),
        _SettingRow(
          icon: Icons.shield_outlined,
          iconColor: AppColors.teal,
          title: 'Privacy Policy',
          subtitle: 'Your data stays on your device',
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ),
        _SettingRow(
          icon: Icons.star_outline_rounded,
          iconColor: AppColors.warning,
          title: 'Rate App',
          subtitle: 'Share your feedback',
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, auth),
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: const Text('Log Out', style: TextStyle(color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showApiKeySheet(BuildContext context) {
    final ai = context.read<AiAssistantProvider>();
    final keyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Use sheetCtx (the sheet's own BuildContext) so viewInsets correctly
      // reflects the on-screen keyboard height inside the bottom sheet.
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Claude API Key',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Get your key from console.anthropic.com',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 20),
              TextField(
                controller: keyCtrl,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'sk-ant-api03-...',
                  prefixIcon: const Icon(Icons.key_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (keyCtrl.text.trim().isNotEmpty) {
                      await ai.saveApiKey(keyCtrl.text.trim());
                    }
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                  child: const Text('Save API Key'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) Divider(
                    height: 1, indent: 56,
                    color: Theme.of(context).dividerColor,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ── Country Picker Sheet ───────────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  final SettingsProvider settings;
  const _CountryPickerSheet({required this.settings});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<CountryCurrency> get _filtered {
    if (_query.isEmpty) return SettingsProvider.allCountries;
    final q = _query.toLowerCase();
    return SettingsProvider.allCountries.where((c) =>
        c.country.toLowerCase().contains(q) ||
        c.currency.toLowerCase().contains(q) ||
        c.symbol.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Country & Currency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Currency symbol updates everywhere automatically',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search country or currency...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).dividerColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Country list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No results for "$_query"',
                        style: TextStyle(color: Colors.grey.shade500)),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final cc = _filtered[i];
                      final isSelected =
                          cc.country == widget.settings.selected.country;
                      return ListTile(
                        leading: Text(cc.flag,
                            style: const TextStyle(fontSize: 26)),
                        title: Text(cc.country,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14)),
                        subtitle: Text(
                            '${cc.currency}  •  ${cc.symbol}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary)
                            : null,
                        selected: isSelected,
                        selectedTileColor:
                            AppColors.primary.withAlpha(12),
                        onTap: () async {
                          await widget.settings.setCountry(cc);
                          if (mounted) Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
