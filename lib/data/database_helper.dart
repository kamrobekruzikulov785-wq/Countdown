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

  /// Baza tuzilishi versiyasi. Kelajakda jadval o'zgarsa, bu son oshiriladi.
  static const int _versiya = 1;

  /// Hodisalar saqlanadigan jadval nomi.
  static const String jadval = 'hodisalar';

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
    );
  }

  /// Baza birinchi marta yaratilganda jadvalni tuzadi.
  Future<void> _jadvalYaratish(Database db, int versiya) async {
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
}
