enum SubPhase {
  // Ночь 0
  se
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