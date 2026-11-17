// Sozlamalar ombori: ism, mavzu va standart eslatmani bazada saqlaydi.
//
// Ma'lumot oqimi: Sozlamalar ekrani -> SozlamalarProvider ->
// SozlamalarRepository -> DatabaseHelper -> SQLite ("sozlamalar" jadvali)

import 'database_helper.dart';

class SozlamalarRepository {
  SozlamalarRepository({DatabaseHelper? baza})
      : _baza = baza ?? DatabaseHelper.instance;

  final DatabaseHelper _baza;

  // Bazadagi kalitlar nomi. Bir joyda turgani uchun adashib ketmaydi.
  static const kalitIsm = 'ism';
  static const kalitMavzu = 'mavzu';
  static const kalitStandartEslatma = 'standart_eslatma';

  /// Barcha saqlangan sozlamalar.
  Future<Map<String, String>> hammasi() => _baza.sozlamalarniOqish();

  /// Bitta sozlamani saqlaydi.
  Future<void> saqlash(String kalit, String qiymat) =>
      _baza.sozlamaniYozish(kalit, qiymat);
}
