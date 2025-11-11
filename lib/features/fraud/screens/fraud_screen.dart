import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class FraudScreen extends StatelessWidget {
  const FraudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fraud Detection')),
      body: Consumer<TransactionProvider>(
        builder: (_, tp, __) {
          final alerts = _buildAlerts(tp);
          final score = _securityScore(tp);
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSecurityHeader(context, score),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (alerts.isNotEmpty) ...[
                        const Text('Security Alerts',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        ...alerts.map((a) => _AlertCard(alert: a)),
                        const SizedBox(height: 20),
                      ],
                      const Text('Security Tips',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      _buildTipsCard(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecurityHeader(BuildContext context, int score) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Security Center',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('AI-powered fraud protection',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Security Score', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('$score/100',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                    Text(
                      score >= 80 ? 'Your account is well protected.' : 'Some risks detected.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    final tips = [
      'Enable two-factor authentication for extra security',
      'Never share your password or verification codes',
      'Review your transactions regularly',
      'Use strong, unique passwords for all accounts',
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Protect Your Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<_Alert> _buildAlerts(TransactionProvider tp) {
    final alerts = <_Alert>[];
    for (final t in tp.fraudAlerts) {
      alerts.add(_Alert(
        title: 'Large Transaction Detected',
        description: 'A purchase of ${Formatters.currency(t.amount)} was made at ${t.title}, which is higher than your usual spending.',
        amount: t.amount,
        merchant: t.title,
        location: 'Malaysia',
        timeAgo: Formatters.timeAgo(t.date),
        risk: _Risk.low,
        verified: false,
      ));
    }
    return alerts;
  }

  int _securityScore(TransactionProvider tp) {
    int score = 92;
    if (tp.fraudAlerts.isNotEmpty) score -= tp.fraudAlerts.length * 5;
    return score.clamp(50, 100);
  }
}

enum _Risk { low, medium, high }

class _Alert {
  final String title, description, merchant, location, timeAgo;
  final double amount;
  final _Risk risk;
  final bool verified;
  _Alert({required this.title, required this.description, required this.amount,
      required this.merchant, required this.location, required this.timeAgo,
      required this.risk, required this.verified});
}

class _AlertCard extends StatefulWidget {
  final _Alert alert;
  const _AlertCard({required this.alert});

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool _verified = false;

  Color get _riskColor {
    switch (widget.alert.risk) {
      case _Risk.high: return AppColors.error;
      case _Risk.medium: return AppColors.warning;
      case _Risk.low: return AppColors.primary;
    }
  }

  String get _riskLabel {
    switch (widget.alert.risk) {
      case _Risk.high: return 'High Risk';
      case _Risk.medium: return 'Medium Risk';
      case _Risk.low: return 'Low Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _riskColor.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _riskColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.alert.risk == _Risk.high ? Icons.cancel_rounded :
                widget.alert.risk == _Risk.medium ? Icons.warning_amber_rounded :
                Icons.info_outline_rounded,
                color: _riskColor, size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.alert.title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: _riskColor, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _riskColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_riskLabel,
                    style: TextStyle(color: _riskColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.alert.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.credit_card_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${Formatters.currency(widget.alert.amount)} • ${widget.alert.merchant}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(widget.alert.location, style: const TextStyle(fontSize: 12)),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(widget.alert.timeAgo, style: const TextStyle(fontSize: 12)),
          ]),
          if (_verified) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 14),
                  SizedBox(width: 4),
                  Text('Verified by you', style: TextStyle(color: AppColors.teal, fontSize: 12)),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _verified = true),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Verify', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Report Fraud', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
