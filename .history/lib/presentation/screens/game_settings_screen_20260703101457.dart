import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'seat_setup_screen.dart';

class GameSettingsScreen extends ConsumerStatefulWidget {
  const GameSettingsScreen({super.key});
  final Function(int, int, DateTime, String, String, String)? onSettingsSaved;

  @override
  ConsumerState<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends ConsumerState<GameSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tableController = TextEditingController(text: '1');
  final _gameController = TextEditingController(text: '1');
  final _judgeController = TextEditingController();
  final _tournamentController = TextEditingController(text: 'РЕЙТИНГ');
  final _stageController = TextEditingController(
      text: [
    'ЯНВАРЬ',
    'ФЕВРАЛЬ',
    'МАРТ',
    'АПРЕЛЬ',
    'МАЙ',
    'ИЮНЬ',
    'ИЮЛЬ',
    'АВГУСТ',
    'СЕНТЯБРЬ',
    'ОКТЯБРЬ',
    'НОЯБРЬ',
    'ДЕКАБРЬ'
  ][DateTime.now().month - 1]);
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _tableController.dispose();
    _gameController.dispose();
    _judgeController.dispose();
    _tournamentController.dispose();
    _stageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Настройки игры'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildTextField(
                context,
                controller: _tournamentController,
                label: 'Турнир',
                hint: 'Введите название турнира',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _stageController,
                label: 'Стадия',
                hint: 'Введите название стадии',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context,
                controller: _tableController,
                label: 'Номер стола',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context,
                controller: _gameController,
                label: 'Номер игры',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDateTimePicker(context),
              const SizedBox(height: 16),
              _buildTextField(
                context,
                controller: _judgeController,
                label: 'Судья (никнейм)',
                hint: 'Введите имя судьи',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ДАЛЕЕ →',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color ?? Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey : Colors.grey.shade600,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _selectDateTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate.toString().substring(0, 16),
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.black,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.orange,
                onPrimary: Colors.black,
                surface: Colors.grey,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatSetupScreen(
            tableNumber: int.parse(_tableController.text),
            gameNumber: int.parse(_gameController.text),
            date: _selectedDate,
            judgeName: _judgeController.text,
            tournamentName: _tournamentController.text,
            stageName: _stageController.text,
          ),
        ),
      );
    }
  }
}