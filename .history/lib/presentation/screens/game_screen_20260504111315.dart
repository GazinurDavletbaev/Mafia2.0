class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(gameViewModelProvider);
    
    return Scaffold(
      body: Column(
        children: [
          PhaseHeader(phase: vm.currentPhase),
          Expanded(
            child: PlayerGrid(
              players: vm.players,
              onPlayerTap: vm.onPlayerTap,
              onPlayerLongPress: vm.onPlayerLongPress,
            ),
          ),
          PhaseButton(
            onBack: vm.onPhaseBack,
            onForward: vm.onPhaseForward,
          ),
        ],
      ),
    );
  }
}