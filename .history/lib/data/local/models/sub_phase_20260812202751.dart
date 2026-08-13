enum SubPhase {
  // Ночь 0
  seat
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
  finalWordKill,
  bestMove,  // ← добавить
}