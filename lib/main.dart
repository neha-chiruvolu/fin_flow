import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/home_shell.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = ExpenseProvider();
  await provider.load();
  runApp(ChangeNotifierProvider.value(
    value: provider,
    child: const FinFlowApp(),
  ));
}

class FinFlowApp extends StatelessWidget {
  const FinFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = context.read<ExpenseProvider>().userName.isNotEmpty;
    return MaterialApp(
      title: 'FinFlow - Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: signedIn ? '/home' : '/',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeShell(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/add') {
          return PageRouteBuilder(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => const AddTransactionScreen(),
            transitionsBuilder: (_, anim, __, child) {
              final curved =
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.08), end: Offset.zero)
                      .animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        return null;
      },
    );
  }
}
