import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../utils/theme.dart';
import '../services/database_service.dart';

class SymptomDiaryScreen extends StatefulWidget {
  const SymptomDiaryScreen({Key? key}) : super(key: key);

  @override
  State<SymptomDiaryScreen> createState() => _SymptomDiaryScreenState();
}

class _SymptomDiaryScreenState extends State<SymptomDiaryScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final symptoms = provider.symptoms[selectedDate] ?? [];

        return Scaffold(
          appBar: AppBar(title: const Text('Щоденник симптомів')),
          body: Column(
            children: [
              // Вибір дати
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          selectedDate = selectedDate.subtract(
                            const Duration(days: 1),
                          );
                        });
                      },
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DateFormat(
                              'd MMMM yyyy',
                              'uk',
                            ).format(selectedDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed:
                          selectedDate.isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          )
                          ? () {
                              setState(() {
                                selectedDate = selectedDate.add(
                                  const Duration(days: 1),
                                );
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),

              // Список симптомів
              Expanded(
                child: symptoms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Немає симптомів',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Натисніть + щоб додати',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: symptoms.length,
                        itemBuilder: (context, index) {
                          final symptom = symptoms[index];
                          return _buildSymptomCard(symptom, () async {
                            provider.symptoms[selectedDate]!.remove(symptom);
                            await DatabaseService.instance.deleteSymptom(
                              selectedDate,
                              symptom,
                            );
                            setState(() {});
                          });
                        },
                      ),
              ),

              // Швидкі симптоми внизу
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Швидкі симптоми:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.symptoms
                          .take(6)
                          .map(
                            (symptom) =>
                                _buildQuickSymptomChip(symptom, provider),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSymptomDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Додати симптом'),
          ),
        );
      },
    );
  }

  Widget _buildSymptomCard(String symptom, VoidCallback onDelete) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.favorite, color: AppTheme.primaryColor),
        ),
        title: Text(
          symptom,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('HH:mm').format(DateTime.now()),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Видалити симптом?'),
                content: Text('Видалити "$symptom"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Скасувати'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onDelete();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Видалити'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickSymptomChip(String symptom, CycleProvider provider) {
    final isSelected =
        provider.symptoms[selectedDate]?.contains(symptom) ?? false;

    return FilterChip(
      label: Text(symptom),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected) {
          await provider.addSymptom(selectedDate, symptom);
        } else {
          provider.symptoms[selectedDate]?.remove(symptom);
          await DatabaseService.instance.deleteSymptom(selectedDate, symptom);
        }
        setState(() {});
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  void _showAddSymptomDialog(BuildContext context, CycleProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Виберіть симптом'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.symptoms.length,
            itemBuilder: (context, index) {
              final symptom = AppConstants.symptoms[index];
              final isSelected =
                  provider.symptoms[selectedDate]?.contains(symptom) ?? false;

              return CheckboxListTile(
                title: Text(symptom),
                value: isSelected,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) async {
                  if (value == true) {
                    await provider.addSymptom(selectedDate, symptom);
                  } else {
                    provider.symptoms[selectedDate]?.remove(symptom);
                    await DatabaseService.instance.deleteSymptom(
                      selectedDate,
                      symptom,
                    );
                  }
                  setState(() {});
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }
}