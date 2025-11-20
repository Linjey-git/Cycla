import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/theme.dart';

class DailyAdviceScreen extends StatelessWidget {
  const DailyAdviceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final today = DateTime.now();
        String phase = 'normal';
        List<String> tips = [];
        String phaseTitle = 'Поради дня';
        String phaseEmoji = '💖';
        Color phaseColor = AppTheme.normalColor;

        if (provider.lastPeriodStart != null) {
          phase = AppConstants.getCyclePhase(
            today,
            provider.lastPeriodStart!,
            provider.cycleLength,
            provider.periodLength,
          );

          // Отримуємо 5 різних порад для поточної фази
          for (int i = 0; i < 5; i++) {
            tips.add(AppConstants.getTipForPhase(phase, i));
          }

          switch (phase) {
            case 'menstrual':
              phaseTitle = 'Менструація';
              phaseEmoji = '🌸';
              phaseColor = AppTheme.periodColor;
              break;
            case 'follicular':
              phaseTitle = 'Фолікулярна фаза';
              phaseEmoji = '🌱';
              phaseColor = AppTheme.fertileColor;
              break;
            case 'ovulation':
              phaseTitle = 'Овуляція';
              phaseEmoji = '🌟';
              phaseColor = AppTheme.ovulationColor;
              break;
            case 'luteal':
              phaseTitle = 'Лютеїнова фаза';
              phaseEmoji = '🌙';
              phaseColor = AppTheme.secondaryColor;
              break;
          }
        } else {
          tips = [
            '💖 Налаштуйте свій цикл у головному меню',
            '📱 Використовуйте календар для відстеження',
            '📝 Додавайте симптоми щодня',
            '⏰ Встановіть нагадування',
            '🌸 Дбайте про себе!',
          ];
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Щоденні поради')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Заголовок фази
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [phaseColor, phaseColor.withOpacity(0.7)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(phaseEmoji, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 16),
                      Text(
                        phaseTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPhaseDescription(phase),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Поради
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Поради для цієї фази',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ...tips.map((tip) => _buildTipCard(tip, phaseColor)),
                      const SizedBox(height: 24),

                      // Додаткова інформація
                      _buildInfoSection(context, phase),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Час для відпочинку та самотурботи';
      case 'follicular':
        return 'Енергія зростає, ідеальний час для нових проектів';
      case 'ovulation':
        return 'Пік енергії та впевненості';
      case 'luteal':
        return 'Час уповільнитись та прислухатись до тіла';
      default:
        return 'Дбайте про своє здоров\'я щодня';
    }
  }

  Widget _buildTipCard(String tip, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.lightbulb_outline, color: color),
        ),
        title: Text(tip, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String phase) {
    final Map<String, List<String>> phaseInfo = {
      'menstrual': [
        '💧 Рекомендована активність',
        'Легка йога, розтяжка, прогулянки на свіжому повітрі',
        '',
        '🥗 Харчування',
        'Залізо (шпинат, червоне м\'ясо), магній, вітамін С',
        '',
        '😌 Емоційний стан',
        'Можлива втома, потреба у спокої та підтримці',
      ],
      'follicular': [
        '💪 Рекомендована активність',
        'Інтенсивні тренування, кардіо, силові вправи',
        '',
        '🥗 Харчування',
        'Білки, свіжі овочі та фрукти, цільні зерна',
        '',
        '😊 Емоційний стан',
        'Підвищена енергія, оптимізм, мотивація',
      ],
      'ovulation': [
        '🏃 Рекомендована активність',
        'Високоінтенсивні тренування, нові виклики',
        '',
        '🥗 Харчування',
        'Омега-3, антиоксиданти, клітковина',
        '',
        '😍 Емоційний стан',
        'Впевненість, комунікабельність, привабливість',
      ],
      'luteal': [
        '🧘 Рекомендована активність',
        'Помірні тренування, пілатес, ходьба',
        '',
        '🥗 Харчування',
        'Складні вуглеводи, вітамін B6, кальцій',
        '',
        '😐 Емоційний стан',
        'Можливі перепади настрою, потреба у комфорті',
      ],
    };

    final info = phaseInfo[phase] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Детальна інформація',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...info.map((line) {
              if (line.isEmpty) {
                return const SizedBox(height: 12);
              }
              final isHeader =
                  line.contains('💧') ||
                  line.contains('💪') ||
                  line.contains('🏃') ||
                  line.contains('🧘') ||
                  line.contains('🥗') ||
                  line.contains('😌') ||
                  line.contains('😊') ||
                  line.contains('😍') ||
                  line.contains('😐');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: isHeader ? 16 : 14,
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                    color: isHeader ? AppTheme.primaryColor : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
