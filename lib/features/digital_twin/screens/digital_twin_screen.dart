import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/digital_twin_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class DigitalTwinScreen extends StatefulWidget {
  const DigitalTwinScreen({super.key});

  @override
  State<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}

class _DigitalTwinScreenState extends State<DigitalTwinScreen> {
  final _eventNameCtrl = TextEditingController();
  final _eventCostCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTwin());
  }

  void _updateTwin() {
    final tp = context.read<TransactionProvider>();
    context.read<DigitalTwinProvider>().updateFromTransactions(
          totalIncome: tp.totalIncome,
          totalExpense: tp.totalExpense,
          balance: tp.balance,
        );
  }

  @override
  void dispose() {
    _eventNameCtrl.dispose();
    _eventCostCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Digital Twin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _updateTwin,
          ),
        ],
      ),
      body: Consumer<DigitalTwinProvider>(
        builder: (_, dt, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHealthCard(dt),
              const SizedBox(height: 16),
              _buildProjectionChart(dt),
              const SizedBox(height: 16),
              _buildProjectionStats(dt),
              const SizedBox(height: 16),
              _buildLifeEventSimulator(dt),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(DigitalTwinProvider dt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [dt.healthColor, dt.healthColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Financial Health',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    dt.financialHealthStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.monitor_heart_outlined,
                  color: Colors.white, size: 36),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip('Avg Income',
                  Formatters.currency(dt.avgMonthlyIncome), Colors.white),
              const SizedBox(width: 16),
              _statChip('Avg Expense',
                  Formatters.currency(dt.avgMonthlyExpense), Colors.white70),
              const SizedBox(width: 16),
              _statChip('Avg Savings',
                  Formatters.currency(dt.avgMonthlySavings),
                  dt.avgMonthlySavings >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildProjectionChart(DigitalTwinProvider dt) {
    if (dt.projections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('12-Month Balance Projection',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Based on your current spending patterns',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: dt.projections
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                            e.key.toDouble(), e.value.projectedBalance))
                        .toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Now',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
              Text(
                Formatters.monthYear(dt.projections.last.month),
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionStats(DigitalTwinProvider dt) {
    if (dt.projections.isEmpty) return const SizedBox.shrink();
    final last = dt.projections.last;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Projected Balance\n(12 months)',
            value: Formatters.currency(last.projectedBalance),
            icon: Icons.account_balance_wallet_outlined,
            color: last.projectedBalance >= 0
                ? AppColors.success
                : AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Annual Savings',
            value: Formatters.currency(dt.projectedAnnualSavings),
            icon: Icons.savings_outlined,
            color: dt.projectedAnnualSavings >= 0
                ? AppColors.success
                : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildLifeEventSimulator(DigitalTwinProvider dt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Life Event Simulator',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('How long to afford a major purchase?',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _eventNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Event name',
                    hintText: 'e.g. New Laptop',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _eventCostCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cost (RM)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _runSimulation(dt),
              child: const Text('Simulate'),
            ),
          ),
          if (_lastSimulation != null) ...[
            const SizedBox(height: 16),
            _SimulationResult(simulation: _lastSimulation!),
          ],
          const SizedBox(height: 16),
          const Text('Quick Events',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ('New Laptop', 3000.0),
              ('Car', 60000.0),
              ('Vacation', 5000.0),
              ('Wedding', 30000.0),
            ]
                .map((e) => ActionChip(
                      label: Text(e.$1),
                      onPressed: () {
                        _eventNameCtrl.text = e.$1;
                        _eventCostCtrl.text = e.$2.toStringAsFixed(0);
                        _runSimulation(dt);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  LifeEventSimulation? _lastSimulation;

  void _runSimulation(DigitalTwinProvider dt) {
    final name = _eventNameCtrl.text.trim();
    final cost = double.tryParse(_eventCostCtrl.text);
    if (name.isEmpty || cost == null) return;
    setState(() {
      _lastSimulation = dt.simulateLifeEvent(name, cost);
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SimulationResult extends StatelessWidget {
  final LifeEventSimulation simulation;
  const _SimulationResult({required this.simulation});

  @override
  Widget build(BuildContext context) {
    final color =
        simulation.isFeasible ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                simulation.isFeasible
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                simulation.eventName,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color),
              ),
              const Spacer(),
              Text(
                Formatters.currency(simulation.eventCost),
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            simulation.isFeasible
                ? 'You can afford this in ~${simulation.monthsToAfford} months by saving ${Formatters.currency(simulation.requiredMonthlySaving)}/month.'
                : 'This may not be feasible with your current savings rate. Consider increasing income or reducing expenses.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
