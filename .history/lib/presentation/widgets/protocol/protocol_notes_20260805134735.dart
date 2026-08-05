import 'package:flutter/material.dart';

class ProtocolNotes extends StatelessWidget {
  final List<TextEditingController> noteControllers;
  final TextEditingController protestCommentController;

  const ProtocolNotes({
    super.key,
    required this.noteControllers,
    required this.protestCommentController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ПОЯСНЕНИЯ К ДОПОЛНИТЕЛЬНЫМ БАЛЛАМ И ШТРАФАМ',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(10, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: noteControllers[index],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: '___________________',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'КОММЕНТАРИЙ К ПРОТЕСТУ:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextFormField(
                controller: protestCommentController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Введите комментарий к протесту...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey.shade700.withOpacity(0.3)
                      : Colors.grey.shade200.withOpacity(0.5),
                  contentPadding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}