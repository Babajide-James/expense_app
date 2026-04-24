import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'state/app_controller.dart';
import 'state/app_scope.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: AppController.seeded(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F7FB),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1148A5),
            primary: const Color(0xFF1148A5),
            brightness: Brightness.light,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFD9E3F3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFD9E3F3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF1148A5), width: 1.4),
            ),
          ),
        ),
        home: const HomeShell(),
      ),
    );
  }
}
