// lib/domain/usecases/nominate_player_usecase.dart

import '../../data/local/models/player_model.dart';

class NominatePlayerUsecase {
  NominatePlayerUsecase();
  
  (List<PlayerModel>, List<int>) execute(
    List<PlayerModel> players,
    List<int> nominatedSeats,
    int seatNumber,
  ) {
    // Проверяем, жив ли игрок
    final player = players.firstWhere((p) => p.seatNumber == seatNumber);
    if (!player.isAlive) return (players, nominatedSeats);
    
    // Проверяем, не выставлен ли уже
    if (nominatedSeats.contains(seatNumber)) return (players, nominatedSeats);
    
    // Добавляем в список выставленных
    final newNominatedSeats = List<int>.from(nominatedSeats)..add(seatNumber);
    
    return (players, newNominatedSeats);
  }
}