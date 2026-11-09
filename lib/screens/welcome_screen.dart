import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ExpenseProvider>().setUser(_name.text);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _brand(bool compact) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mustard,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.savings, size: 36, color: AppColors.ink),
            ),
            const SizedBox(height: 20),
            const Text('FinFlow',
                style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Track spending. Hit your budget.\nSee where your money flows.',
                style: TextStyle(fontSize: 18, color: Colors.white70)),
            if (!compact) ...[
              const SizedBox(height: 28),
              for (final f in const [
                'Live category insights',
                'Monthly budget tracking',
                'Works on phone, tablet & desktop'
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.mustard, size: 20),
                    const SizedBox(width: 10),
                    Text(f, style: const TextStyle(color: Colors.white)),
                  ]),
                ),
            ],
          ],
        ),
      );

  Widget _form() => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: FadeIn(
              child: AppCard(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Create your profile',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person)),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return 'Enter at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email)),
                        validator: (v) {
                          final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(v?.trim() ?? '');
                          return ok ? null : 'Enter a valid email address';
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Get started'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.blue, AppColors.teal],
          ),
        ),
        child: SafeArea(
          child: wide
              ? Row(children: [
                  Expanded(child: _brand(false)),
                  Expanded(child: _form()),
                ])
              : Column(children: [
                  SizedBox(height: 200, child: _brand(true)),
                  Expanded(child: _form()),
                ]),
        ),
      ),
    );
  }
}
