// lib/data/local/sources/protocol_local_source.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mafia_help/domain/entities/game_protocol.dart';

class ProtocolLocalSource {
  static const String _folderName = 'protocols';

  // 🔥 ПОЛУЧИТЬ ПУТЬ К ПАПКЕ
  Future<Directory> _getDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // 🔥 СОХРАНИТЬ ПРОТОКОЛ
  Future<void> saveProtocol(GameProtocol protocol) async {
    final dir = await _getDirectory();
    final fileName =
        '${protocol.date.toIso8601String()}_${protocol.table}_${protocol.game}.json';
    final file = File('${dir.path}/$fileName');
    final json = protocol.toJson();
    await file.writeAsString(jsonEncode(json));
  }

  // 🔥 ПОЛУЧИТЬ ВСЕ ПРОТОКОЛЫ
  Future<List<GameProtocol>> getAllProtocols() async {
    final dir = await _getDirectory();
    final files = dir.listSync();
    final List<GameProtocol> protocols = [];

    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final jsonString = await file.readAsString();
          final Map<String, dynamic> data = jsonDecode(jsonString);
          final protocol = GameProtocol.fromJson(data);
          protocols.add(protocol);
        } catch (e) {
          print('❌ Ошибка чтения файла: $e');
        }
      }
    }

    // Сортируем по дате (новые сверху)
    protocols.sort((a, b) => b.date.compareTo(a.date));
    return protocols;
  }

  // 🔥 ПОЛУЧИТЬ ПРОТОКОЛ ПО ПАРАМЕТРАМ
  Future<GameProtocol?> getProtocol({
    required DateTime date,
    required int table,
    required int game,
  }) async {
    final protocols = await getAllProtocols();
    for (final protocol in protocols) {
      final bool sameDate = protocol.date.year == date.year &&
          protocol.date.month == date.month &&
          protocol.date.day == date.day;
      final bool sameTable = protocol.table == table;
      final bool sameGame = protocol.game == game;

      if (sameDate && sameTable && sameGame) {
        return protocol;
      }
    }
    return null;
  }

  // 🔥 УДАЛИТЬ ПРОТОКОЛ
  Future<void> deleteProtocol({
    required DateTime date,
    required int table,
    required int game,
  }) async {
    final dir = await _getDirectory();
    final fileName =
        '${date.toIso8601String()}_${table}_${game}.json';
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }
}