import 'package:flutter/material.dart';

class SeatSearchOverlay {
  static OverlayEntry? _overlayEntry;

  static void show({
    required BuildContext context,
    required GlobalKey textFieldKey,
    required List<Map<String, dynamic>> members,
    required Function(Map<String, dynamic>) onSelect,
    required VoidCallback onClose,
  }) {
    _overlayEntry?.remove();

    final renderBox = textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final width = renderBox.size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: onClose,
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
                    itemCount: members.length,
                    itemBuilder: (context, i) {
                      final member = members[i];
                      final avatarUrl = member['avatar_url'];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: avatarUrl != null &&
                                  avatarUrl.toString().isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null || avatarUrl.toString().isEmpty
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
                          onSelect(member);
                          _overlayEntry?.remove();
                          _overlayEntry = null;
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

  static void close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static bool get isVisible => _overlayEntry != null;
}