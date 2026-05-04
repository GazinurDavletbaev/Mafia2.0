import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RefContext on Ref {
  BuildContext get context {
    return (this as Ref).container.read(contextProvider);
  }
}

final contextProvider = Provider<BuildContext>((ref) {
  throw UnimplementedError('Context not set');
});