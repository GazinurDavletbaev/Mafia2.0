// lib/application/providers/rules_providers.dart

import 'package:riverpod/riverpod.dart';
import '../../domain/rules/player_rules.dart';
import '../../domain/rules/win_rules.dart';
import '../../domain/rules/voting_rules.dart';
import '../../domain/rules/speech_rules.dart';
import '../../domain/rules/phase_rules.dart';

final playerRulesProvider = Provider<PlayerRules>((ref) {
  return PlayerRules();
});

final winRulesProvider = Provider<WinCH>((ref) {
  return WinRules();
});

final votingRulesProvider = Provider<VotingRules>((ref) {
  return VotingRules();
});

final speechRulesProvider = Provider<SpeechRules>((ref) {
  return SpeechRules();
});

final phaseRulesProvider = Provider<PhaseRules>((ref) {
  return PhaseRules();
});