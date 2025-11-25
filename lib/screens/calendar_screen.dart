import 'package:cycla/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Обмеження календаря: 2 місяці назад, поточний місяць, 9 місяців вперед
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _firstDay = DateTime(now.year, now.month - 2, 1);
    _lastDay = DateTime(
      now.year,
      now.month + 10,
      0,
    ); // Останній день 9-го місяця вперед
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Календар циклу')),
          body: Column(
            children: [
              // Легенда
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Менструація', AppTheme.periodColor),
                        _buildLegendItem('Фертильне', AppTheme.fertileColor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Овуляція', AppTheme.ovulationColor),
                        _buildLegendItem('Звичайний', AppTheme.normalColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Календар показує 12 місяців (2 назад + 10 вперед)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Календар
              Expanded(
                child: TableCalendar(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  locale: 'uk_UA',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, provider);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(
                        context,
                        day,
                        provider,
                        isToday: true,
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(
                        context,
                        day,
                        provider,
                        isSelected: true,
                      );
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      // Показати дні поза поточним місяцем, але в межах дозволеного діапазону
                      if (day.isBefore(_firstDay) || day.isAfter(_lastDay)) {
                        return Container();
                      }
                      return _buildCalendarDay(
                        context,
                        day,
                        provider,
                        isOutside: true,
                      );
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (selectedDay.isBefore(_firstDay) ||
                        selectedDay.isAfter(_lastDay)) {
                      return; // Не дозволяти вибирати дні поза діапазоном
                    }
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showDayDetails(context, selectedDay, provider);
                  },
                  onPageChanged: (focusedDay) {
                    // Обмежити прокрутку
                    if (focusedDay.isBefore(_firstDay)) {
                      setState(() => _focusedDay = _firstDay);
                    } else if (focusedDay.isAfter(_lastDay)) {
                      setState(() => _focusedDay = _lastDay);
                    } else {
                      setState(() => _focusedDay = focusedDay);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCalendarDay(
    BuildContext context,
    DateTime day,
    CycleProvider provider, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    Color? backgroundColor;
    Color textColor = isOutside ? Colors.grey.shade400 : Colors.black;

    if (provider.lastPeriodStart != null) {
      if (provider.isPeriodDay(day)) {
        backgroundColor = AppTheme.periodColor;
        textColor = Colors.white;
      } else if (provider.isOvulationDay(day)) {
        backgroundColor = AppTheme.ovulationColor;
        textColor = Colors.white;
      } else if (provider.isFertileDay(day)) {
        backgroundColor = AppTheme.fertileColor;
        textColor = Colors.white;
      }
    }

    if (isToday && backgroundColor == null) {
      backgroundColor = AppTheme.normalColor.withOpacity(0.3);
    }

    if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
    }

    final hasSymptoms = provider.symptoms[day]?.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (hasSymptoms)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDayDetails(
    BuildContext context,
    DateTime day,
    CycleProvider provider,
  ) {
    final symptoms = provider.symptoms[day] ?? [];
    String phaseInfo = '';

    if (provider.lastPeriodStart != null) {
      if (provider.isPeriodDay(day)) {
        phaseInfo = '🌸 День менструації';
      } else if (provider.isOvulationDay(day)) {
        phaseInfo = '🌟 День овуляції';
      } else if (provider.isFertileDay(day)) {
        phaseInfo = '💚 Фертильний день';
      } else {
        phaseInfo = '📅 Звичайний день';
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('d MMMM yyyy', 'uk').format(day),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (phaseInfo.isNotEmpty) ...[
              Text(
                phaseInfo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (symptoms.isNotEmpty) ...[
              const Text(
                'Симптоми:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...symptoms.map(
                (symptom) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(symptom)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.removeSymptom(day, symptom);
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _addSymptomDialog(context, day, provider);
                },
                icon: const Icon(Icons.add),
                label: const Text('Додати симптом'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSymptomDialog(
    BuildContext context,
    DateTime day,
    CycleProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Додати симптом'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.symptoms.length,
            itemBuilder: (context, index) {
              final symptom = AppConstants.symptoms[index];
              return ListTile(
                title: Text(symptom),
                onTap: () {
                  provider.addSymptom(day, symptom);
                  Navigator.pop(context);
                  setState(() {});
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
        ],
      ),
    );
  }
}
