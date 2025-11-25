import 'package:flutter/material.dart';

class AppTheme {
  // Яскраві кольори для різних фаз циклу
  static const Color periodColor = Color(0xFFE91E63); // Рожевий
  static const Color fertileColor = Color(0xFF4CAF50); // Зелений
  static const Color ovulationColor = Color(0xFFFF9800); // Помаранчевий
  static const Color normalColor = Color(0xFF9C27B0); // Фіолетовий

  static const Color primaryColor = Color(0xFFE91E63);
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color backgroundColor = Color(0xFFFCE4EC);
  static const Color cardColor = Colors.white;

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
  );
}

class AppConstants {
  static const List<String> symptoms = [
    '🤕 Headache',
    '😫 Cramps',
    '😌 Good mood',
    '😢 Low mood',
    '💤 Fatigue',
    '🍕 Increased appetite',
    '🤢 Nausea',
    '💆 Breast tenderness',
    '🔥 Elevated temperature',
    '💧 Heavy bleeding',
  ];

  static const List<String> tipsByPhase = [];

  static String getTipForPhase(String phase, int day) {
    final tips = {
      'menstrual': [
        '🌸 Drink more water to reduce bloating',
        '🧘 Try light yoga to ease pain',
        '🍫 Eat foods rich in magnesium (dark chocolate, nuts)',
        '💆 Massage your belly counterclockwise',
        '😴 Rest more — your body needs the energy',
      ],
      'follicular': [
        '💪 Great time for intense workouts!',
        '🎯 Your energy is at its peak — plan challenging tasks',
        '🥗 Add protein and fresh vegetables to your diet',
        '🧠 A good time to learn something new',
        '✨ Your skin is glowing — perfect moment for photos!',
      ],
      'ovulation': [
        '🌟 Peak energy and confidence!',
        '💃 Great time for social activity',
        '🥑 Eat foods rich in Omega-3 (fish, avocado)',
        '🏃 Your body is ready for physical challenges',
        '💚 Increased fertility — be mindful',
      ],
      'luteal': [
        '🍵 Drink herbal teas to calm your body',
        '🛀 Relaxing baths can help with PMS',
        '🍎 Eat complex carbs to keep your mood stable',
        '📝 Make lists — concentrating may be harder',
        '💤 Listen to your body and rest',
      ],
    };

    return tips[phase]?[day % tips[phase]!.length] ??
        '💖 Take care of yourself today!';
  }

  static String getCyclePhase(
    DateTime date,
    DateTime lastPeriodStart,
    int cycleLength,
    int periodLength,
  ) {
    final dayOfCycle = date.difference(lastPeriodStart).inDays % cycleLength;

    if (dayOfCycle < periodLength) {
      return 'menstrual';
    } else if (dayOfCycle < cycleLength - 14) {
      return 'follicular';
    } else if (dayOfCycle == cycleLength - 14) {
      return 'ovulation';
    } else {
      return 'luteal';
    }
  }
}
