// Hodisa modeli: ilovadagi bitta imtihon, tadbir yoki muhim sana.
//
// Bu fayl faqat ma'lumot tuzilishini tavsiflaydi. U baza bilan ham,
// ekranlar bilan ham bevosita ishlamaydi. Shuning uchun uni alohida
// sinash (test qilish) oson.

/// Hodisa turi. Har bir turning ekranda ko'rinadigan o'zbekcha nomi bor.
enum HodisaTuri {
  imtihon('Imtihon'),
  tadbir('Tadbir'),
  tugilganKun("Tug'ilgan kun"),
  boshqa('Boshqa');

  const HodisaTuri(this.nomi);

  /// Ekranda ko'rsatiladigan nom.
  final String nomi;

  /// Bazadagi matndan (masalan, "imtihon") turni tiklaydi.
  /// Noma'lum qiymat kelsa, ilova qulamasligi uchun "Boshqa" qaytariladi.
  static HodisaTuri matndan(String qiymat) {
    return HodisaTuri.values.firstWhere(
      (tur) => tur.name == qiymat,
      orElse: () => HodisaTuri.boshqa,
    );
  }
}

/// Eslatma oralig'i: bildirishnoma hodisadan qancha vaqt oldin chiqishi.
enum EslatmaOraligi {
  birKunOldin('1 kun oldin', Duration(days: 1)),
  birSoatOldin('1 soat oldin', Duration(hours: 1)),
  aynanVaqtida('Aynan vaqtida', Duration.zero);

  const EslatmaOraligi(this.nomi, this.oldin);

  /// Ekranda ko'rsatiladigan nom.
  final String nomi;

  /// Hodisa vaqtidan qancha oldin eslatish kerakligi.
  final Duration oldin;

  /// Bazadagi matndan oraliqni tiklaydi. Noma'lum qiymat uchun `null`.
  static EslatmaOraligi? matndan(String qiymat) {
    for (final oraliq in EslatmaOraligi.values) {
      if (oraliq.name == qiymat) return oraliq;
    }
    return null;
  }
}

/// Bitta hodisa haqidagi barcha ma'lumot.
class Hodisa {
  const Hodisa({
    this.id,
    required this.nomi,
    required this.sana,
    required this.turi,
    this.izoh = '',
    this.eslatmalar = const [],
    required this.rang,
    required this.yaratilgan,
  });

  /// Bazadagi tartib raqami. Hodisa hali saqlanmagan bo'lsa, `null`.
  final int? id;

  /// Hodisa nomi, masalan "Matematika imtihoni".
  final String nomi;

  /// Hodisa boshlanadigan sana va vaqt.
  final DateTime sana;

  /// Hodisa turi: imtihon, tadbir, tug'ilgan kun yoki boshqa.
  final HodisaTuri turi;

  /// Ixtiyoriy izoh. Kiritilmagan bo'lsa, bo'sh matn.
  final String izoh;

  /// Qaysi oraliqlarda eslatma chiqishi kerak.
  final List<EslatmaOraligi> eslatmalar;

  /// Kartochka rangi, ARGB son ko'rinishida (masalan, 0xFF97C459).
  final int rang;

  /// Hodisa qachon yaratilgani. Sanoq halqasidagi foizni hisoblashda kerak.
  final DateTime yaratilgan;

  /// Hodisa vaqti kelganmi yoki o'tib ketganmi.
  bool otganmi(DateTime hozir) => !sana.isAfter(hozir);

  /// Hodisagacha qolgan vaqt. Hodisa o'tgan bo'lsa, manfiy bo'ladi.
  Duration qolganVaqt(DateTime hozir) => sana.difference(hozir);

  /// Hodisani bazaga yozish uchun jadval qatoriga aylantiradi.
  ///
  /// SQLite sana va ro'yxatni to'g'ridan-to'g'ri saqlay olmaydi, shuning uchun:
  /// - sanalar millisekundlardagi son sifatida saqlanadi;
  /// - eslatmalar vergul bilan ajratilgan matn bo'ladi: "birKunOldin,birSoatOldin".
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nomi': nomi,
      'sana': sana.millisecondsSinceEpoch,
      'turi': turi.name,
      'izoh': izoh,
      'eslatmalar': eslatmalar.map((e) => e.name).join(','),
      'rang': rang,
      'yaratilgan': yaratilgan.millisecondsSinceEpoch,
    };
  }

  /// Bazadagi jadval qatoridan hodisani qayta tiklaydi (`toMap` ning teskarisi).
  factory Hodisa.fromMap(Map<String, Object?> qator) {
    final eslatmaMatni = (qator['eslatmalar'] as String?) ?? '';
    return Hodisa(
      id: qator['id'] as int?,
      nomi: qator['nomi'] as String,
      sana: DateTime.fromMillisecondsSinceEpoch(qator['sana'] as int),
      turi: HodisaTuri.matndan(qator['turi'] as String),
      izoh: (qator['izoh'] as String?) ?? '',
      eslatmalar: eslatmaMatni
          .split(',')
          .map(EslatmaOraligi.matndan)
          .whereType<EslatmaOraligi>()
          .toList(),
      rang: qator['rang'] as int,
      yaratilgan:
          DateTime.fromMillisecondsSinceEpoch(qator['yaratilgan'] as int),
    );
  }

  /// Hodisaning nusxasini yaratadi, faqat ko'rsatilgan maydonlar o'zgaradi.
  /// Masalan, tahrirlashda: `hodisa.copyWith(nomi: 'Yangi nom')`.
  Hodisa copyWith({
    int? id,
    String? nomi,
    DateTime? sana,
    HodisaTuri? turi,
    String? izoh,
    List<EslatmaOraligi>? eslatmalar,
    int? rang,
    DateTime? yaratilgan,
  }) {
    return Hodisa(
      id: id ?? this.id,
      nomi: nomi ?? this.nomi,
      sana: sana ?? this.sana,
      turi: turi ?? this.turi,
      izoh: izoh ?? this.izoh,
      eslatmalar: eslatmalar ?? this.eslatmalar,
      rang: rang ?? this.rang,
      yaratilgan: yaratilgan ?? this.yaratilgan,
    );
  }
}
