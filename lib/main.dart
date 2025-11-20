import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Ініціалізація timezone
  tz.initializeTimeZones();

  // Ініціалізація служби нотифікацій
  await NotificationService.initialize(flutterLocalNotificationsPlugin);

  // Ініціалізація бази даних
  await DatabaseService.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CycleProvider(),
      child: MaterialApp(
        title: 'Cycle Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('uk', 'UA'), Locale('en', 'US')],
        locale: const Locale('uk', 'UA'),
      ),
    );
  }
}

class CycleProvider extends ChangeNotifier {
  DateTime? _lastPeriodStart;
  int _cycleLength = 28;
  int _periodLength = 5;
  Map<DateTime, List<String>> _symptoms = {};

  DateTime? get lastPeriodStart => _lastPeriodStart;
  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  Map<DateTime, List<String>> get symptoms => _symptoms;

  CycleProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseService.instance;
    final cycleData = await db.getCycleData();
    if (cycleData != null) {
      _lastPeriodStart = cycleData['lastPeriodStart'];
      _cycleLength = cycleData['cycleLength'];
      _periodLength = cycleData['periodLength'];
    }
    _symptoms = await db.getAllSymptoms();
    notifyListeners();
  }

  Future<void> updateCycleData({
    DateTime? lastPeriodStart,
    int? cycleLength,
    int? periodLength,
  }) async {
    if (lastPeriodStart != null) _lastPeriodStart = lastPeriodStart;
    if (cycleLength != null) _cycleLength = cycleLength;
    if (periodLength != null) _periodLength = periodLength;

    await DatabaseService.instance.saveCycleData(
      _lastPeriodStart!,
      _cycleLength,
      _periodLength,
    );
    notifyListeners();
  }

  Future<void> addSymptom(DateTime date, String symptom) async {
    if (_symptoms[date] == null) {
      _symptoms[date] = [];
    }
    _symptoms[date]!.add(symptom);
    await DatabaseService.instance.saveSymptom(date, symptom);
    notifyListeners();
  }

  DateTime? getNextPeriodDate() {
    if (_lastPeriodStart == null) return null;
    return _lastPeriodStart!.add(Duration(days: _cycleLength));
  }

  DateTime? getOvulationDate() {
    if (_lastPeriodStart == null) return null;
    return _lastPeriodStart!.add(Duration(days: _cycleLength - 14));
  }

  List<DateTime> getFertileWindow() {
    final ovulation = getOvulationDate();
    if (ovulation == null) return [];

    List<DateTime> fertile = [];
    for (int i = -5; i <= 1; i++) {
      fertile.add(ovulation.add(Duration(days: i)));
    }
    return fertile;
  }

  bool isPeriodDay(DateTime date) {
    if (_lastPeriodStart == null) return false;
    final diff = date.difference(_lastPeriodStart!).inDays;
    return diff >= 0 && diff < _periodLength;
  }

  bool isFertileDay(DateTime date) {
    return getFertileWindow().any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  bool isOvulationDay(DateTime date) {
    final ovulation = getOvulationDate();
    if (ovulation == null) return false;
    return date.year == ovulation.year &&
        date.month == ovulation.month &&
        date.day == ovulation.day;
  }
}
