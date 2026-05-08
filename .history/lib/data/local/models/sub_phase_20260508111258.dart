enum SubPhase {
  // Первая ночь
  roleDistribution,
  contract,
  sheriffLook,
  
  // Обычная ночь (со 2-й)
  mafiaShoot,
  donCheck,
  sheriffCheck,
  
  // День
  bestMove,
  speeches,
  voting,
  revote,
  eliminationVote,
  finalWord,
  tieBreak, // перестрелка (30 сек кандидатам)

}