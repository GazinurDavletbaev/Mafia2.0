import 'package:flutter/material.dart';
import 'package:mdi_plus/mdi_plus.dart';

class SeatSearchOverlay {
  static OverlayEntry? _overlayEntry;
  static BuildContext? _context;
  static List<Map<String, dynamic>> _members = [];
  static Function(Map<String, dynamic>)? _onSelect;
  static VoidCallback? _onClose;
  static bool _isVisible = false;

  static bool get isVisible => _isVisible;

  static void show({
    required BuildContext context,
    required List<Map<String, dynamic>> members,
    required Function(Map<String, dynamic>) onSelect,
    required VoidCallback onClose,
  }) {
    _context = context;
    _members = members;
    _onSelect = onSelect;
    _onClose = onClose;
    _isVisible = true;
    _createOverlay();
  }

  static void update({
    required List<Map<String, dynamic>> members,
  }) {
    _members = members;
    if (_isVisible && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  static void close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
    if (_onClose != null) {
      _onClose!();
    }
  }

  static void _createOverlay() {
    _overlayEntry?.remove();

    final screenWidth = MediaQuery.of(_context!).size.width;
    final screenHeight = MediaQuery.of(_context!).size.height;
    final isDark = Theme.of(_context!).brightness == Brightness.dark;

    // 🔥 ПРИВОДИМ К DOUBLE
    final double overlayWidth =
        (screenWidth * 0.6 > 200 ? 200 : screenWidth * 0.6).toDouble();
    final double maxHeight = (screenHeight * 0.5).toDouble();

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: close,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Material(
              elevation: 8,
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: overlayWidth,
                constraints: BoxConstraints(maxHeight: maxHeight),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _members.length,
                  itemBuilder: (context, i) {
                    final member = _members[i];
                    final avatarUrl = member['avatar_url'];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            avatarUrl != null && avatarUrl.toString().isNotEmpty
                                ? Colors.transparent
                                : Colors.grey.shade300,
                        backgroundImage:
                            avatarUrl != null && avatarUrl.toString().isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                        child: avatarUrl == null || avatarUrl.toString().isEmpty
                            ? Icon(
                                Mdi.imageOff,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400,
                                size: 20,
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
                        if (_onSelect != null) {
                          _onSelect!(member);
                        }
                        close();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(_context!).insert(_overlayEntry!);
  }
}
