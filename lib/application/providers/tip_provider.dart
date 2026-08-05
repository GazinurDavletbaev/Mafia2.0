// lib/application/providers/tip_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final tipsEnabledProvider = StateProvider<bool>((ref) => true);

final dismissedTipsProvider = StateProvider<Set<String>>((ref) => const {});