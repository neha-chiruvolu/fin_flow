import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _isIncome = false;
  Category _category = Category.food;
  DateTime _date = DateTime.now();

  List<Category> get _options => _isIncome
      ? [Category.salary, Category.other]
      : Category.values.where((c) => c != Category.salary).toList();

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ExpenseProvider>().add(TransactionItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: _title.text.trim(),
          amount: double.parse(_amount.text.trim()),
          isIncome: _isIncome,
          category: _category,
          date: _date,
          note: _note.text.trim(),
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New transaction')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                            value: false,
                            label: Text('Expense'),
                            icon: Icon(Icons.arrow_upward)),
                        ButtonSegment(
                            value: true,
                            label: Text('Income'),
                            icon: Icon(Icons.arrow_downward)),
                      ],
                      selected: {_isIncome},
                      onSelectionChanged: (s) => setState(() {
                        _isIncome = s.first;
                        _category = _options.first;
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _title,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Title', prefixIcon: Icon(Icons.edit)),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: Icon(Icons.currency_rupee)),
                      validator: (v) {
                        final n = double.tryParse(v?.trim() ?? '');
                        if (n == null) return 'Enter a valid number';
                        if (n <= 0) return 'Amount must be greater than 0';
                        if (n > 100000000) return 'Amount is too large';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Category>(
                      value: _category,
                      decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category)),
                      items: _options
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Row(children: [
                                  Icon(c.icon, color: c.color, size: 20),
                                  const SizedBox(width: 10),
                                  Text(c.label),
                                ]),
                              ))
                          .toList(),
                      onChanged: (c) => setState(() => _category = c!),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today)),
                        child: Text(fmtDate(_date)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _note,
                      maxLines: 2,
                      maxLength: 120,
                      decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          prefixIcon: Icon(Icons.notes)),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.green),
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Save transaction'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
