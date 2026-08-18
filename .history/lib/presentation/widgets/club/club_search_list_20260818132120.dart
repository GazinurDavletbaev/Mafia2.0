// lib/presentation/widgets/club/club_search_list.dart
import 'package:flutter/material.dart';
import 'package:mafia_help/services/club_service.dart';

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
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
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
            ),
          ),
        ),
        Expanded(
          child: _isLoading
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
                          padding: const EdgeInsets.all(2),
                          itemCount: _filteredClubs.length,
                          itemBuilder: (context, index) {
                            final club = _filteredClubs[index];
                            final isOfficial = club['is_official'] == true;
                            final isMember = club['is_member'] == true;
                            final isPending = club['is_pending'] == true;

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
                                      // 🔥 АВАТАРКА КЛУБА
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.black
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(28),
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: theme
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color ??
                                                          Colors.white,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isOfficial) ...[
                                                  const SizedBox(width: 4),
                                                  Icon(Icons.verified,
                                                      color: theme.primaryColor,
                                                      size: 24),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            if (club['city'] != null &&
                                                club['city'].isNotEmpty)
                                              Text(
                                                '📍 ${club['city']}',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            Text(
                                              '👤 ${club['president_name'] ?? 'Неизвестен'}',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              '👥 ${club['judges_count'] ?? 0} участников',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isMember)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            '✅ Состою',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      else if (isPending)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.orange.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            '⏳ Заявка',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
