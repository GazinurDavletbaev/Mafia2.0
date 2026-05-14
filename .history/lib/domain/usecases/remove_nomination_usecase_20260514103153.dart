// lib/domain/usecases/remove_nomination_usecase.dart

class RemoveNominationUsecase {
  RemoveNominationUsecase();
  
  List<int> execute(
    List<int> nominatedSeats,
    int seatNumber,
  ) {
    if (!nominatedSeats.contains(seatNumber)) return nominatedSeats;
    
    return nominatedSeats.where((seat) => seat != seatNumber).toList();
  }
}