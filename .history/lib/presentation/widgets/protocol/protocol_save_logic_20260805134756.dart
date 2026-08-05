import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/rules/game_history.dart';

class ProtocolSaveLogic {
  final GameState gameState;
  final WidgetRef ref;

  final List<TextEditingController> noteControllers =
      List.generate(