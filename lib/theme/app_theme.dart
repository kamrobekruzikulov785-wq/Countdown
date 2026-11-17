// Ilova mavzusi: ranglar, shrift va tugmalar ko'rinishi shu bir joyda.
//
// Tasdiqlangan dizayn uslubi (ISH-REJASI.md, 7-bo'lim) shu yerda kodga
// aylangan. Rangni o'zgartirish kerak bo'lsa, faqat shu faylga tegiladi.

import 'package:material_ui/material_ui.dart';

/// Hodisa kartochkalari uchun tanlanadigan 5 ta rang.
const List<Color> hodisaRanglari = [
  Color(0xFF97C459), // yashil
  Color(0xFF85B7EB), // ko'k
  Color(0xFFF0997B), // marjon
  Color(0xFFAFA9EC), // binafsha
  Color(0xFFEF9F27), // sariq
];

/// Material'ning standart ranglarida yo'q, lekin bizning dizaynda bor ranglar.
///
/// Ular mavzuga "kengaytma" (ThemeExtension) sifatida qo'shiladi va har
/// qanday ekranda `context.ranglar` orqali olinadi.
class IlovaRanglari extends ThemeExtension<IlovaRanglari> {
  const IlovaRanglari({
    required this.fon,
    required this.kartochka,
    required this.matn,
    required this.ikkinchiMatn,
    required this.ajratuvchi,
    required this.urgu,
    required this.urguFon,
    required this.urguIz,
    required this.urguMatn,
    required this.urguIkkinchiMatn,
    required this.urguUstida,
    required this.ogohlantirishFon,
    required this.ogohlantirishMatn,
  });

  /// Ekran foni (och kulrang).
  final Color fon;

  /// Kartochka foni (oq).
  final Color kartochka;

  /// Asosiy matn (qora).
  final Color matn;

  /// Ikkinchi darajali matn (kulrang).
  final Color ikkinchiMatn;

  /// Ingichka ajratuvchi chiziq.
  final Color ajratuvchi;

  /// Asosiy urg'u rangi (yashil): "+" tugmasi, halqa, tanlangan belgilar.
  final Color urgu;

  /// Yashil kartochka foni.
  final Color urguFon;

  /// Halqaning to'lmagan qismi va bugungi kun foni.
  final Color urguIz;

  /// Yashil fondagi asosiy matn.
  final Color urguMatn;

  /// Yashil fondagi ikkinchi darajali matn.
  final Color urguIkkinchiMatn;

  /// Yashil tugma ustidagi belgi rangi.
  final Color urguUstida;

  /// Ogohlantirish xabari foni va matni (sariq tonlarda).
  final Color ogohlantirishFon;
  final Color ogohlantirishMatn;

  /// Yorug' mavzu ranglari.
  static const yorug = IlovaRanglari(
    fon: Color(0xFFF2F3F5),
    kartochka: Color(0xFFFFFFFF),
    matn: Color(0xFF111214),
    ikkinchiMatn: Color(0xFF7C7F85),
    ajratuvchi: Color(0xFFE9EAEC),
    urgu: Color(0xFF639922),
    urguFon: Color(0xFFEAF3DE),
    urguIz: Color(0xFFC0DD97),
    urguMatn: Color(0xFF27500A),
    urguIkkinchiMatn: Color(0xFF3B6D11),
    urguUstida: Color(0xFFFFFFFF),
    ogohlantirishFon: Color(0xFFFAEEDA),
    ogohlantirishMatn: Color(0xFF854F0B),
  );

  /// Qorong'i mavzu ranglari.
  static const qorongi = IlovaRanglari(
    fon: Color(0xFF0E0F10),
    kartochka: Color(0xFF1B1C1E),
    matn: Color(0xFFF4F4F2),
    ikkinchiMatn: Color(0xFF9B9DA2),
    ajratuvchi: Color(0xFF2B2C2F),
    urgu: Color(0xFF97C459),
    urguFon: Color(0xFF27500A),
    urguIz: Color(0xFF3B6D11),
    urguMatn: Color(0xFFEAF3DE),
    urguIkkinchiMatn: Color(0xFFC0DD97),
    urguUstida: Color(0xFF173404),
    ogohlantirishFon: Color(0xFF412402),
    ogohlantirishMatn: Color(0xFFFAC775),
  );

  // Quyidagi ikki metodni Flutter talab qiladi. Ranglarimiz o'zgarmas,
  // shuning uchun nusxa o'zi qaytariladi, mavzu almashganda esa ranglar
  // silliq emas, bir zumda almashadi.
  @override
  IlovaRanglari copyWith() => this;

  @override
  IlovaRanglari lerp(IlovaRanglari? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

/// `context.ranglar` deb yozib, joriy mavzu ranglarini olish uchun.
extension IlovaRanglariOlish on BuildContext {
  IlovaRanglari get ranglar => Theme.of(this).extension<IlovaRanglari>()!;
}

/// Raqamlar bir xil kenglikda chiqishi uchun (sanoq "sakramasligi" uchun).
const List<FontFeature> tengRaqamlar = [FontFeature.tabularFigures()];

/// Yorug' yoki qorong'i mavzuni yaratadi.
ThemeData ilovaMavzusi(Brightness yorqinlik) {
  final r = yorqinlik == Brightness.dark
      ? IlovaRanglari.qorongi
      : IlovaRanglari.yorug;
  final xatoRangi = yorqinlik == Brightness.dark
      ? const Color(0xFFF09595)
      : const Color(0xFFA32D2D);

  final sxema = ColorScheme.fromSeed(
    seedColor: r.urgu,
    brightness: yorqinlik,
  ).copyWith(
    primary: r.urgu,
    onPrimary: r.urguUstida,
    surface: r.kartochka,
    onSurface: r.matn,
    onSurfaceVariant: r.ikkinchiMatn,
    outlineVariant: r.ajratuvchi,
    error: xatoRangi,
  );

  final yumaloq16 = BorderRadius.circular(16);

  return ThemeData(
    useMaterial3: true,
    brightness: yorqinlik,
    colorScheme: sxema,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: r.fon,
    extensions: [r],
    appBarTheme: AppBarTheme(
      backgroundColor: r.fon,
      foregroundColor: r.matn,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: r.matn,
      ),
    ),
    cardTheme: CardThemeData(
      color: r.kartochka,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: yumaloq16),
    ),
    dividerTheme: DividerThemeData(color: r.ajratuvchi, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: r.kartochka,
      hintStyle: TextStyle(color: r.ikkinchiMatn),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: yumaloq16,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: yumaloq16,
        borderSide: BorderSide(color: r.urgu, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: yumaloq16,
        borderSide: BorderSide(color: xatoRangi),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: yumaloq16,
        borderSide: BorderSide(color: xatoRangi, width: 1.5),
      ),
    ),
    // Asosiy tugma: qora kapsula ("Saqlash").
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: r.matn,
        foregroundColor: r.fon,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
