class VoteCalculator extends StatelessWidget {
  final VoteCalculatorController controller;
  final VoidCallback onClose;
  final ValueChanged<int> onVoteEntered;

  const VoteCalculator({...});

  @override
  Widget build(BuildContext context) {
    if (!controller.isVisible) return const SizedBox.shrink();
    
    return Draggable(  // можно перемещать, но без сохранения позиции
      child: Container(
        // кнопки 0-10, текущий кандидат, навигация
      ),
    );
  }
}