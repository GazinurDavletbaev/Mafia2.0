// Стаб для веба — никогда не использует dart:io
Future<void> initPlatformSpecific() async {
  // На вебе ничего не делаем: окно не создаём, Hive.init с путём не вызываем
  // (hive_ce на вебе сам использует IndexedDB)
}
