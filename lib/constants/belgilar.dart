// Har bir hodisa turi uchun belgi (ikonka).

import 'package:material_ui/material_ui.dart';

import '../models/hodisa.dart';

/// Hodisa turiga mos belgini qaytaradi.
IconData turBelgisi(HodisaTuri tur) {
  switch (tur) {
    case HodisaTuri.imtihon:
      return Icons.school_outlined;
    case HodisaTuri.tadbir:
      return Icons.event_outlined;
    case HodisaTuri.tugilganKun:
      return Icons.cake_outlined;
    case HodisaTuri.boshqa:
      return Icons.star_outline;
  }
}
