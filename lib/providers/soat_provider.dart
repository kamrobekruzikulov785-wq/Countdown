// Ilovaning "soati": har soniyada bir marta "tiqillaydi".
//
// Barcha sanoqlar shu BITTA taymerdan yangilanadi. Har bir kartochkaga
// alohida taymer qo'yilsa, telefon ortiqcha ishlab, batareya tez tugaydi.

import 'dart:async';

import 'package:flutter/foundation.dart';

class SoatProvider extends ChangeNotifier {
  SoatProvider() {
    _taymer = Timer.periodic(const Duration(seconds: 1), (_) {
      _hozir = DateTime.now();
      notifyListeners(); // tinglayotgan ekranlarga "vaqt yangilandi" deydi
    });
  }

  late final Timer _taymer;
  DateTime _hozir = DateTime.now();

  /// Joriy vaqt (har soniyada yangilanadi).
  DateTime get hozir => _hozir;

  @override
  void dispose() {
    _taymer.cancel(); // ilova yopilganda taymer to'xtatiladi
    super.dispose();
  }
}
