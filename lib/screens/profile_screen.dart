import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _budget;

  @override
  void initState() {
    super.initState();
    final p = context.read<ExpenseProvider>();
    _name = TextEditingController(text: p.userName);
    _budget = TextEditingController(text: p.budget.round().toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<ExpenseProvider>();
    p.setUser(_name.text);
    p.setBudget(double.parse(_budget.text.trim()));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        FadeIn(
          child: AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.mustard,
                      child: Text(
                        p.userName.isEmpty
                            ? '?'
                            : p.userName[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text('Your settings',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                        labelText: 'Name', prefixIcon: Icon(Icons.person)),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Enter at least 2 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _budget,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Monthly budget (₹)',
                        prefixIcon: Icon(Icons.savings)),
                    validator: (v) {
                      final n = double.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) {
                        return 'Enter a budget greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save changes'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<ExpenseProvider>().resetDemoData();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demo data restored')));
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset to demo data'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      context.read<ExpenseProvider>().signOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (_) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
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
