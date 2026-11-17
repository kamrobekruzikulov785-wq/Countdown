// Eslatma (bildirishnoma) uchun ID raqam va matn tayyorlash.
//
// Bu yerdagi funksiyalar telefonga bog'liq emas, shuning uchun ularni
// testlar bilan tekshirish oson.

import '../models/hodisa.dart';
import 'sana_format.dart';

/// Har bir eslatma uchun unikal ID.
///
/// Formula: `hodisaId * 10 + oraliq tartib raqami`.
/// Masalan, 7-hodisaning "1 soat oldin" (1-tartib) eslatmasi → 71.
/// Shunda hodisani o'chirganda uning eslatmalarini aniq topib bekor qilamiz.
int eslatmaId(int hodisaId, EslatmaOraligi oraliq) => hodisaId * 10 + oraliq.index;

/// Bildirishnoma sarlavhasi va matni.
///
/// - 1 kun oldin:  "Ertaga: Matematika imtihoni (09:00)"
/// - 1 soat oldin: "1 soat qoldi: Matematika imtihoni"
/// - aynan vaqtida: "Boshlandi: Matematika imtihoni"
({String sarlavha, String matn}) eslatmaMatni(
  Hodisa hodisa,
  EslatmaOraligi oraliq,
) {
  final vaqt = vaqtMatni(hodisa.sana);
  final sana = toliqSana(hodisa.sana);
  switch (oraliq) {
    case EslatmaOraligi.birKunOldin:
      return (
        sarlavha: 'Ertaga: ${hodisa.nomi} ($vaqt)',
        matn: '${hodisa.turi.nomi} · $sana',
      );
    case EslatmaOraligi.birSoatOldin:
      return (
        sarlavha: '1 soat qoldi: ${hodisa.nomi}',
        matn: 'Boshlanish vaqti: $vaqt',
      );
    case EslatmaOraligi.aynanVaqtida:
      return (
        sarlavha: 'Boshlandi: ${hodisa.nomi}',
        matn: 'Omad tilaymiz! · $sana',
      );
  }
}

/// Qaysi eslatmalarni rejalashtirish kerak: faqat hodisada tanlangan va
/// vaqti hali kelmaganlari. O'tib ketgan eslatma rejalashtirilmaydi.
List<EslatmaOraligi> rejalashtiriladiganEslatmalar(
  Hodisa hodisa,
  DateTime hozir,
) {
  return hodisa.eslatmalar
      .where((oraliq) => oraliq.vaqti(hodisa.sana).isAfter(hozir))
      .toList();
}
