// lib/data/local/models/sub_phase.dart

enum SubPhase {
  // Ночь 0
  roleDistribution,
  contract,
  sheriffLook,
  freeSeating,
  
  // Ночь 1+
  mafiaShoot,
  donCheck,
  sheriffCheck,
  
  // День
  speeches,
  voting,
  revote,
  tieBreak,
  eliminationVote,
  finalWord,
}