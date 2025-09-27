import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const StudentConnectApp());
}

class StudentConnectApp extends StatelessWidget {
  const StudentConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'PFW Connect',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D4ED8)),
          useMaterial3: true,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Roboto'),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
