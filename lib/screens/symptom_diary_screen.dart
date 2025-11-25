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
    '🤕 Headache',
    '😫 Cramps',
    '😌 Good mood',
    '😢 Low mood',
    '💤 Fatigue',
    '🍕 Increased appetite',
    '🤢 Nausea',
    '💆 Breast tenderness',
    '🔥 Elevated temperature',
    '💧 Heavy bleeding',
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
        ).showSnackBar(SnackBar(content: Text('Error during download: $e')));
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
            content: Text('Symptoms saved successfully'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error during download: $e')));
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
        title: const Text('Symptom diary'),
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
                        'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
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
                        child: const Text('Change date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Список симптомів
                  const Text(
                    'Selected symptoms:',
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
                      hintText: 'Add description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: 'Description',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Кнопка збереження
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSymptoms,
                      child: const Text('Save symptoms'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
