import 'package:flutter/material.dart';
import '../models/coffee_log.dart';

class AddCoffeeDialog extends StatefulWidget {
  const AddCoffeeDialog({super.key});

  @override
  State<AddCoffeeDialog> createState() => _AddCoffeeDialogState();
}

class _AddCoffeeDialogState extends State<AddCoffeeDialog> {
  CoffeeType _selectedType = CoffeeType.espresso;
  CoffeeLocation _selectedLocation = CoffeeLocation.home;
  DateTime _selectedDateTime = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(now);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime _getCombinedDateTime() {
    return DateTime(
      _selectedDateTime.year,
      _selectedDateTime.month,
      _selectedDateTime.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_cafe,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Logger un café',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Sélection du type de café
            Text(
              'Type de café',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<CoffeeType>(
                value: _selectedType,
                isExpanded: true,
                underline: const SizedBox(),
                items: CoffeeType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(type.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Sélection du lieu
            Text(
              'Lieu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<CoffeeLocation>(
                value: _selectedLocation,
                isExpanded: true,
                underline: const SizedBox(),
                items: CoffeeLocation.values.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Row(
                      children: [
                        Text(location.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(location.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Sélection de la date et de l'heure
            Text(
              'Date et heure',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final log = CoffeeLog(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: _selectedType,
                      location: _selectedLocation,
                      timestamp: _getCombinedDateTime(),
                    );
                    Navigator.of(context).pop(log);
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
