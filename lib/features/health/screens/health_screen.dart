import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Health')),
      body: Consumer<TransactionProvider>(
        builder: (_, tp, __) {
          final score = tp.healthScore;
          final categories = _buildCategories(tp);
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildScoreHeader(context, score),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRadarCard(context, categories),
                      const SizedBox(height: 16),
                      const Text('Category Scores',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      ...categories.map((c) => _CategoryScoreCard(cat: c)),
                      const SizedBox(height: 16),
                      _buildHistoryChart(context, score),
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

  Widget _buildScoreHeader(BuildContext context, int score) {
    final color = score >= 80 ? AppColors.teal : score >= 60 ? AppColors.primary : AppColors.warning;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(180)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          const Text('Your Financial Health Score',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$score', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w700)),
              const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 4),
                child: Text('/100', style: TextStyle(color: Colors.white70, fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 2),
                    Text('+2 pts', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          Text(
            score >= 80 ? 'Excellent Financial Health!' : score >= 60 ? 'Good Financial Health' : 'Needs Improvement',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.white.withAlpha(30),
                      color: Colors.white,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're in the top ${(100 - score + 15).clamp(5, 50)}% of FinGuard AI users. Keep up the great work!",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard(BuildContext context, List<_HealthCat> cats) {
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
          const Text('Score Breakdown',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: false),
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withAlpha(40),
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    dataEntries: cats.map((c) => RadarEntry(value: c.score.toDouble())).toList(),
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                tickCount: 4,
                ticksTextStyle: const TextStyle(fontSize: 0),
                tickBorderData: BorderSide(color: Theme.of(context).dividerColor),
                gridBorderData: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                titleTextStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 11,
                ),
                getTitle: (i, _) => RadarChartTitle(text: cats[i].name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChart(BuildContext context, int currentScore) {
    final scores = [72.0, 75.0, 78.0, 80.0, 82.0, currentScore.toDouble()];
    final months = List.generate(6, (i) {
      final now = DateTime.now();
      return DateTime(now.year, now.month - (5 - i));
    });

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
          const Text('Score History (6 Months)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: LineChart(LineChartData(
              minY: 60,
              maxY: 105,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: Theme.of(context).dividerColor, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 20,
                    getTitlesWidget: (v, _) => Text(
                      Formatters.monthShort(months[v.toInt()]),
                      style: TextStyle(fontSize: 10,
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: scores.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  isCurved: true,
                  color: AppColors.teal,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 4, color: AppColors.teal, strokeWidth: 2, strokeColor: Colors.white),
                  ),
                  belowBarData: BarAreaData(show: true, color: AppColors.teal.withAlpha(30)),
                ),
              ],
            )),
          ),
          const SizedBox(height: 10),
          Text(
            'Your score has improved by ${(currentScore - 72)} points over the last 6 months! 📈',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<_HealthCat> _buildCategories(TransactionProvider tp) {
    final savings = (tp.savingsRate.clamp(0, 100)).toInt();
    final budget = tp.totalIncome > 0
        ? ((tp.totalIncome - tp.totalExpense) / tp.totalIncome * 100).clamp(0, 100).toInt()
        : 50;
    return [
      _HealthCat('Savings', savings,
          tip: 'Try to increase to 20% for optimal financial health',
          detail: 'You save ${tp.savingsRate.toStringAsFixed(0)}% of your income'),
      _HealthCat('Debt', 72,
          tip: 'Focus on high-interest debt to improve this score',
          detail: 'Debt-to-income ratio: 28%'),
      _HealthCat('Budget', budget.clamp(0, 100),
          tip: 'Excellent! Keep monitoring dining expenses',
          detail: 'Staying within budget ${budget.clamp(0, 100)}% of the time'),
      _HealthCat('Goals', 78,
          tip: 'Increase monthly contributions by RM100',
          detail: '72% toward all financial goals'),
      _HealthCat('Emergency', 88,
          tip: 'Target is 6 months — almost there!',
          detail: 'Can cover 5.5 months of expenses'),
    ];
  }
}

class _HealthCat {
  final String name, tip, detail;
  final int score;
  _HealthCat(this.name, this.score, {required this.tip, required this.detail});
}

class _CategoryScoreCard extends StatelessWidget {
  final _HealthCat cat;
  const _CategoryScoreCard({required this.cat});

  Color get _color {
    if (cat.score >= 80) return AppColors.teal;
    if (cat.score >= 60) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
                child: Icon(_iconFor(cat.name), color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(cat.detail, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  Text('${cat.score}',
                      style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 18)),
                  Icon(Icons.arrow_upward_rounded, color: _color, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: cat.score / 100,
              backgroundColor: Theme.of(context).dividerColor,
              color: _color, minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('Tip: ', style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
                Expanded(child: Text(cat.tip, style: const TextStyle(fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'Savings': return Icons.savings_rounded;
      case 'Debt': return Icons.credit_card_rounded;
      case 'Budget': return Icons.account_balance_wallet_rounded;
      case 'Goals': return Icons.track_changes_rounded;
      case 'Emergency': return Icons.security_rounded;
      default: return Icons.bar_chart_rounded;
    }
  }
}
