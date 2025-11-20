import 'package:cycla/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../utils/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
                  ],
                ),
              ),

              // Календар
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
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
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showDayDetails(context, selectedDay, provider);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
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
  }) {
    Color? backgroundColor;
    Color textColor = Colors.black;

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
                          provider.symptoms[day]!.remove(symptom);
                          DatabaseService.instance.deleteSymptom(day, symptom);
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