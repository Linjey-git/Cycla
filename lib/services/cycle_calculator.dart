class CycleCalculator {
  final DateTime lastPeriodStart;
  final int cycleLength;
  final int periodLength;

  CycleCalculator({
    required this.lastPeriodStart,
    required this.cycleLength,
    required this.periodLength,
  });

  /// Отримати всі дати менструацій на наступні N циклів
  List<DateTime> getPeriodDates(int numberOfCycles) {
    List<DateTime> dates = [];

    for (int i = 0; i < numberOfCycles; i++) {
      final periodDate = lastPeriodStart.add(Duration(days: cycleLength * i));
      dates.add(periodDate);
    }

    return dates;
  }

  /// Отримати всі дні менструації (включно з усіма циклами)
  List<DateTime> getAllPeriodDays(int numberOfCycles) {
    List<DateTime> allDays = [];
    final periodDates = getPeriodDates(numberOfCycles);

    for (var periodStart in periodDates) {
      for (int i = 0; i < periodLength; i++) {
        allDays.add(periodStart.add(Duration(days: i)));
      }
    }

    return allDays;
  }

  /// Отримати всі дати овуляції на наступні N циклів
  List<DateTime> getOvulationDates(int numberOfCycles) {
    List<DateTime> dates = [];
    final periodDates = getPeriodDates(numberOfCycles);

    for (var periodStart in periodDates) {
      // Овуляція зазвичай за 14 днів до наступної менструації
      final ovulationDate = periodStart.add(Duration(days: cycleLength - 14));
      dates.add(ovulationDate);
    }

    return dates;
  }

  /// Отримати всі фертильні дні (5 днів до овуляції + день овуляції + 1 день після)
  List<DateTime> getAllFertileDays(int numberOfCycles) {
    List<DateTime> allDays = [];
    final ovulationDates = getOvulationDates(numberOfCycles);

    for (var ovulationDate in ovulationDates) {
      // 5 днів до овуляції
      for (int i = -5; i <= 1; i++) {
        allDays.add(ovulationDate.add(Duration(days: i)));
      }
    }

    return allDays;
  }

  /// Перевірити чи є день менструацією
  bool isPeriodDay(DateTime date, int numberOfCycles) {
    final allPeriodDays = getAllPeriodDays(numberOfCycles);
    return allPeriodDays.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  /// Перевірити чи є день овуляцією
  bool isOvulationDay(DateTime date, int numberOfCycles) {
    final ovulationDates = getOvulationDates(numberOfCycles);
    return ovulationDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  /// Перевірити чи є день фертильним
  bool isFertileDay(DateTime date, int numberOfCycles) {
    final fertileDays = getAllFertileDays(numberOfCycles);
    return fertileDays.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  /// Отримати наступну дату менструації
  DateTime getNextPeriodDate() {
    final now = DateTime.now();
    final periodDates = getPeriodDates(20); // Перевіряємо 20 циклів вперед

    return periodDates.firstWhere(
      (date) => date.isAfter(now),
      orElse: () => lastPeriodStart.add(Duration(days: cycleLength)),
    );
  }

  /// Отримати наступну дату овуляції
  DateTime getNextOvulationDate() {
    final now = DateTime.now();
    final ovulationDates = getOvulationDates(20);

    return ovulationDates.firstWhere(
      (date) => date.isAfter(now),
      orElse: () => lastPeriodStart.add(Duration(days: cycleLength - 14)),
    );
  }

  /// Отримати інформацію про поточний день циклу
  Map<String, dynamic> getDayInfo(DateTime date) {
    // Знайти до якого циклу належить цей день
    int daysSinceLastPeriod = date.difference(lastPeriodStart).inDays;
    int currentCycleNumber = (daysSinceLastPeriod / cycleLength).floor();
    int dayOfCycle = (daysSinceLastPeriod % cycleLength) + 1;

    String phase = 'normal';
    if (dayOfCycle <= periodLength) {
      phase = 'menstrual';
    } else if (dayOfCycle >= cycleLength - 14 - 5 &&
        dayOfCycle <= cycleLength - 14 + 1) {
      phase = 'fertile';
      if (dayOfCycle == cycleLength - 14) {
        phase = 'ovulation';
      }
    } else if (dayOfCycle > periodLength && dayOfCycle < cycleLength - 14) {
      phase = 'follicular';
    } else {
      phase = 'luteal';
    }

    return {
      'cycleNumber': currentCycleNumber,
      'dayOfCycle': dayOfCycle,
      'phase': phase,
      'isPeriod': isPeriodDay(date, 20),
      'isOvulation': isOvulationDay(date, 20),
      'isFertile': isFertileDay(date, 20),
    };
  }

  /// Отримати статистику циклів
  Map<String, dynamic> getCycleStats() {
    final now = DateTime.now();
    final nextPeriod = getNextPeriodDate();
    final nextOvulation = getNextOvulationDate();

    final daysUntilPeriod = nextPeriod.difference(now).inDays;
    final daysUntilOvulation = nextOvulation.difference(now).inDays;

    return {
      'nextPeriodDate': nextPeriod,
      'daysUntilPeriod': daysUntilPeriod,
      'nextOvulationDate': nextOvulation,
      'daysUntilOvulation': daysUntilOvulation,
      'averageCycleLength': cycleLength,
    };
  }
}
