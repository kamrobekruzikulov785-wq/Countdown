// Sanoq matnini hisoblash testlari.
// Ishga tushirish: flutter test

import 'package:countdown/utils/countdown_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sanoqMatni', () {
    test('bir kundan ko\'p qolsa, kunlar bilan yoziladi', () {
      const qolgan = Duration(days: 12, hours: 4, minutes: 31, seconds: 9);
      expect(sanoqMatni(qolgan), '12 kun 04:31:09');
    });

    test('bir kundan kam qolsa, faqat soat:daqiqa:soniya', () {
      const qolgan = Duration(hours: 3, minutes: 5, seconds: 7);
      expect(sanoqMatni(qolgan), '03:05:07');
    });

    test('vaqt kelgan yoki o\'tgan bo\'lsa, "Boshlandi"', () {
      expect(sanoqMatni(Duration.zero), 'Boshlandi');
      expect(sanoqMatni(const Duration(seconds: -5)), 'Boshlandi');
    });
  });

  test('kutishUlushi: yarim yo\'l bosilgan bo\'lsa 0.5', () {
    final yaratilgan = DateTime(2026, 12, 1);
    final sana = DateTime(2026, 12, 21);
    final hozir = DateTime(2026, 12, 11);
    expect(kutishUlushi(yaratilgan: yaratilgan, sana: sana, hozir: hozir), 0.5);
  });
}
