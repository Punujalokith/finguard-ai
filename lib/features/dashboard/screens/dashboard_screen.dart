import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../goals/providers/goal_provider.dart';
import '../../goals/models/goal_model.dart';
import '../../transactions/models/transaction_model.dart';
import '../../fraud/screens/fraud_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../digital_twin/screens/digital_twin_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _balanceVisible = false; // hidden by default — tap eye icon to reveal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<TransactionProvider, GoalProvider, AuthProvider>(
        builder: (_, tp, gp, auth, __) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(tp, auth)),
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            SliverToBoxAdapter(child: _buildHealthScore(tp)),
            SliverToBoxAdapter(child: _buildAiInsights(tp)),
            SliverToBoxAdapter(child: _buildSpendingTrends(tp)),
            SliverToBoxAdapter(child: _buildGoalProgress(gp)),
            SliverToBoxAdapter(child: _buildRecentTransactions(tp)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TransactionProvider tp, AuthProvider auth) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final userName = auth.userName ?? 'there';

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$greeting,',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              IconButton(
                icon: Icon(_balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white70),
                onPressed: () => setState(() => _balanceVisible = !_balanceVisible),
              ),
            ],
          ),
          Text(userName,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  _balanceVisible ? Formatters.currency(tp.balance) : 'RM ••••••',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _HeaderStat(
                      label: 'Income',
                      value: _balanceVisible ? Formatters.currency(tp.totalIncome) : 'RM •••',
                      color: const Color(0xFF55EFC4),
                      icon: Icons.arrow_upward_rounded,
                    ),
                    const SizedBox(width: 32),
                    _HeaderStat(
                      label: 'Expenses',
                      value: _balanceVisible ? Formatters.currency(tp.totalExpense) : 'RM •••',
                      color: const Color(0xFFFFAB91),
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction('AI Twin', Icons.auto_awesome, AppColors.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalTwinScreen()))),
      _QuickAction('Goals', Icons.track_changes_rounded, AppColors.pink,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen()))),
      _QuickAction('Fraud', Icons.shield_rounded, AppColors.teal,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FraudScreen()))),
      _QuickAction('Reports', Icons.bar_chart_rounded, const Color(0xFFE17055),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((a) => _QuickActionButton(action: a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore(TransactionProvider tp) {
    final score = tp.healthScore;
    final color = score >= 80 ? AppColors.teal : score >= 60 ? AppColors.primary : AppColors.warning;
    return _Card(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Financial Health Score',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Theme.of(context).dividerColor,
                    color: color,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  score >= 80 ? 'Excellent! Keep up the good work.' : score >= 60 ? 'Good, room for improvement.' : 'Needs attention.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$score/100',
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsights(TransactionProvider tp) {
    final insight = tp.aiInsight;
    return _Card(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.teal]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Insights',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                Text(insight,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                const SizedBox(height: 8),
                const Text('View all insights →',
                    style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrends(TransactionProvider tp) {
    final monthly = tp.getMonthlyExpenses(6);
    if (monthly.values.every((v) => v == 0)) return const SizedBox.shrink();
    final maxY = monthly.values.reduce((a, b) => a > b ? a : b) * 1.3;

    return _Card(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending Trends',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: Theme.of(context).dividerColor,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final now = DateTime.now();
                      final m = DateTime(now.year, now.month - (5 - v.toInt()));
                      return Text(Formatters.monthShort(m),
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodyMedium?.color));
                    },
                    reservedSize: 20,
                  ),
                ),
              ),
              minY: 0,
              maxY: maxY == 0 ? 100 : maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: monthly.entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 4, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withAlpha(30),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress(GoalProvider gp) {
    final active = gp.activeGoals.take(2).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return _Card(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Savings Goal Progress',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 14),
          ...active.map((g) => _GoalProgressRow(goal: g)),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider tp) {
    final recent = tp.recentTransactions;
    return _Card(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              TextButton(
                onPressed: () {},
                child: const Text('View all',
                    style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
            ],
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No transactions yet',
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            ...recent.take(5).map((t) => _TransactionRow(t: t)),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _HeaderStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      );
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _QuickAction(this.label, this.icon, this.color, this.onTap);
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: action.color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: action.color.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(action.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(action.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _GoalProgressRow extends StatelessWidget {
  final GoalModel goal;
  const _GoalProgressRow({required this.goal});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.title,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ),
                Text(Formatters.currency(goal.savedAmount),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(' / ${Formatters.currency(goal.targetAmount)}',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Theme.of(context).dividerColor,
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel t;
  const _TransactionRow({required this.t});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(t.category);
    final icon = AppColors.categoryIcon(t.category);
    final isIncome = t.isIncome;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(t.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${Formatters.currency(t.amount)}',
            style: TextStyle(
              color: isIncome ? AppColors.income : AppColors.expense,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  const _Card({required this.child, this.margin});

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      );
}
