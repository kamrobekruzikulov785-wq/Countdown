// Sanoqni (qolgan vaqtni) hisoblash va matnga aylantirish.
//
// Bu yerdagi funksiyalar ekranga bog'liq emas: ular faqat `Duration`
// (vaqt oralig'i) bilan ishlaydi. Shuning uchun ularni testlar bilan
// tekshirish oson.

import '../constants/matnlar.dart';
import 'sana_format.dart';

/// Qolgan vaqtning bo'laklari: kun, soat, daqiqa, soniya.
class SanoqQismlari {
  const SanoqQismlari(this.kun, this.soat, this.daqiqa, this.soniya);

  final int kun;
  final int soat;
  final int daqiqa;
  final int soniya;
}

/// Qolgan vaqtni bo'laklarga ajratadi.
/// Masalan, 1 kun 2 soat 3 daqiqa 4 soniya → (1, 2, 3, 4).
/// Vaqt o'tib ketgan bo'lsa, hammasi 0.
SanoqQismlari sanoqQismlari(Duration qolgan) {
  if (qolgan.isNegative) return const SanoqQismlari(0, 0, 0, 0);
  return SanoqQismlari(
    qolgan.inDays,
    qolgan.inHours % 24, // 24 ga bo'lgandagi qoldiq: kunlardan ortgan soatlar
    qolgan.inMinutes % 60,
    qolgan.inSeconds % 60,
  );
}

/// Kartochkadagi sanoq matni: "12 kun 04:31:09" yoki "04:31:09".
/// Vaqt kelgan bo'lsa: "Boshlandi".
String sanoqMatni(Duration qolgan) {
  if (qolgan.inSeconds <= 0) return Matnlar.boshlandi;
  final q = sanoqQismlari(qolgan);
  final vaqt =
      '${ikkiXonali(q.soat)}:${ikkiXonali(q.daqiqa)}:${ikkiXonali(q.soniya)}';
  return q.kun > 0 ? '${q.kun} ${Matnlar.kun} $vaqt' : vaqt;
}

/// O'tgan hodisa uchun matn: "3 kun oldin", "5 soat oldin".
String otganVaqtMatni(Duration otgan) {
  if (otgan.inMinutes < 1) return Matnlar.hozirgina;
  if (otgan.inHours < 1) return '${otgan.inMinutes} ${Matnlar.daqiqa} oldin';
  if (otgan.inDays < 1) return '${otgan.inHours} ${Matnlar.soat} oldin';
  return '${otgan.inDays} ${Matnlar.kun} oldin';
}

/// Halqa markazida ko'rsatiladigan eng katta birlik.
/// 3 kun qolsa → (3, "kun"), 5 soat qolsa → (5, "soat").
({int son, String birlik}) halqaQiymati(Duration qolgan) {
  final q = sanoqQismlari(qolgan);
  if (q.kun > 0) return (son: q.kun, birlik: Matnlar.kun);
  if (q.soat > 0) return (son: q.soat, birlik: Matnlar.soat);
  return (son: q.daqiqa, birlik: Matnlar.daqiqa);
}

/// Kutish vaqtining qancha qismi o'tganini 0 dan 1 gacha son bilan beradi.
///
/// Masalan, hodisa 10 kun oldin qo'shilgan va unga yana 10 kun qolgan
/// bo'lsa, natija 0.5 (ya'ni 50%). Halqa shu songa qarab to'ladi.
double kutishUlushi({
  required DateTime yaratilgan,
  required DateTime sana,
  required DateTime hozir,
}) {
  final jami = sana.difference(yaratilgan).inSeconds;
  if (jami <= 0) return 1;
  final otgan = hozir.difference(yaratilgan).inSeconds;
  return (otgan / jami).clamp(0.0, 1.0);
}
