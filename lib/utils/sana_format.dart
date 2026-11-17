// Sana va vaqtni o'zbekcha ko'rinishda yozish.
//
// `intl` paketi o'zbekcha oy va hafta kunlari nomlarini biladi
// ("dekabr", "seshanba"). Buning uchun main.dart da bir marta
// `initializeDateFormatting('uz')` chaqiriladi.

import 'package:intl/intl.dart';

/// Sonni ikki xonali qiladi: 5 → "05".
String ikkiXonali(int son) => son.toString().padLeft(2, '0');

/// "09:05" ko'rinishidagi vaqt.
String soatMinut(int soat, int daqiqa) =>
    '${ikkiXonali(soat)}:${ikkiXonali(daqiqa)}';

/// Sanadan vaqtni oladi: "09:00".
String vaqtMatni(DateTime sana) => soatMinut(sana.hour, sana.minute);

/// To'liq sana: "15-dekabr, 2026, 09:00".
String toliqSana(DateTime sana) =>
    DateFormat('d-MMMM, y, HH:mm', 'uz').format(sana);

/// Kun va oy: "28-noyabr".
String kunVaOy(DateTime sana) => DateFormat('d-MMMM', 'uz').format(sana);

/// Kartochkadagi qisqa sana: "19 noy".
String qisqaSana(DateTime sana) => DateFormat('d MMM', 'uz').format(sana);

/// Bosh ekran tepasidagi sana: "Seshanba, 17-noyabr".
String bugungiSarlavha(DateTime sana) {
  final matn = DateFormat('EEEE, d-MMMM', 'uz').format(sana);
  return matn[0].toUpperCase() + matn.substring(1);
}

/// Kun vaqtiga qarab salomlashuv.
String salomlashuv(DateTime hozir) {
  final soat = hozir.hour;
  if (soat >= 5 && soat < 11) return 'Xayrli tong';
  if (soat >= 11 && soat < 17) return 'Xayrli kun';
  if (soat >= 17 && soat < 22) return 'Xayrli kech';
  return 'Xayrli tun';
}

/// Ikki sana bir kunga to'g'ri keladimi (soatga qaramasdan).
bool birKunmi(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
