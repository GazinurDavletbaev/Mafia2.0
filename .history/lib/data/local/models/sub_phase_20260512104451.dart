enum SubPhase {
  // Ночь
  roleDistribution,
  contract,
  sheriffLook,
  mafiaShoot,
  donCheck,
  sheriffCheck,
  
  // День
  speeches,        // речи игроков (с указанием номера речи)
  voting,          // голосование
  revote,          // переголосование
  tieBreak,        // перестрелка
  eliminationVote, // голосование за подъём
  finalWord,       // заключительная минута
  bestMove,        // лучший ход (только если было убийство)
}