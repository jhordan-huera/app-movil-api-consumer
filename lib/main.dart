import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const HotelAdminApp());
}

class HotelAdminApp extends StatelessWidget {
  const HotelAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1C1917); // Obsidian Black
    const accentColor = Color(0xFFA16207);  // Dark Gold
    const backgroundColor = Color(0xFFFAFAF9);
    const surfaceColor = Color(0xFFFFFFFF);
    
    // Configurar tipografía base con Jost
    final baseTextTheme = GoogleFonts.jostTextTheme(Theme.of(context).textTheme);
    
    // Configurar tipografía de títulos con Bodoni Moda
    final luxuryTextTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.bodoniModa(textStyle: baseTextTheme.displayLarge, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.bodoniModa(textStyle: baseTextTheme.displayMedium, fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.bodoniModa(textStyle: baseTextTheme.displaySmall, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.bodoniModa(textStyle: baseTextTheme.headlineLarge, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.bodoniModa(textStyle: baseTextTheme.headlineMedium, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.bodoniModa(textStyle: baseTextTheme.headlineSmall, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.bodoniModa(textStyle: baseTextTheme.titleLarge, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.bodoniModa(textStyle: baseTextTheme.titleMedium, fontWeight: FontWeight.w500),
    );

    return MaterialApp(
      title: 'Hotel Guests',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: luxuryTextTheme,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          surface: surfaceColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: GoogleFonts.bodoniModa(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceColor.withValues(alpha: 0.9), // Ligera transparencia para glassmorphism
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Bordes más suaves
            side: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.jost(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          labelStyle: GoogleFonts.jost(color: const Color(0xFF64748B)),
          prefixIconColor: const Color(0xFF64748B),
        ),
      ),
      home: const HomePage(),
    );
  }
}