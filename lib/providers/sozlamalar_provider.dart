// Sozlamalar holati: foydalanuvchi ismi, mavzu va standart eslatma.
//
// Ilova ochilishida (main.dart) bir marta yuklanadi. Biror sozlama
// o'zgarsa, darhol ekranga ta'sir qiladi (notifyListeners) va bazaga yoziladi.

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../data/sozlamalar_repository.dart';
import '../models/hodisa.dart';

class SozlamalarProvider extends ChangeNotifier {
  SozlamalarProvider({SozlamalarRepository? repository})
      : _repository = repository ?? SozlamalarRepository();

  final SozlamalarRepository _repository;

  static const int ismMaxUzunlik = 30;

  String _ism = '';
  ThemeMode _mavzu = ThemeMode.system;
  EslatmaOraligi _standartEslatma = EslatmaOraligi.birKunOldin;

  /// Salomlashuvda ko'rsatiladigan ism. Bo'sh bo'lishi mumkin.
  String get ism => _ism;

  /// Mavzu: telefon bo'yicha, yorug' yoki qorong'i.
  ThemeMode get mavzu => _mavzu;

  /// Yangi hodisa qo'shganda oldindan belgilanadigan eslatma.
  EslatmaOraligi get standartEslatma => _standartEslatma;

  /// Bazadan o'qiydi. Xato bo'lsa, standart qiymatlar qoladi (ilova qulamaydi).
  Future<void> yuklash() async {
    try {
      final s = await _repository.hammasi();
      _ism = s[SozlamalarRepository.kalitIsm] ?? '';
      _mavzu = ThemeMode.values.firstWhere(
        (m) => m.name == s[SozlamalarRepository.kalitMavzu],
        orElse: () => ThemeMode.system,
      );
      _standartEslatma = EslatmaOraligi.matndan(
            s[SozlamalarRepository.kalitStandartEslatma] ?? '',
          ) ??
          EslatmaOraligi.birKunOldin;
    } catch (_) {
      // Standart qiymatlar bilan davom etamiz.
    }
    notifyListeners();
  }

  Future<void> ismniOzgartirish(String yangiIsm) async {
    _ism = yangiIsm.trim();
    notifyListeners();
    await _saqlash(SozlamalarRepository.kalitIsm, _ism);
  }

  Future<void> mavzuniOzgartirish(ThemeMode yangiMavzu) async {
    _mavzu = yangiMavzu;
    notifyListeners();
    await _saqlash(SozlamalarRepository.kalitMavzu, yangiMavzu.name);
  }

  Future<void> standartEslatmaniOzgartirish(EslatmaOraligi oraliq) async {
    _standartEslatma = oraliq;
    notifyListeners();
    await _saqlash(SozlamalarRepository.kalitStandartEslatma, oraliq.name);
  }

  // Bazaga yozishda xato bo'lsa ham, sozlama shu seans davomida ishlaydi.
  Future<void> _saqlash(String kalit, String qiymat) async {
    try {
      await _repository.saqlash(kalit, qiymat);
    } catch (_) {}
  }
}
