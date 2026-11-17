// Testlar uchun "soxta" (fake) baza va xizmatlar.
//
// Ekran testlari kompyuterda ishlaydi: u yerda telefon bazasi va
// bildirishnoma tizimi yo'q. Shuning uchun ularning o'rniga xotirada
// ishlaydigan oddiy nusxalar ishlatiladi. Ekranlar farqni sezmaydi.

import 'package:countdown/data/hodisa_repository.dart';
import 'package:countdown/data/sozlamalar_repository.dart';
import 'package:countdown/models/hodisa.dart';
import 'package:countdown/services/notification_service.dart';

/// Hodisalarni xotirada saqlaydigan soxta ombor.
class SoxtaHodisaRepository implements HodisaRepository {
  SoxtaHodisaRepository(List<Hodisa> boshlangich) : _royxat = [...boshlangich];

  final List<Hodisa> _royxat;
  int _keyingiId = 100;

  @override
  Future<List<Hodisa>> barchasi() async =>
      [..._royxat]..sort((a, b) => a.sana.compareTo(b.sana));

  @override
  Future<Hodisa> qoshish(Hodisa hodisa) async {
    final saqlangan = hodisa.copyWith(id: _keyingiId++);
    _royxat.add(saqlangan);
    return saqlangan;
  }

  @override
  Future<void> yangilash(Hodisa hodisa) async {
    _royxat[_royxat.indexWhere((h) => h.id == hodisa.id)] = hodisa;
  }

  @override
  Future<void> ochirish(int id) async => _royxat.removeWhere((h) => h.id == id);
}

/// Sozlamalarni xotirada saqlaydigan soxta ombor.
class SoxtaSozlamalarRepository implements SozlamalarRepository {
  SoxtaSozlamalarRepository([Map<String, String>? boshlangich])
    : _qiymatlar = {...?boshlangich};

  final Map<String, String> _qiymatlar;

  @override
  Future<Map<String, String>> hammasi() async => {..._qiymatlar};

  @override
  Future<void> saqlash(String kalit, String qiymat) async =>
      _qiymatlar[kalit] = qiymat;
}

/// Hech narsa qilmaydigan bildirishnoma xizmati.
class SoxtaBildirishnoma implements NotificationService {
  @override
  Future<void> ishgaTushirish() async {}

  @override
  Future<bool> yoqilganmi() async => true;

  @override
  Future<bool> ruxsatSorash() async => true;

  @override
  Future<void> sozlamalarniOchish() async {}

  @override
  Future<void> sinovKorsatish() async {}

  @override
  Future<void> rejalashtirish(Hodisa hodisa) async {}

  @override
  Future<void> bekorQilish(int hodisaId) async {}

  @override
  Future<void> hammasiniTiklash(List<Hodisa> hodisalar) async {}
}
