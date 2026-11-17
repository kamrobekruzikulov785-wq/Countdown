// Foydalanuvchi kiritgan ma'lumotlarni tekshirish (validatsiya).
//
// Har bir funksiya xato bo'lsa xato matnini, hammasi to'g'ri bo'lsa
// `null` qaytaradi. Flutter'ning `TextFormField` maydonlari aynan shu
// qoidani tushunadi.

import '../constants/matnlar.dart';
import '../models/hodisa.dart';

class Validatorlar {
  Validatorlar._();

  static const int nomMaxUzunlik = 60;
  static const int izohMaxUzunlik = 200;

  /// Nom bo'sh bo'lmasin va 60 belgidan oshmasin.
  /// Faqat bo'shliqlardan iborat nom ham bo'sh hisoblanadi.
  static String? nom(String? qiymat) {
    final matn = (qiymat ?? '').trim();
    if (matn.isEmpty) return Matnlar.nomBosh;
    if (matn.length > nomMaxUzunlik) return Matnlar.nomUzun;
    return null;
  }

  /// Izoh ixtiyoriy, lekin 200 belgidan oshmasin.
  static String? izoh(String? qiymat) {
    final matn = (qiymat ?? '').trim();
    if (matn.length > izohMaxUzunlik) return Matnlar.izohUzun;
    return null;
  }

  /// Hodisa sanasi va vaqti hozirgi vaqtdan keyin bo'lishi kerak.
  static String? sana(DateTime sana, DateTime hozir) {
    if (!sana.isAfter(hozir)) return Matnlar.sanaOtgan;
    return null;
  }

  /// Tanlangan eslatmalardan qaysilarining vaqti allaqachon o'tib ketganini
  /// topadi. Masalan, hodisa 30 daqiqadan keyin bo'lsa, "1 soat oldin"
  /// eslatmasi endi chiqmaydi.
  static List<EslatmaOraligi> otganEslatmalar(
    DateTime sana,
    Iterable<EslatmaOraligi> eslatmalar,
    DateTime hozir,
  ) {
    return eslatmalar
        .where((oraliq) => !oraliq.vaqti(sana).isAfter(hozir))
        .toList();
  }
}
