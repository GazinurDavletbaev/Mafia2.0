Future<void> onTimerComplete() async {
  final subPhase = state.currentSubPhase;
  final currentSpeaker = state.currentSpeakerSeat;

  AppLogger.d('onTimerComplete: subPhase=$subPhase, currentSpeaker=$currentSpeaker');

  if (subPhase == SubPhase.speeches && currentSpeaker != null) {
    await nextSpeaker();
  } else if (subPhase == SubPhase.tieBreak) {
    await onNextTieCandidate();
  } else if (subPhase == SubPhase.finalWord && currentSpeaker != null) {
    await onPhaseForward();
  } else if (subPhase == SubPhase.contract) {
    // Ничего не делаем
  } else if (subPhase == SubPhase.sheriffLook || subPhase == SubPhase.sheriffCheck || subPhase == SubPhase.donCheck) {
    await onPhaseForward();
  } else if (subPhase == SubPhase.bestMove && currentSpeaker != null) {
    // После лучшего хода → заключительная минута
    await setCurrentSpeaker(currentSpeaker);
    await onPhaseForward();
  }
}