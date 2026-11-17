// Hodisalar ombori (repository).
//
// Ilovaning qolgan qismi (provider va ekranlar) baza bilan to'g'ridan-to'g'ri
// emas, faqat shu sinf orqali gaplashadi. U jadval qatorlarini Hodisa
// obyektlariga va aksincha aylantiradi.
//
// Ma'lumot oqimi: Ekran -> Provider -> HodisaRepository -> DatabaseHelper -> SQLite

import '../models/hodisa.dart';
import 'database_helper.dart';

class HodisaRepository {
  /// Odatda umumiy bazadan foydalanadi. Testlarda boshqa baza berish mumkin.
  HodisaRepository({DatabaseHelper? baza})
      : _baza = baza ?? DatabaseHelper.instance;

  final DatabaseHelper _baza;

  /// Barcha hodisalarni sana bo'yicha tartiblangan holda qaytaradi.
  Future<List<Hodisa>> barchasi() async {
    final qatorlar = await _baza.hammasi();
    return qatorlar.map(Hodisa.fromMap).toList();
  }

  /// Yangi hodisani saqlaydi va baza bergan `id` bilan qaytaradi.
  Future<Hodisa> qoshish(Hodisa hodisa) async {
    // `id` ni baza o'zi beradi, shuning uchun uni qatordan olib tashlaymiz.
    final qator = hodisa.toMap()..remove('id');
    final id = await _baza.qoshish(qator);
    return hodisa.copyWith(id: id);
  }

  /// Mavjud hodisani yangilaydi.
  Future<void> yangilash(Hodisa hodisa) async {
    final id = hodisa.id;
    if (id == null) {
      throw ArgumentError("Hali saqlanmagan hodisani yangilab bo'lmaydi");
    }
    await _baza.yangilash(id, hodisa.toMap()..remove('id'));
  }

  /// Hodisani `id` bo'yicha o'chiradi.
  Future<void> ochirish(int id) async {
    await _baza.ochirish(id);
  }
}
