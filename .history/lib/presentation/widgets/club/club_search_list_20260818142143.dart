// lib/presentation/widgets/club/club_search_list.dart
import 'package:flutter/material.dart';
import 'package:mafia_help/services/club_service.dart';
import 'package:mdi_plus/mdi_plus.dart';

class ClubSearchList extends StatefulWidget {
  final bool isDark;
  final Function(int) onClubSelected;

  const ClubSearchList({
    super.key,
    required this.isDark,
    required this.onClubSelected,
  });

  @override
  State<ClubSearchList> createState() => _ClubSearchListState();
}

class _ClubSearchListState extends State<ClubSearchList> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allClubs = [];
  List<Map<String, dynamic>> _filteredClubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    final result = await ClubService.getAllClubs();
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _allClubs =
            (result['clubs'] as List? ?? []).cast<Map<String, dynamic>>();
        _filteredClubs = List.from(_allClubs);
      }
    });
  }

  void _filterClubs(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filteredClubs = List.from(_allClubs);
      } else {
        _filteredClubs = _allClubs.where((club) {
          final title = club['title']?.toLowerCase() ?? '';
          final city = club['city']?.toLowerCase() ?? '';
          return title.contains(q) || city.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;

    return Stack(
      children: [
        // 🔥 СПИСОК КЛУБОВ
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allClubs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Клубы не найдены',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredClubs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ничего не найдено',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 80, // 🔥 ОТСТУП СВЕРХУ ДЛЯ ПОИСКА
                          bottom: 16,
                          left: 2,
                          right: 2,
                        ),
                        itemCount: _filteredClubs.length,
                        itemBuilder: (context, index) {
                          final club = _filteredClubs[index];
                          final isOfficial = club['is_official'] == true;
                          final isMember = club['is_member'] == true;
                          final isPending = club['is_pending'] == true;
                          final membersCount = club['members_count'] ??
                              club['judges_count'] ??
                              0;

                          return GestureDetector(
                            onTap: () => widget.onClubSelected(club['id']),
                            child: Card(
                              color: theme.cardColor,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: BorderSide.none,
                              ),
                              elevation: 8,
                              shadowColor: isOfficial
                                  ? Colors.amber.shade300.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        image: club['logo_url'] != null &&
                                                club['logo_url']
                                                    .toString()
                                                    .isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    club['logo_url']),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: club['logo_url'] == null ||
                                              club['logo_url']
                                                  .toString()
                                                  .isEmpty
                                          ? Image.asset(
                                              'assets/logo_new.png',
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.contain,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  club['title'] ??
                                                      'Без названия',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.textTheme
                                                            .bodyLarge?.color ??
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (isOfficial) ...[
                                                const SizedBox(width: 4),
                                                Icon(Icons.verified,
                                                    color: Colors.green,
                                                    size: 30),
                                              ],
                                            ],
                                          ),
                                          if (club['city'] != null &&
                                              club['city'].isNotEmpty)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  club['city'],
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: isDark
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade300,
                                                backgroundImage:
                                                    club['president_avatar'] !=
                                                                null &&
                                                            club['president_avatar']
                                                                .toString()
                                                                .isNotEmpty
                                                        ? NetworkImage(club[
                                                            'president_avatar'])
                                                        : null,
                                                child: club['president_avatar'] ==
                                                            null ||
                                                        club['president_avatar']
                                                            .toString()
                                                            .isEmpty
                                                    ? Text(
                                                        club['president_name']
                                                                ?.substring(
                                                                    0, 1)
                                                                .toUpperCase() ??
                                                            '?',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  club['president_name'] ??
                                                      'Неизвестен',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Mdi.accountGroup,
                                                size: 20,
                                                color: isDark
                                                    ? Colors.purple
                                                        .withOpacity(0.5)
                                                    : Colors.purple
                                                        .withOpacity(0.5),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$membersCount резидентов',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

        // 🔥 СТРОКА ПОИСКА (ПОВЕРХ СПИСКА, СВЕРХУ)
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // 🔥 90% ШИРИНЫ
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.92)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16), // 🔥 СКРУГЛЕНИЕ
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterClubs,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию или городу...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                  filled: true,
                  fillColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filterClubs('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
