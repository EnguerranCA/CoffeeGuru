import 'package:flutter/material.dart';

class CaffeineProgressBar extends StatelessWidget {
  final int currentCaffeine;
  final int dailyLimit;

  const CaffeineProgressBar({
    super.key,
    required this.currentCaffeine,
    this.dailyLimit = 400,
  });

  Color _getProgressColor(double percentage) {
    if (percentage < 50) {
      return Colors.green;
    } else if (percentage < 80) {
      return Colors.yellow.shade700;
    } else if (percentage < 100) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getStatusMessage(double percentage) {
    if (percentage < 50) {
      return 'Vous êtes dans les clous ! 👍';
    } else if (percentage < 80) {
      return 'Attention à ne pas trop en abuser 😊';
    } else if (percentage < 100) {
      return 'Vous approchez de la limite ! ⚠️';
    } else {
      return 'Limite dépassée ! 🚨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (currentCaffeine / dailyLimit * 100).clamp(0.0, 200.0);
    final progressValue = (currentCaffeine / dailyLimit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.local_drink, color: Color(0xFF6B4423), size: 20),
                SizedBox(width: 8),
                Text(
                  'Caféine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B4423),
                  ),
                ),
              ],
            ),
            Text(
              '$currentCaffeine / $dailyLimit mg',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getProgressColor(percentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 20,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(percentage),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getStatusMessage(percentage),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getProgressColor(percentage),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
