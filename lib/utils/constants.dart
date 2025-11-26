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
