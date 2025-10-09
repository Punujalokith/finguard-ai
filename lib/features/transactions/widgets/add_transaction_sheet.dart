import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

// ── Category data ─────────────────────────────────────────────────────────────

class _Cat {
  final String name;
  final IconData icon;
  final Color color;
  const _Cat(this.name, this.icon, this.color);
}

const _expenseCats = [
  _Cat('Food & Dining',   Icons.restaurant_rounded,       Color(0xFFE17055)),
  _Cat('Transport',       Icons.directions_car_rounded,   Color(0xFF00CEC9)),
  _Cat('Shopping',        Icons.shopping_bag_rounded,     Color(0xFF00B894)),
  _Cat('Bills & Utilities', Icons.bolt_rounded,           Color(0xFF55EFC4)),
  _Cat('Entertainment',   Icons.movie_rounded,            Color(0xFFFDAA47)),
  _Cat('Health & Medical',Icons.favorite_rounded,         Color(0xFFE84393)),
  _Cat('Education',       Icons.school_rounded,           Color(0xFF74B9FF)),
  _Cat('Rent & Housing',  Icons.home_rounded,             Color(0xFF6C5CE7)),
  _Cat('Subscriptions',   Icons.subscriptions_rounded,    Color(0xFFA29BFE)),
  _Cat('Travel',          Icons.flight_rounded,           Color(0xFF00B2D6)),
  _Cat('Fitness',         Icons.fitness_center_rounded,   Color(0xFF2ECC71)),
  _Cat('Other',           Icons.category_rounded,         Color(0xFFB2BEC3)),
];

const _incomeCats = [
  _Cat('Salary',      Icons.account_balance_wallet_rounded, Color(0xFF00B894)),
  _Cat('Freelance',   Icons.laptop_rounded,                 Color(0xFF74B9FF)),
  _Cat('Business',    Icons.storefront_rounded,             Color(0xFFA29BFE)),
  _Cat('Investment',  Icons.trending_up_rounded,            Color(0xFF00CEC9)),
  _Cat('Gift',        Icons.card_giftcard_rounded,          Color(0xFFE84393)),
  _Cat('Rental',      Icons.home_work_rounded,              Color(0xFFE17055)),
  _Cat('Bonus',       Icons.emoji_events_rounded,           Color(0xFFFDAA47)),
  _Cat('Side Hustle', Icons.lightbulb_rounded,              Color(0xFFF9CA24)),
  _Cat('Refund',      Icons.replay_rounded,                 Color(0xFF00B2D6)),
  _Cat('Other',       Icons.more_horiz_rounded,             Color(0xFFB2BEC3)),
];

// ── Sheet ─────────────────────────────────────────────────────────────────────

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _pageCtrl   = PageController();
  final _amountCtrl = TextEditingController();
  final _titleCtrl  = TextEditingController();
  final _noteCtrl   = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  bool _isExpense = true;
  _Cat? _selected;
  DateTime _date  = DateTime.now();
  bool _loading   = false;
  String? _catError;

  List<_Cat> get _cats => _isExpense ? _expenseCats : _incomeCats;

  void _goToStep1() {
    if (_selected == null) {
      setState(() => _catError = 'Please choose a category');
      return;
    }
    setState(() => _catError = null);
    _pageCtrl.animateToPage(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    _pageCtrl.animateToPage(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final t = TransactionModel(
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.replaceAll(',', '')),
      type:   _isExpense ? TransactionType.expense : TransactionType.income,
      category: _selected!.name,
      date: _date,
      note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
    );
    await context.read<TransactionProvider>().addTransaction(t);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: screenH * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPage0(context),
                _buildPage1(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 0: Type + Category ───────────────────────────────────────────────

  Widget _buildPage0(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              const Text('New Transaction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 22),
              ),
            ],
          ),
        ),

        // Expense / Income toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(child: _TypePill(
                  label: 'Expense',
                  icon: Icons.arrow_downward_rounded,
                  selected: _isExpense,
                  color: AppColors.expense,
                  onTap: () {
                    if (!_isExpense) {
                      setState(() { _isExpense = true; _selected = null; });
                    }
                  },
                )),
                Expanded(child: _TypePill(
                  label: 'Income',
                  icon: Icons.arrow_upward_rounded,
                  selected: !_isExpense,
                  color: AppColors.income,
                  onTap: () {
                    if (_isExpense) {
                      setState(() { _isExpense = false; _selected = null; });
                    }
                  },
                )),
              ],
            ),
          ),
        ),

        // Category grid
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
          child: Text('Choose Category',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
        ),
        if (_catError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(_catError!,
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
              children: _cats.map((cat) => _CatButton(
                cat: cat,
                selected: _selected?.name == cat.name,
                onTap: () => setState(() {
                  _selected  = cat;
                  _catError = null;
                }),
              )).toList(),
            ),
          ),
        ),

        // Continue button
        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20,
              MediaQuery.of(context).padding.bottom + 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _goToStep1,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selected?.color ?? AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Page 1: Amount + Details ──────────────────────────────────────────────

  Widget _buildPage1(BuildContext context) {
    final cat     = _selected;
    final catColor = cat?.color ?? AppColors.primary;
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: back + category badge
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
              if (cat != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: catColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: catColor.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, color: catColor, size: 16),
                      const SizedBox(width: 6),
                      Text(cat.name,
                          style: TextStyle(
                              color: catColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Text(
                _isExpense ? 'Expense' : 'Income',
                style: TextStyle(
                    color: _isExpense ? AppColors.expense : AppColors.income,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ],
          ),
        ),

        // Scrollable form
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20,
                MediaQuery.of(context).viewInsets.bottom + 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  _SectionLabel('Amount'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: catColor.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          Formatters.currencySymbol,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: catColor),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            autofocus: false,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: (isDark ? Colors.white : Colors.black).withAlpha(40)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              isDense: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter an amount';
                              }
                              final n = double.tryParse(v.replaceAll(',', ''));
                              if (n == null || n <= 0) return 'Enter a valid amount';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  _SectionLabel('Title *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: _isExpense
                          ? 'e.g. Lunch at KFC'
                          : 'e.g. Monthly salary',
                      prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Note
                  _SectionLabel('Note (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Add a note...',
                      prefixIcon: Icon(Icons.notes_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  _SectionLabel('Date'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 18,
                              color: catColor),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy').format(_date),
                            style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_calendar_rounded,
                              size: 16,
                              color: Colors.grey.shade500),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _save,
                      icon: _loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                      label: Text(_loading
                          ? 'Saving...'
                          : 'Save ${_isExpense ? "Expense" : "Income"}'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: catColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _TypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _CatButton extends StatelessWidget {
  final _Cat cat;
  final bool selected;
  final VoidCallback onTap;
  const _CatButton({
    required this.cat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? cat.color.withAlpha(25)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cat.color : Theme.of(context).dividerColor,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? cat.color
                    : cat.color.withAlpha(30),
                shape: BoxShape.circle,
                boxShadow: selected
                    ? [BoxShadow(
                        color: cat.color.withAlpha(80),
                        blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Icon(cat.icon,
                  size: 20,
                  color: selected ? Colors.white : cat.color),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cat.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? cat.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.3),
      );
}
