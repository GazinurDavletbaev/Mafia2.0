import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';
import 'package:mafia_help/application/providers/vote_providers.dart';

class VoteBottomSheet extends ConsumerStatefulWidget {
  final VoteController controller;
  final Function(int) onVoteSubmitted;
  final VoidCallback onComplete;

  const VoteBottomSheet({
    super.key,
    required this.controller,
    required this.onVoteSubmitted,
    required this.onComplete,
  });

  @override
  ConsumerState<VoteBottomSheet> createState() => _VoteBottomSheetState();
}

class _VoteBottomSheetState extends ConsumerState<VoteBottomSheet> {
  late VoteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Текущий кандидат
              Text(
                'Кандидат: место ${_controller.currentSeat}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Текущие голоса: ${_controller.currentVotes ?? 0}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // Кнопки 0-10
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 11,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _controller.setVotes(index);
                          setState(() {});
                          widget.onVoteSubmitted(index);
                          if (_controller.isComplete) {
                            widget.onComplete();
                          } else {
                            _controller.nextCandidate();
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          index.toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Навигация
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _controller.currentIndex > 0
                          ? () {
                              _controller.previousCandidate();
                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Назад'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onComplete();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Завершить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}