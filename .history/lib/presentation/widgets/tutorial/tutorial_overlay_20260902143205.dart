// lib/presentation/widgets/tutorial/tutorial_overlay.dart
import 'package:flutter/material.dart';
import 'tutorials.dart';

class TutorialOverlay extends StatefulWidget {
  final TutorialStep step;
  final VoidCallback onClose;

  const TutorialOverlay({
    super.key,
    required this.step,
    required this.onClose,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final targetKey = step.targetKey;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: _buildContent(step, targetKey),
          ),
        );
      },
    );
  }

  Widget _buildContent(TutorialStep step, GlobalKey? targetKey) {
    final screenSize = MediaQuery.of(context).size;

    if (targetKey != null) {
      return _buildWithTarget(step, targetKey, screenSize);
    }

    if (step.customPosition != null) {
      return _buildWithPosition(step, screenSize);
    }

    return Center(child: _buildCard(step));
  }

  Widget _buildWithTarget(
    TutorialStep step,
    GlobalKey targetKey,
    Size screenSize,
  ) {
    return FutureBuilder<Rect?>(
      future: _getWidgetRect(targetKey),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final rect = snapshot.data!;
        final cardWidth = step.width ?? 280;
        final cardHeight = step.height ?? 120;

        final showAbove = rect.top > screenSize.height / 2;

        double left = (rect.left + rect.right) / 2 - cardWidth / 2;
        double top = showAbove ? rect.top - cardHeight - 20 : rect.bottom + 20;

        left = left.clamp(10, screenSize.width - cardWidth - 10);
        top = top.clamp(10, screenSize.height - cardHeight - 10);

        return Stack(
          children: [
            Positioned.fromRect(
              rect: rect,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: _buildCard(step),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWithPosition(TutorialStep step, Size screenSize) {
    final cardWidth = step.width ?? 280;
    final cardHeight = step.height ?? 120;
    final pos = step.customPosition!;

    return Stack(
      children: [
        Positioned(
          left: pos.dx.clamp(0, screenSize.width - cardWidth),
          top: pos.dy.clamp(0, screenSize.height - cardHeight),
          child: _buildCard(step),
        ),
      ],
    );
  }

  Future<Rect?> _getWidgetRect(GlobalKey key) async {
    await WidgetsBinding.instance.endOfFrame;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }

  Widget _buildCard(TutorialStep step) {
    return Container(
      width: step.width ?? 280,
      constraints: BoxConstraints(
        minHeight: step.height ?? 100,
        maxHeight: step.height ?? 140,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: step.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                step.icon,
                color: step.textColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    color: step.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _close,
                child: Icon(
                  Icons.close,
                  color: step.textColor.withOpacity(0.7),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            step.description,
            style: TextStyle(
              color: step.textColor.withOpacity(0.9),
              fontSize: 9,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
