// Условный импорт: на вебе — stub, на десктопе/мобайле — real
import 'io_stub.dart' if (dart.library.io) 'io_real.dart' as impl;

Future<void> initPlatformSpecific() => impl.initPlatformSpecific();
