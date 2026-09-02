import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio/screens/home_screen.dart';

// Import your new theme files
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

void main() {
  runApp(
    // Wrap the entire app in the provider to manage state
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PortfolioApp(),
    ),
  );
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the ThemeProvider to listen for mode changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Moosa Raza Portfolio',
          debugShowCheckedModeBanner: false,
          
          // Link the theme mode and custom themes we created
          themeMode: themeProvider.themeMode, 
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          
          // Keep your existing home screen
          home: const HomeScreen(),
        );
      },
    );
  }
}