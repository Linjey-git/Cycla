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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
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
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
  );
}

class AppConstants {
  static const List<String> symptoms = [
    '🤕 Головний біль',
    '😫 Судоми',
    '😌 Хороший настрій',
    '😢 Поганий настрій',
    '💤 Втома',
    '🍕 Підвищений апетит',
    '🤢 Нудота',
    '💆 Біль у грудях',
    '🔥 Підвищена температура',
    '💧 Сильна кровотеча',
  ];
  
  static const List<String> tipsByPhase = [];
  
  static String getTipForPhase(String phase, int day) {
    final tips = {
      'menstrual': [
        '🌸 Пийте більше води, щоб зменшити здуття',
        '🧘 Спробуйте легку йогу для полегшення болю',
        '🍫 Їжте продукти з магнієм (темний шоколад, горіхи)',
        '💆 Зробіть масаж живота проти годинникової стрілки',
        '😴 Відпочивайте більше - вашому тілу потрібна енергія',
      ],
      'follicular': [
        '💪 Відмінний час для інтенсивних тренувань!',
        '🎯 Ваша енергія на піку - плануйте складні задачі',
        '🥗 Додайте білки та свіжі овочі до раціону',
        '🧠 Гарний час для навчання нового',
        '✨ Ваша шкіра сяє - чудовий момент для фото!',
      ],
      'ovulation': [
        '🌟 Пік енергії та впевненості!',
        '💃 Відмінний час для соціальної активності',
        '🥑 Їжте продукти з Омега-3 (риба, авокадо)',
        '🏃 Ваше тіло готове до фізичних викликів',
        '💚 Підвищена фертильність - будьте обережні',
      ],
      'luteal': [
        '🍵 Пийте трав\'яні чаї для заспокоєння',
        '🛀 Розслаблюючі ванни допоможуть із ПМС',
        '🍎 Їжте складні вуглеводи для стабільного настрою',
        '📝 Робіть списки - може бути важче концентруватись',
        '💤 Слухайте своє тіло та відпочивайте',
      ],
    };
    
    return tips[phase]?[day % tips[phase]!.length] ?? 
           '💖 Дбайте про себе сьогодні!';
  }
  
  static String getCyclePhase(DateTime date, DateTime lastPeriodStart, int cycleLength, int periodLength) {
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