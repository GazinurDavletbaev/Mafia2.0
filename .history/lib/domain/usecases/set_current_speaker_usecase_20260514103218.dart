// lib/domain/usecases/set_current_speaker_usecase.dart

class SetCurrentSpeakerUsecase {
  SetCurrentSpeakerUsecase();
  
  int? execute(
    int? currentSpeaker,
    int newSpeaker,
  ) {
    return newSpeaker;
  }
}