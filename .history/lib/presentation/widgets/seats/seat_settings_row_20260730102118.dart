import 'package:flutter/material.dart';

class SeatSettingsRow extends StatelessWidget {
  final TextEditingController tournamentController;
  final TextEditingController stageController;
  final TextEditingController tableController;
  final TextEditingController gameController;
  final DateTime selectedDate;
  final List<String> months;
  final VoidCallback onDateTap;
  final VoidCallback onChanged;

  const SeatSettingsRow({
    super.key,
    required this.tournamentController,
    required this.stageController,
    required this.tableController,
    required this.gameController,
    required this.selectedDate,
    required this.months,
    required this.onDateTap,
  onChanged: notifier.notifyChanges,  // ← публичный метод
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Первая строка: Турнир + Стол + Игра
          Row(
            children: [
              Flexible(
                flex: 4,
                child: _buildSmallTextField(
                  context,
                  controller: tournamentController,
                  label: 'Турнир',
                  hint: 'РЕЙТИНГ',
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: _buildSmallTextField(
                  context,
                  controller: tableController,
                  label: 'Стол',
                  hint: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: _buildSmallTextField(
                  context,
                  controller: gameController,
                  label: 'Игра',
                  hint: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Вторая строка: Стадия + Дата
          Row(
            children: [
              Flexible(
                flex: 4,
                child: _buildSmallTextField(
                  context,
                  controller: stageController,
                  label: 'Стадия',
                  hint: months[DateTime.now().month - 1],
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: InkWell(
                  onTap: onDateTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            selectedDate.toString().substring(0, 10),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color ?? Colors.white,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey : Colors.grey.shade600,
          fontSize: 10,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          fontSize: 11,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade700 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        isDense: true,
      ),
    );
  }
}