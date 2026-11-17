// Ekran testlari: ekranlar kichik telefonda (360 px kenglik) va katta
// shriftda ham sig'ishini, matnlar chiqishini va tekshiruvlar ishlashini
// avtomatik tekshiradi.
//
// Biror narsa sig'may qolsa ("overflow"), Flutter xato beradi va test
// muvaffaqiyatsiz tugaydi.

import 'package:countdown/models/hodisa.dart';
import 'package:countdown/providers/hodisa_provider.dart';
import 'package:countdown/providers/soat_provider.dart';
import 'package:countdown/providers/sozlamalar_provider.dart';
import 'package:countdown/screens/detail_screen.dart';
import 'package:countdown/screens/edit_screen.dart';
import 'package:countdown/screens/home_screen.dart';
import 'package:countdown/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'soxta_xizmatlar.dart';

/// Eng og'ir holatlar: 60 belgilik nom, uzun izoh, barcha eslatmalar,
/// 100 kundan ortiq sanoq va o'tib ketgan hodisa.
List<Hodisa> namunaviyHodisalar() {
  final hozir = DateTime.now();
  return [
    Hodisa(
      id: 1,
      nomi: 'Matematika va informatika fanlaridan yakuniy davlat imtihoni',
      sana: hozir.add(const Duration(days: 3, hours: 4)),
      turi: HodisaTuri.imtihon,
      izoh: 'Kalkulyator, pasport va talabalik guvohnomasini olib borish. ' * 3,
      eslatmalar: EslatmaOraligi.values,
      rang: hodisaRanglari[0].toARGB32(),
      yaratilgan: hozir.subtract(const Duration(days: 10)),
    ),
    Hodisa(
      id: 2,
      nomi: "Ona tug'ilgan kuni",
      sana: hozir.add(const Duration(days: 123)),
      turi: HodisaTuri.tugilganKun,
      rang: hodisaRanglari[2].toARGB32(),
      yaratilgan: hozir,
    ),
    Hodisa(
      id: 3,
      nomi: 'Diplom himoyasi',
      sana: hozir.subtract(const Duration(days: 2)),
      turi: HodisaTuri.tadbir,
      rang: hodisaRanglari[1].toARGB32(),
      yaratilgan: hozir.subtract(const Duration(days: 20)),
    ),
  ];
}

/// Ekranni kerakli provider'lar bilan o'rab, telefon o'lchamida chizadi.
Future<void> ekranniChizish(
  WidgetTester tester,
  Widget ekran, {
  List<Hodisa>? hodisalar,
  double shriftKattaligi = 1.0,
}) async {
  // 360 x 690 — eng kichik zamonaviy telefonlar o'lchami.
  tester.view.physicalSize = const Size(360, 690);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final sozlamalar = SozlamalarProvider(
    repository: SoxtaSozlamalarRepository({'ism': 'Kamronbek'}),
  );
  await sozlamalar.yuklash();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sozlamalar),
        ChangeNotifierProvider(create: (_) => SoatProvider()),
        ChangeNotifierProvider(
          create: (_) => HodisaProvider(
            repository: SoxtaHodisaRepository(
              hodisalar ?? namunaviyHodisalar(),
            ),
            bildirishnoma: SoxtaBildirishnoma(),
          )..yuklash(),
        ),
      ],
      child: MaterialApp(
        theme: ilovaMavzusi(Brightness.light),
        locale: const Locale('uz'),
        supportedLocales: const [Locale('uz')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, bola) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(shriftKattaligi)),
          child: bola!,
        ),
        home: ekran,
      ),
    ),
  );
  // Har soniyalik taymer bor, shuning uchun pumpAndSettle emas, oddiy pump.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(() => initializeDateFormatting('uz'));

  for (final shrift in [1.0, 1.3]) {
    group('shrift x$shrift', () {
      testWidgets('bosh ekran sig\'adi va ism ko\'rinadi', (tester) async {
        await ekranniChizish(
          tester,
          const HomeScreen(),
          shriftKattaligi: shrift,
        );
        expect(find.text('Kamronbek'), findsOneWidget);
        expect(find.text('Eng yaqin hodisa'), findsOneWidget);

        // Pastga aylantirib, barcha kartochkalar chizilganini tekshiramiz.
        await tester.drag(find.byType(ListView).first, const Offset(0, -800));
        await tester.pump();
        expect(find.text("Ona tug'ilgan kuni"), findsOneWidget);
      });

      testWidgets("o'tgan hodisalar va sozlamalar bo'limlari", (tester) async {
        await ekranniChizish(
          tester,
          const HomeScreen(),
          shriftKattaligi: shrift,
        );

        await tester.tap(find.byTooltip("O'tgan hodisalar"));
        await tester.pump();
        expect(find.text('Diplom himoyasi'), findsOneWidget);

        await tester.tap(find.byTooltip('Sozlamalar'));
        await tester.pump();
        expect(find.text('Ismingiz'), findsOneWidget);
      });

      testWidgets('batafsil ekran sig\'adi', (tester) async {
        await ekranniChizish(
          tester,
          const DetailScreen(hodisaId: 1),
          shriftKattaligi: shrift,
        );
        expect(find.text('daqiqa'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -1500));
        await tester.pump();
        expect(find.text("O'chirish"), findsOneWidget);
      });

      testWidgets("qo'shish ekrani sig'adi", (tester) async {
        await ekranniChizish(
          tester,
          const EditScreen(),
          shriftKattaligi: shrift,
        );
        await tester.ensureVisible(find.text('Saqlash'));
        await tester.pump();
        expect(find.text('Saqlash'), findsOneWidget);
      });

      testWidgets("tahrirlash ekrani (uzun nom va izoh) sig'adi", (
        tester,
      ) async {
        await ekranniChizish(
          tester,
          EditScreen(hodisa: namunaviyHodisalar().first),
          shriftKattaligi: shrift,
        );
        expect(find.text('Tahrirlash'), findsOneWidget);
        await tester.ensureVisible(find.text('Saqlash'));
        await tester.pump();
      });
    });
  }

  testWidgets("bo'sh holat: hodisa yo'q bo'lsa taklif ko'rsatiladi", (
    tester,
  ) async {
    await ekranniChizish(tester, const HomeScreen(), hodisalar: []);
    expect(find.text("Hali hodisa yo'q"), findsOneWidget);
  });

  testWidgets("bo'sh nom bilan saqlab bo'lmaydi, ekran tepaga suriladi", (
    tester,
  ) async {
    await ekranniChizish(tester, const EditScreen());
    // Pastga tushib "Saqlash" ni bosamiz (nom maydoni ekrandan chiqib ketgan).
    await tester.ensureVisible(find.text('Saqlash'));
    await tester.pump();
    await tester.tap(find.text('Saqlash'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // tepaga surilish
    expect(find.text('Hodisa nomini kiriting'), findsOneWidget);
    // Xato matni ekranning yuqori qismida ko'rinib turishi kerak.
    expect(
      tester.getTopLeft(find.text('Hodisa nomini kiriting')).dy,
      lessThan(300),
    );
  });
}
