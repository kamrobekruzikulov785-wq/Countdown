// Ma'lumotlar bazasi bilan ishlovchi yordamchi sinf.
//
// Telefonda "countdown.db" nomli SQLite fayl yaratiladi. Ilova yopilib
// ochilganda ham ma'lumot shu faylda saqlanib qoladi. Internet kerak emas.
//
// Bu sinf faqat jadval qatorlari (Map) bilan ishlaydi. Qatorlarni Hodisa
// obyektiga aylantirish HodisaRepository'ning vazifasi.

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Konstruktor yopiq: butun ilovada bazaga faqat bitta ulanish bo'ladi.
  DatabaseHelper._();

  /// Yagona nusxa (singleton). Hamma joyda shu ishlatiladi.
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _faylNomi = 'countdown.db';

  /// Baza tuzilishi versiyasi. Jadval qo'shilsa yoki o'zgarsa, bu son oshiriladi.
  /// 1 — faqat hodisalar; 2 — sozlamalar jadvali qo'shildi.
  static const int _versiya = 2;

  /// Hodisalar saqlanadigan jadval nomi.
  static const String jadval = 'hodisalar';

  /// Sozlamalar saqlanadigan jadval nomi ("kalit — qiymat" juftliklari).
  static const String sozlamalarJadvali = 'sozlamalar';

  // Baza bir marta ochiladi va keyin shu natija qayta ishlatiladi.
  Future<Database>? _baza;

  /// Ochiq bazani qaytaradi. Birinchi chaqiruvda bazani ochadi.
  Future<Database> get baza => _baza ??= _ochish();

  Future<Database> _ochish() async {
    final papka = await getDatabasesPath();
    return openDatabase(
      join(papka, _faylNomi),
      version: _versiya,
      onCreate: _jadvalYaratish,
      onUpgrade: _yangilash,
    );
  }

  /// Ilova yangi versiyaga yangilanganda (eski baza bilan) chaqiriladi.
  /// Eski ma'lumotga tegilmaydi, faqat yetishmayotgan jadval qo'shiladi.
  Future<void> _yangilash(Database db, int eskiVersiya, int yangiVersiya) async {
    if (eskiVersiya < 2) await _sozlamalarJadvaliniYaratish(db);
  }

  Future<void> _sozlamalarJadvaliniYaratish(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $sozlamalarJadvali (
        kalit   TEXT PRIMARY KEY,
        qiymat  TEXT NOT NULL
      )
    ''');
  }

  /// Baza birinchi marta yaratilganda jadvallarni tuzadi.
  Future<void> _jadvalYaratish(Database db, int versiya) async {
    await _sozlamalarJadvaliniYaratish(db);
    await db.execute('''
      CREATE TABLE $jadval (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nomi        TEXT    NOT NULL,
        sana        INTEGER NOT NULL,
        turi        TEXT    NOT NULL,
        izoh        TEXT    NOT NULL DEFAULT '',
        eslatmalar  TEXT    NOT NULL DEFAULT '',
        rang        INTEGER NOT NULL,
        yaratilgan  INTEGER NOT NULL
      )
    ''');
  }

  /// Yangi qator qo'shadi va baza bergan `id` raqamini qaytaradi.
  Future<int> qoshish(Map<String, Object?> qator) async {
    final db = await baza;
    return db.insert(jadval, qator);
  }

  /// Barcha qatorlarni sana bo'yicha (eng yaqini birinchi) qaytaradi.
  Future<List<Map<String, Object?>>> hammasi() async {
    final db = await baza;
    return db.query(jadval, orderBy: 'sana ASC');
  }

  /// `id` raqamli qatorni yangilaydi. O'zgargan qatorlar sonini qaytaradi.
  Future<int> yangilash(int id, Map<String, Object?> qator) async {
    final db = await baza;
    return db.update(jadval, qator, where: 'id = ?', whereArgs: [id]);
  }

  /// `id` raqamli qatorni o'chiradi. O'chirilgan qatorlar sonini qaytaradi.
  Future<int> ochirish(int id) async {
    final db = await baza;
    return db.delete(jadval, where: 'id = ?', whereArgs: [id]);
  }

  /// Barcha sozlamalarni `{kalit: qiymat}` ko'rinishida o'qiydi.
  Future<Map<String, String>> sozlamalarniOqish() async {
    final db = await baza;
    final qatorlar = await db.query(sozlamalarJadvali);
    return {
      for (final q in qatorlar) q['kalit'] as String: q['qiymat'] as String,
    };
  }

  /// Bitta sozlamani yozadi. Bunday kalit bor bo'lsa, qiymati almashtiriladi.
  Future<void> sozlamaniYozish(String kalit, String qiymat) async {
    final db = await baza;
    await db.insert(
      sozlamalarJadvali,
      {'kalit': kalit, 'qiymat': qiymat},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
