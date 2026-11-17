// Hodisalar holatini boshqaruvchi provider (ChangeNotifier).
//
// Ekranlar hodisalar ro'yxatini shu yerdan oladi. Hodisa qo'shilsa,
// o'zgarsa yoki o'chirilsa, provider `notifyListeners()` chaqiradi va
// unga bog'langan ekranlar avtomatik qayta chiziladi.
//
// Ma'lumot oqimi: Ekran -> HodisaProvider -> HodisaRepository -> SQLite

import 'package:flutter/foundation.dart';

import '../constants/matnlar.dart';
import '../data/hodisa_repository.dart';
import '../models/hodisa.dart';
import '../utils/sana_format.dart';

class HodisaProvider extends ChangeNotifier {
  HodisaProvider({HodisaRepository? repository})
      : _repository = repository ?? HodisaRepository();

  final HodisaRepository _repository;

  List<Hodisa> _hodisalar = [];
  bool _yuklanmoqda = true;
  String? _xato;
  HodisaTuri? _filtr; // null = barcha turlar

  /// Bazadan o'qish davom etyaptimi.
  bool get yuklanmoqda => _yuklanmoqda;

  /// O'qishda xato bo'lsa, foydalanuvchiga ko'rsatiladigan matn.
  String? get xato => _xato;

  /// Tanlangan filtr (null bo'lsa, hammasi ko'rsatiladi).
  HodisaTuri? get filtr => _filtr;

  /// Umuman birorta hodisa bormi (o'tganlari bilan birga).
  bool get bosh => _hodisalar.isEmpty;

  /// Ilova ochilganda hodisalarni bazadan o'qiydi.
  Future<void> yuklash() async {
    _yuklanmoqda = true;
    _xato = null;
    notifyListeners();
    try {
      _hodisalar = await _repository.barchasi();
    } catch (_) {
      // Baza ochilmasa ham ilova qulamaydi, xato xabari ko'rsatiladi.
      _xato = Matnlar.yuklashXatosi;
    } finally {
      _yuklanmoqda = false;
      notifyListeners();
    }
  }

  /// Filtrni tanlaydi. `null` — barcha turlar.
  void filtrniTanlash(HodisaTuri? tur) {
    _filtr = tur;
    notifyListeners();
  }

  /// Hodisani `id` bo'yicha topadi. Topilmasa (masalan, o'chirilgan) — `null`.
  Hodisa? idBoyicha(int id) {
    for (final h in _hodisalar) {
      if (h.id == id) return h;
    }
    return null;
  }

  /// Hali boshlanmagan hodisalar (filtr bilan), eng yaqini birinchi.
  List<Hodisa> kelayotganlar(DateTime hozir) {
    return _hodisalar
        .where((h) => !h.otganmi(hozir))
        .where((h) => _filtr == null || h.turi == _filtr)
        .toList();
  }

  /// Vaqti o'tgan hodisalar, eng oxirgisi birinchi.
  List<Hodisa> otganlar(DateTime hozir) {
    return _hodisalar.where((h) => h.otganmi(hozir)).toList().reversed.toList();
  }

  /// Eng yaqin kelayotgan hodisa (filtrga qaramasdan). Yo'q bo'lsa `null`.
  Hodisa? engYaqin(DateTime hozir) {
    for (final h in _hodisalar) {
      if (!h.otganmi(hozir)) return h;
    }
    return null;
  }

  /// Barcha kelayotgan hodisalar soni.
  int kelayotganSoni(DateTime hozir) =>
      _hodisalar.where((h) => !h.otganmi(hozir)).length;

  /// Keyingi 7 kun ichidagi hodisalar soni.
  int yettiKunIchidaSoni(DateTime hozir) {
    final chegara = hozir.add(const Duration(days: 7));
    return _hodisalar
        .where((h) => !h.otganmi(hozir) && h.sana.isBefore(chegara))
        .length;
  }

  /// Berilgan kunda birorta hodisa bormi (hafta qatoridagi nuqta uchun).
  bool kundaHodisaBor(DateTime kun) =>
      _hodisalar.any((h) => birKunmi(h.sana, kun));

  /// Yangi hodisani saqlaydi.
  Future<void> qoshish(Hodisa hodisa) async {
    final saqlangan = await _repository.qoshish(hodisa);
    _hodisalar.add(saqlangan);
    _tartiblash();
    notifyListeners();
  }

  /// Mavjud hodisani yangilaydi.
  Future<void> yangilash(Hodisa hodisa) async {
    await _repository.yangilash(hodisa);
    final indeks = _hodisalar.indexWhere((h) => h.id == hodisa.id);
    if (indeks != -1) _hodisalar[indeks] = hodisa;
    _tartiblash();
    notifyListeners();
  }

  /// Hodisani o'chiradi.
  Future<void> ochirish(int id) async {
    await _repository.ochirish(id);
    _hodisalar.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  /// Ro'yxatni sana bo'yicha tartiblaydi (eng yaqini birinchi).
  void _tartiblash() => _hodisalar.sort((a, b) => a.sana.compareTo(b.sana));
}
