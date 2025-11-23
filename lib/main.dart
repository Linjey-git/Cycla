import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/cycle_calculator.dart';
import 'utils/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ініціалізація timezone
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
        title: 'Cycla',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('uk', 'UA'),
          Locale('en', 'US'),
        ],
        locale: const Locale('uk', 'UA'),
        home: const HomeScreen(),
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
  
  CycleCalculator? getCalculator() {
    if (_lastPeriodStart == null) return null;
    return CycleCalculator(
      lastPeriodStart: _lastPeriodStart!,
      cycleLength: _cycleLength,
      periodLength: _periodLength,
    );
  }

  DateTime? getNextPeriodDate() {
    return getCalculator()?.getNextPeriodDate();
  }
  
  DateTime? getOvulationDate() {
    return getCalculator()?.getNextOvulationDate();
  }
  
  List<DateTime> getFertileWindow() {
    final calc = getCalculator();
    if (calc == null) return [];
    return calc.getAllFertileDays(1);
  }
  
  bool isPeriodDay(DateTime date) {
    final calc = getCalculator();
    if (calc == null) return false;
    return calc.isPeriodDay(date, 20);
  }
  
  bool isFertileDay(DateTime date) {
    final calc = getCalculator();
    if (calc == null) return false;
    return calc.isFertileDay(date, 20);
  }
  
  bool isOvulationDay(DateTime date) {
    final calc = getCalculator();
    if (calc == null) return false;
    return calc.isOvulationDay(date, 20);
  }
  
  Map<String, dynamic>? getDayInfo(DateTime date) {
    return getCalculator()?.getDayInfo(date);
  }
}