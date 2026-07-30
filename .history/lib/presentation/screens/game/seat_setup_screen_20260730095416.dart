// lib/presentation/screens/game/seat_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/lobby/lobby_data.dart';
import 'package:mafia_help/presentation/widgets/game/game_new_button.dart';
import 'package:mafia_help/services/club_service.dart';
import 'package:mafia_help/application/providers/club_provider.dart';

class SeatSetupScreen extends ConsumerStatefulWidget {
  final GameData initialData;
  final Function(GameData) onNamesChanged;

  const SeatSetupScreen({
    super.key,
    required this.initialData,
    required this.onNamesChanged,
  });

  @override
  ConsumerState<SeatSetupScreen> createState() => _SeatSetupScreenState();
}

class _SeatSetupScreenState extends ConsumerState<SeatSetupScreen> {
  // ===== КОНТРОЛЛЕРЫ ДЛЯ ИМЁН =====
  late List<TextEditingController> _nameControllers;
  late List<Map<String, dynamic>?> _selectedPlayers;
  List<Map<String, dynamic>> _clubMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  int _focusedIndex = -1;
  String _searchQuery = '';
  final List<GlobalKey> _textFieldKeys =
      List.generate(10, (index) => GlobalKey());
  OverlayEntry? _overlayEntry;

  // ===== КОНТРОЛЛЕРЫ ДЛЯ НАСТРОЕК =====
  late TextEditingController _tournamentController;
  late TextEditingController _stageController;
  late TextEditingController _tableController;
  late TextEditingController _gameController;
  late DateTime _selectedDate;

  final List<String> _months = [
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
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initSettingsControllers();
    _loadClubMembers();
  }

  void _initControllers() {
    _nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: widget.initialData.playerNames.length > index
            ? widget.initialData.playerNames[index]
            : '',
      );
    });
    _selectedPlayers = List.generate(10, (index) => null);
  }

  void _initSettingsControllers() {
    final initialStage = widget.initialData.stageName.isNotEmpty
        ? widget.initialData.stageName
        : _months[DateTime.now().month - 1];

    _tournamentController = TextEditingController(
      text: widget.initialData.tournamentName,
    );
    _stageController = TextEditingController(
      text: initialStage,
    );
    _tableController = TextEditingController(
      text: widget.initialData.tableNumber.toString(),
    );
    _gameController = TextEditingController(
      text: widget.initialData.gameNumber.toString(),
    );
    _selectedDate = widget.initialData.date;
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    _tournamentController.dispose();
    _stageController.dispose();
    _tableController.dispose();
    _gameController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  // ===== СБРОС =====
  void _resetSeats() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    for (var controller in _nameControllers) {
      controller.clear();
    }

    setState(() {
      _selectedPlayers = List.generate(10, (index) => null);
      _focusedIndex = -1;
      _searchQuery = '';
      _filteredMembers = List.from(_clubMembers);
    });

    _notifyChanges();
  }

  // ===== ФИЛЬТРАЦИЯ ДЛЯ ПОИСКА =====
  void _updateFilteredList() {
    final q = _searchQuery.toLowerCase().trim();
    setState(() {
      final takenUsernames = <String>{};
      for (int i = 0; i < _selectedPlayers.length; i++) {
        if (_focusedIndex >= 0 && i == _focusedIndex) continue;

        final selected = _selectedPlayers[i];
        if (selected != null) {
          final username = selected['username'];
          if (username != null && username.isNotEmpty) {
            takenUsernames.add(username);
          }
        }
      }

      if (q.isEmpty) {
        _filteredMembers = _clubMembers
            .where((m) => !takenUsernames.contains(m['username']))
            .toList();
      } else {
        _filteredMembers = _clubMembers
            .where((m) =>
                (m['username'] ?? '').toLowerCase().contains(q) &&
                !takenUsernames.contains(m['username']))
            .toList();
      }
    });
  }

  // ===== ОВЕРЛЕЙ ДЛЯ ПОИСКА =====
  void _showOverlay(BuildContext context, int index) {
    _overlayEntry?.remove();

    final renderBox =
        _textFieldKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final width = renderBox.size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _updateFilteredList();

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeOverlay,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + 50,
              left: offset.dx,
              width: width,
              child: Material(
                elevation: 8,
                color: isDark ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _filteredMembers.length,
                    itemBuilder: (context, i) {
                      final member = _filteredMembers[i];
                      final avatarUrl = member['avatar_url'];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: avatarUrl != null &&
                                  avatarUrl.toString().isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child:
                              avatarUrl == null || avatarUrl.toString().isEmpty
                                  ? Image.asset(
                                      'assets/mafia_logo.png',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                    )
                                  : null,
                        ),
                        title: Text(
                          member['username'] ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPlayers[index] = member;
                            _nameControllers[index].text =
                                member['username'] ?? '';
                            _filteredMembers = [];
                            _focusedIndex = -1;
                            _searchQuery = '';
                          });
                          _closeOverlay();
                          _notifyChanges();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _filteredMembers = [];
      _focusedIndex = -1;
      _searchQuery = '';
    });
  }

  // ===== ЗАГРУЗКА УЧАСТНИКОВ КЛУБА =====
  Future<void> _loadClubMembers() async {
    final clubAsync = ref.read(clubProvider);
    final club = clubAsync.value;
    if (club == null) return;

    final membersResult = await ClubService.getClubMembers(club['id']);
    final List<Map<String, dynamic>> allPlayers = [];

    if (membersResult['success']) {
      final members = (membersResult['members'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      allPlayers.addAll(members);
    }

    final now = DateTime.now();
    final ratingResult = await ClubService.getClubRating(
      clubId: club['id'],
      month: now.month,
      year: now.year,
    );

    if (ratingResult['success'] && ratingResult['has_games'] == true) {
      final ratingPlayers =
          (ratingResult['players'] as List? ?? []).cast<Map<String, dynamic>>();

      for (var player in ratingPlayers) {
        final username = player['username'] ?? '';
        final alreadyExists = allPlayers.any((m) => m['username'] == username);

        if (!alreadyExists) {
          allPlayers.add({
            'id': null,
            'username': username,
            'avatar_url': null,
            'email': null,
            'is_president': false,
            'is_judge': false,
            'joined_at': null,
          });
        }
      }
    }

    setState(() {
      _clubMembers = allPlayers;
      _filteredMembers = List.from(allPlayers);
    });
  }

  // ===== УВЕДОМЛЕНИЕ ОБ ИЗМЕНЕНИЯХ =====
  void _notifyChanges() {
    final names = _nameControllers.map((c) => c.text.trim()).toList();

    final updatedPlayers =
        widget.initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final newName = names.length > index ? names[index] : player.name;
      final oldName = player.name;

      if (newName == oldName) {
        return player;
      }

      final selected = _selectedPlayers[index];
      final int? userId = selected != null ? selected['id'] as int? : null;
      final String? avatarUrl =
          (userId != null) ? selected!['avatar_url'] as String? : '';

      return player.copyWith(
        name: newName,
        avatarUrl: avatarUrl,
        userId: userId,
      );
    }).toList();

    final updatedGameState = widget.initialData.gameState.copyWith(
      players: updatedPlayers,
      tournamentName: _tournamentController.text,
      stageName: _stageController.text,
      tableNumber: int.tryParse(_tableController.text) ?? 1,
      gameNumber: int.tryParse(_gameController.text) ?? 1,
      gameDate: _selectedDate,
    );

    widget.onNamesChanged(
      GameData(
        tournamentName: _tournamentController.text,
        stageName: _stageController.text,
        tableNumber: int.tryParse(_tableController.text) ?? 1,
        gameNumber: int.tryParse(_gameController.text) ?? 1,
        date: _selectedDate,
        judgeName: widget.initialData.judgeName,
        playerNames: names,
        gameState: updatedGameState,
        gameHistory: widget.initialData.gameHistory,
      ),
    );
  }

  // ===== ВЫБОР ДАТЫ =====
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
          _stageController.text = _months[_selectedDate.month - 1];
          _notifyChanges();
        });
      }
    }
  }

  // ===== ПОСТРОЕНИЕ =====
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    // Обновляем контроллеры если изменились данные
    for (int i = 0; i < 10; i++) {
      final savedName = widget.initialData.playerNames.length > i
          ? widget.initialData.playerNames[i]
          : '';
      if (_nameControllers[i].text != savedName) {
        _nameControllers[i].text = savedName;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ===== ИГРОКИ =====
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildColumn(leftSeats, isLeft: true),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildColumn(rightSeats, isLeft: false),
                  ),
                ],
              ),
            ),
            // ===== НАСТРОЙКИ (5 ПОЛЕЙ) =====
            const SizedBox(height: 8),
            _buildSettingsRow(),
            const SizedBox(height: 8),
            // ===== КНОПКА НОВАЯ ИГРА =====
            GameNewButton(
              label: 'СОЗДАТЬ НОВУЮ ИГРУ',
              isFullWidth: true,
              onNewGame: _resetSeats,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ===== СТРОКА С НАСТРОЙКАМИ =====
  Widget _buildSettingsRow() {
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
          // Первая строка: Турнир + Стадия
          Row(
            children: [
              Flexible(
                flex: 4,
                child: _buildSmallTextField(
                  context,
                  controller: _tournamentController,
                  label: 'Турнир',
                  hint: 'РЕЙТИНГ',
                  onChanged: (_) => _notifyChanges(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: _buildSmallTextField(
                  context,
                  controller: _tableController,
                  label: 'Стол',
                  hint: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _notifyChanges(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: _buildSmallTextField(
                  context,
                  controller: _gameController,
                  label: 'Игра',
                  hint: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _notifyChanges(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Вторая строка: Стол + Игра + Дата
          Row(
            children: [
              Flexible(
                flex: 4,
                child: _buildSmallTextField(
                  context,
                  controller: _stageController,
                  label: 'Стадия',
                  hint: _months[DateTime.now().month - 1],
                  onChanged: (_) => _notifyChanges(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: InkWell(
                  onTap: () => _selectDateTime(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                            _selectedDate.toString().substring(0, 10),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color ??
                                  Colors.white,
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

  // ===== КОЛОНКА С ИГРОКАМИ =====
  Widget _buildColumn(List<int> seats, {required bool isLeft}) {
    return Column(
      children: seats.map((seat) {
        final index = seat - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$seat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _buildTextField(index, seat, isLeft),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(int index, int seat, bool isLeft) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = _nameControllers[index];
    final key = _textFieldKeys[index];

    return Container(
      key: key,
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color ?? Colors.white,
          fontSize: 13,
        ),
        onChanged: (value) {
          _searchQuery = value;
          _focusedIndex = index;
          _updateFilteredList();
          _notifyChanges();

          if (_overlayEntry != null) {
            _showOverlay(context, index);
          }
        },
        onTap: () {
          _focusedIndex = index;
          _searchQuery = controller.text;
          _updateFilteredList();
          _showOverlay(context, index);
        },
        decoration: InputDecoration(
          hintText: 'Игрок $seat',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            fontSize: 12,
          ),
          filled: true,
          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          isDense: true,
        ),
        textAlign: isLeft ? TextAlign.left : TextAlign.right,
      ),
    );
  }
}
