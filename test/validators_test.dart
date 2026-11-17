// Kiritilgan ma'lumotlarni tekshirish (validatsiya) testlari.

import 'package:countdown/models/hodisa.dart';
import 'package:countdown/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nom', () {
    test("bo'sh nom xato beradi", () {
      expect(Validatorlar.nom(''), 'Hodisa nomini kiriting');
      expect(Validatorlar.nom(null), 'Hodisa nomini kiriting');
    });

    test("faqat bo'shliqlardan iborat nom ham bo'sh hisoblanadi", () {
      expect(Validatorlar.nom('    '), 'Hodisa nomini kiriting');
    });

    test('60 belgidan uzun nom xato beradi', () {
      expect(Validatorlar.nom('a' * 61), 'Nom 60 belgidan oshmasin');
      expect(Validatorlar.nom('a' * 60), isNull);
    });

    test("to'g'ri nom qabul qilinadi", () {
      expect(Validatorlar.nom('Matematika imtihoni'), isNull);
    });
  });

  group('izoh', () {
    test("bo'sh izoh mumkin (ixtiyoriy maydon)", () {
      expect(Validatorlar.izoh(''), isNull);
    });

    test('200 belgidan uzun izoh xato beradi', () {
      expect(Validatorlar.izoh('b' * 201), 'Izoh 200 belgidan oshmasin');
      expect(Validatorlar.izoh('b' * 200), isNull);
    });
  });

  group('sana', () {
    final hozir = DateTime(2026, 11, 17, 10, 0);

    test("o'tgan sana xato beradi", () {
      expect(
        Validatorlar.sana(DateTime(2026, 11, 16, 10, 0), hozir),
        "Sana va vaqt kelajakda bo'lishi kerak",
      );
    });

    test('aynan hozirgi vaqt ham qabul qilinmaydi', () {
      expect(Validatorlar.sana(hozir, hozir), isNotNull);
    });

    test('kelajakdagi sana qabul qilinadi', () {
      expect(Validatorlar.sana(DateTime(2026, 11, 17, 10, 1), hozir), isNull);
    });
  });

  test("o'tib ketgan eslatmalar topiladi", () {
    // Hodisa 30 daqiqadan keyin: "1 kun" va "1 soat oldin" allaqachon o'tgan.
    final hozir = DateTime(2026, 11, 17, 10, 0);
    final sana = DateTime(2026, 11, 17, 10, 30);
    expect(Validatorlar.otganEslatmalar(sana, EslatmaOraligi.values, hozir), [
      EslatmaOraligi.birKunOldin,
      EslatmaOraligi.birSoatOldin,
    ]);
  });
}
