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
        String phaseTitle = 'Tips of the day';
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
              phaseTitle = 'Menstruation';
              phaseEmoji = '🌸';
              phaseColor = AppTheme.periodColor;
              break;
            case 'follicular':
              phaseTitle = 'Follicular phase';
              phaseEmoji = '🌱';
              phaseColor = AppTheme.fertileColor;
              break;
            case 'ovulation':
              phaseTitle = 'Ovulation';
              phaseEmoji = '🌟';
              phaseColor = AppTheme.ovulationColor;
              break;
            case 'luteal':
              phaseTitle = 'Luteal phase';
              phaseEmoji = '🌙';
              phaseColor = AppTheme.secondaryColor;
              break;
          }
        } else {
          tips = [
            '💖 Set up your cycle in the main menu',
            '📱 Use the calendar to keep track',
            '📝 Add symptoms daily',
            '⏰ Set a reminder',
            '🌸 Take care of yourself!',
          ];
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Daily tips')),
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
                        'Tips for this phase',
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
        return 'Time for relaxation and self-care';
      case 'follicular':
        return 'Energy is rising, the perfect time for new projects';
      case 'ovulation':
        return 'Peak energy and confidence';
      case 'luteal':
        return 'Time to slow down and listen to your body';
      default:
        return 'Take care of your health every day';
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
        '💧 Recommended activity',
        'Light yoga, stretching, walks in the fresh air',
        '',
        '🥗 Food',
        'Iron (spinach, red meat), magnesium, vitamin C',
        '',
        '😌 Emotional state',
        'Possible fatigue, need for rest and support',
      ],
      'follicular': [
        '💪 Recommended activity',
        'Intense workouts, cardio, strength training',
        '',
        '🥗 Food',
        'Protein, fresh vegetables and fruit, whole grains',
        '',
        '😊 Emotional state',
        'Increased energy, optimism, motivation',
      ],
      'ovulation': [
        '🏃 Recommended activity',
        'High-intensity training, new challenges',
        '',
        '🥗 Food',
        'Omega-3, antioxidants, fibre',
        '',
        '😍 Emotional state',
        'Confidence, sociability, attractiveness',
      ],
      'luteal': [
        '🧘 Recommended activity',
        'Moderate exercise, Pilates, walking',
        '',
        '🥗 Food',
        'Complex carbohydrates, vitamin B6, calcium',
        '',
        '😐 Emotional state',
        'Possible mood swings, need for comfort',
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
              'Detailed information',
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
