// Eslatma vaqti, ID raqami va matnini hisoblash testlari.

import 'package:countdown/models/hodisa.dart';
import 'package:countdown/utils/eslatma_matni.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // O'zbekcha oy nomlari ("dekabr") uchun.
  setUpAll(() => initializeDateFormatting('uz'));

  final imtihon = Hodisa(
    id: 7,
    nomi: 'Matematika imtihoni',
    sana: DateTime(2026, 12, 15, 9, 0),
    turi: HodisaTuri.imtihon,
    eslatmalar: const [
      EslatmaOraligi.birKunOldin,
      EslatmaOraligi.birSoatOldin,
      EslatmaOraligi.aynanVaqtida,
    ],
    rang: 0xFF97C459,
    yaratilgan: DateTime(2026, 11, 17),
  );

  test('eslatma vaqti: hodisa vaqtidan oraliq ayriladi', () {
    final sana = imtihon.sana;
    expect(
      EslatmaOraligi.birKunOldin.vaqti(sana),
      DateTime(2026, 12, 14, 9, 0),
    );
    expect(
      EslatmaOraligi.birSoatOldin.vaqti(sana),
      DateTime(2026, 12, 15, 8, 0),
    );
    expect(EslatmaOraligi.aynanVaqtida.vaqti(sana), sana);
  });

  test('eslatma ID: hodisaId * 10 + tartib raqami', () {
    expect(eslatmaId(7, EslatmaOraligi.birKunOldin), 70);
    expect(eslatmaId(7, EslatmaOraligi.birSoatOldin), 71);
    expect(eslatmaId(7, EslatmaOraligi.aynanVaqtida), 72);
  });

  test('eslatma matni', () {
    expect(
      eslatmaMatni(imtihon, EslatmaOraligi.birKunOldin).sarlavha,
      'Ertaga: Matematika imtihoni (09:00)',
    );
    expect(
      eslatmaMatni(imtihon, EslatmaOraligi.birSoatOldin).sarlavha,
      '1 soat qoldi: Matematika imtihoni',
    );
  });

  test("vaqti o'tib ketgan eslatma rejalashtirilmaydi", () {
    // Imtihonga 30 daqiqa qolgan: "1 kun" va "1 soat oldin" allaqachon o'tgan.
    final hozir = DateTime(2026, 12, 15, 8, 30);
    expect(rejalashtiriladiganEslatmalar(imtihon, hozir), [
      EslatmaOraligi.aynanVaqtida,
    ]);
  });
}
