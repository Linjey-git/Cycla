import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../utils/theme.dart';
import 'calendar_screen.dart';
import 'daily_advice_screen.dart';
import 'symptom_diary_screen.dart';
import 'reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const CalendarScreen(),
    const DailyAdviceScreen(),
    const SymptomDiaryScreen(),
    const RemindersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Головна'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Календар',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tips_and_updates),
              label: 'Поради',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Симптоми',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Нагадування',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final today = DateTime.now();
        final nextPeriod = provider.getNextPeriodDate();
        final ovulation = provider.getOvulationDate();

        String cyclePhase = 'Не налаштовано';
        String phaseEmoji = '🌸';

        if (provider.lastPeriodStart != null) {
          final phase = AppConstants.getCyclePhase(
            today,
            provider.lastPeriodStart!,
            provider.cycleLength,
            provider.periodLength,
          );

          switch (phase) {
            case 'menstrual':
              cyclePhase = 'Менструація';
              phaseEmoji = '🌸';
              break;
            case 'follicular':
              cyclePhase = 'Фолікулярна фаза';
              phaseEmoji = '🌱';
              break;
            case 'ovulation':
              cyclePhase = 'Овуляція';
              phaseEmoji = '🌟';
              break;
            case 'luteal':
              cyclePhase = 'Лютеїнова фаза';
              phaseEmoji = '🌙';
              break;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cycle Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSettingsDialog(context, provider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Головна картка статусу
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            phaseEmoji,
                            style: const TextStyle(fontSize: 60),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cyclePhase,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('d MMMM yyyy', 'uk').format(today),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Прогноз
                  if (nextPeriod != null) ...[
                    _buildInfoCard(
                      context,
                      '📅 Наступна менструація',
                      DateFormat('d MMMM', 'uk').format(nextPeriod),
                      'через ${nextPeriod.difference(today).inDays} днів',
                      AppTheme.periodColor,
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (ovulation != null) ...[
                    _buildInfoCard(
                      context,
                      '🌟 Овуляція',
                      DateFormat('d MMMM', 'uk').format(ovulation),
                      ovulation.isAfter(today)
                          ? 'через ${ovulation.difference(today).inDays} днів'
                          : 'минула',
                      AppTheme.ovulationColor,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Фертильне вікно
                  _buildFertilityCard(context, provider),

                  const SizedBox(height: 20),

                  // Швидкі дії
                  Text(
                    'Швидкі дії',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          '📝',
                          'Симптоми',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SymptomDiaryScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          '💊',
                          'Ліки',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RemindersScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String date,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.circle, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Text(
          subtitle,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFertilityCard(BuildContext context, CycleProvider provider) {
    final fertile = provider.getFertileWindow();
    final today = DateTime.now();
    final isFertile = fertile.any(
      (d) =>
          d.year == today.year && d.month == today.month && d.day == today.day,
    );

    return Card(
      color: isFertile ? AppTheme.fertileColor.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: AppTheme.fertileColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Фертильне вікно',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isFertile
                  ? 'Сьогодні у вас високий шанс завагітніти'
                  : 'Сьогодні низький шанс завагітніти',
              style: TextStyle(
                color: isFertile ? AppTheme.fertileColor : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String emoji,
    String label,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, CycleProvider provider) {
    final lastPeriodController = TextEditingController(
      text: provider.lastPeriodStart?.toIso8601String().split('T')[0] ?? '',
    );
    final cycleLengthController = TextEditingController(
      text: provider.cycleLength.toString(),
    );
    final periodLengthController = TextEditingController(
      text: provider.periodLength.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Налаштування циклу'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cycleLengthController,
                decoration: const InputDecoration(
                  labelText: 'Довжина циклу (днів)',
                  hintText: '28',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: periodLengthController,
                decoration: const InputDecoration(
                  labelText: 'Довжина менструації (днів)',
                  hintText: '5',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: provider.lastPeriodStart ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    lastPeriodController.text = date.toIso8601String().split(
                      'T',
                    )[0];
                  }
                },
                child: Text(
                  lastPeriodController.text.isEmpty
                      ? 'Вибрати дату останньої менструації'
                      : 'Остання: ${lastPeriodController.text}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              if (lastPeriodController.text.isNotEmpty) {
                provider.updateCycleData(
                  lastPeriodStart: DateTime.parse(lastPeriodController.text),
                  cycleLength: int.tryParse(cycleLengthController.text) ?? 28,
                  periodLength: int.tryParse(periodLengthController.text) ?? 5,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }
}