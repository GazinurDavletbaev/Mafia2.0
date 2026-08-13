enum SubPhase {
  // Ночь 0
  seatSetup,
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