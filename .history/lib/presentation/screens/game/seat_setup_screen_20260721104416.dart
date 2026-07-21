// lib/presentation/screens/game/seat_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/lobby_screen.dart';
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
  late List<TextEditingController> _nameControllers;
  late List<Map<String, dynamic>?> _selectedPlayers;
  List<Map<String, dynamic>> _clubMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  int _focusedIndex = -1;
  final List<GlobalKey> _textFieldKeys =
      List.generate(10, (index) => GlobalKey());
  OverlayEntry? _overlayEntry;
  @override
  void initState() {
    super.initState();
    _nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: widget.initialData.playerNames.length > index
            ? widget.initialData.playerNames[index]
            : '',
      );
    });
    _selectedPlayers =
        List.generate(10, (index) => null); // ← ДОБАВЬ ЭТУ СТРОКУ

    _loadClubMembers();
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
      _closeOverlay();

    super.dispose();
  }

  void _showOverlay(BuildContext context, int index) {
    // Закрываем старый оверлей
    _overlayEntry?.remove();

    final renderBox =
        _textFieldKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final width = renderBox.size.width;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _closeOverlay();
        },
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
    });
  }

  Future<void> _loadClubMembers() async {
    final clubAsync = ref.read(clubProvider);
    final club = clubAsync.value;
    if (club == null) return;

    // 1. Загружаем участников клуба
    final membersResult = await ClubService.getClubMembers(club['id']);
    final List<Map<String, dynamic>> allPlayers = [];

    if (membersResult['success']) {
      final members = (membersResult['members'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      allPlayers.addAll(members);
    }

    // 2. Загружаем рейтинг за текущий месяц
    final now = DateTime.now();
    final ratingResult = await ClubService.getClubRating(
      clubId: club['id'],
      month: now.month,
      year: now.year,
    );

    if (ratingResult['success'] && ratingResult['has_games'] == true) {
      final ratingPlayers =
          (ratingResult['players'] as List? ?? []).cast<Map<String, dynamic>>();

      // Добавляем игроков из рейтинга, которых ещё нет в списке
      for (var player in ratingPlayers) {
        final username = player['username'] ?? '';
        final alreadyExists = allPlayers.any((m) => m['username'] == username);

        if (!alreadyExists) {
          allPlayers.add({
            'id': null, // ← нет user_id
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
    });
  }

  void _notifyChanges() {
    final names = _nameControllers.map((c) => c.text.trim()).toList();
    final avatars =
        _selectedPlayers.map((p) => p?['avatar_url']).toList(); // ✅ ДОБАВИТЬ

    final updatedPlayers =
        widget.initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final name = names.length > index ? names[index] : player.name;
      final avatar =
          avatars.length > index ? avatars[index] : player.avatarUrl; // ✅
      return player.copyWith(
        name: name,
        avatarUrl: avatar, // ✅
      );
    }).toList();

    final updatedGameState = widget.initialData.gameState.copyWith(
      players: updatedPlayers,
    );

    widget.onNamesChanged(
      GameData(
        tournamentName: widget.initialData.tournamentName,
        stageName: widget.initialData.stageName,
        tableNumber: widget.initialData.tableNumber,
        gameNumber: widget.initialData.gameNumber,
        date: widget.initialData.date,
        judgeName: widget.initialData.judgeName,
        playerNames: names,
        gameState: updatedGameState,
        gameHistory: widget.initialData.gameHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    // Восстанавливаем имена при возврате
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
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<int> seats, {required bool isLeft}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: seats.map((seat) {
        final index = seat - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(index, seat, isLeft),
                ),
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
    final key = _textFieldKeys[index]; // ← уникальный ключ для каждого поля

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: key,
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color ?? Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _focusedIndex = index;
                final q = value.toLowerCase().trim();
                if (q.isNotEmpty) {
                  _filteredMembers = _clubMembers
                      .where((m) =>
                          (m['username'] ?? '').toLowerCase().contains(q))
                      .toList();
                } else {
                  _filteredMembers = [];
                }
              });
              _notifyChanges();
            },
            onTap: () {
              setState(() {
                _focusedIndex = index;
                final q = controller.text.toLowerCase().trim();
                _filteredMembers = _clubMembers
                    .where(
                        (m) => (m['username'] ?? '').toLowerCase().contains(q))
                    .toList();
              });
              _showOverlay(context, index); // ← показываем список через Overlay
            },
            decoration: InputDecoration(
              hintText: 'Игрок $seat',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            textAlign: isLeft ? TextAlign.left : TextAlign.right,
          ),
        ),
      ],
    );
  }
}
