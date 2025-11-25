import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';

class SymptomDiaryScreen extends StatefulWidget {
  const SymptomDiaryScreen({Key? key}) : super(key: key);

  @override
  State<SymptomDiaryScreen> createState() => _SymptomDiaryScreenState();
}

class _SymptomDiaryScreenState extends State<SymptomDiaryScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> selectedSymptoms = [];
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = true;

  final List<String> availableSymptoms = [
    'Головний біль',
    'Втомлення',
    'Вздуття',
    'Депресія',
    'Спазми',
    'Запор',
    'Діарея',
    'Висипання',
    'Болі в суглобах',
    'Сніданок',
  ];

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    setState(() => isLoading = true);

    try {
      final symptoms = await DatabaseService.instance.getSymptomsForDate(
        selectedDate,
      );
      final description = await DatabaseService.instance.getSymptomDescription(
        selectedDate,
      );

      setState(() {
        selectedSymptoms = symptoms;
        descriptionController.text = description;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Помилка при завантаженні: $e')));
      }
    }
  }

  Future<void> _saveSymptoms() async {
    try {
      await DatabaseService.instance.saveSymptom(
        selectedDate,
        selectedSymptoms,
        descriptionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Симптоми збережені'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Помилка при збереженні: $e')));
      }
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Щоденник симптомів'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Вибір дати
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Дата: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                            _loadSymptoms();
                          }
                        },
                        child: const Text('Змінити дату'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Список симптомів
                  const Text(
                    'Вибрані симптоми:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSymptoms.map((symptom) {
                      final isSelected = selectedSymptoms.contains(symptom);
                      return FilterChip(
                        label: Text(symptom),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSymptoms.add(symptom);
                            } else {
                              selectedSymptoms.remove(symptom);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Опис
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Додати опис...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: 'Опис',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Кнопка збереження
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSymptoms,
                      child: const Text('Зберегти симптоми'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
