

/*
 * Project: Flutter Credit Card Scanner
 * Developer: Muhammad Usman
 * LinkedIn: https://www.linkedin.com/in/muhammad-usman-81994a324
 *
 * Description: Real-time OCR scanner using Google ML Kit with custom Fast-Scan Logic.
 */




import 'package:card_scanner/pages/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // FIX: Use the full class name 'ColorScheme'
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.indigoAccent,
        ),
        // ... rest of your code
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: ScannerPage(),
    );
  }
}