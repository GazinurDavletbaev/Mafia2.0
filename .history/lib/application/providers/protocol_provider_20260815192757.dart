final checkGameExistsUsecaseProvider = Provider<CheckGameExistsUsecase>((ref) {
  return CheckGameExistsUsecase(ref.read(protocolRepositoryProvider));
});