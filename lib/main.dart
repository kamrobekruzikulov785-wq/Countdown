// Ilovaning kirish nuqtasi: dastur shu yerdan boshlanadi.
//
// 1. O'zbekcha sana nomlarini ("dekabr", "seshanba") yuklaydi.
// 2. Sozlamalarni (ism, mavzu) oldindan o'qiydi: shunda ilova birinchi
//    kadrdanoq to'g'ri mavzuda ochiladi.
// 3. Provider'larni yaratadi: SoatProvider (har soniyalik taymer),
//    HodisaProvider (hodisalar ro'yxati) va SozlamalarProvider.
// 4. Mavzu va o'zbek tilini sozlab, bosh ekranni ochadi.

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'constants/matnlar.dart';
import 'providers/hodisa_provider.dart';
import 'providers/soat_provider.dart';
import 'providers/sozlamalar_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Flutter tayyor bo'lishini kutamiz (baza va boshqa xizmatlar uchun kerak).
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('uz');
  Intl.defaultLocale = 'uz';

  final sozlamalar = SozlamalarProvider();
  await sozlamalar.yuklash();

  // Bildirishnomalarni tayyorlaymiz. Xato bo'lsa ham ilova ochilaveradi.
  try {
    await NotificationService.instance.ishgaTushirish();
  } catch (xato) {
    debugPrint('Bildirishnomalarni sozlab bo\'lmadi: $xato');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sozlamalar),
        ChangeNotifierProvider(create: (_) => SoatProvider()),
        // `..yuklash()` — provider yaratilishi bilan bazadan o'qishni boshlaydi.
        ChangeNotifierProvider(create: (_) => HodisaProvider()..yuklash()),
      ],
      child: const CountdownIlovasi(),
    ),
  );
}

class CountdownIlovasi extends StatelessWidget {
  const CountdownIlovasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Matnlar.ilovaNomi,
      debugShowCheckedModeBanner: false,
      theme: ilovaMavzusi(Brightness.light),
      darkTheme: ilovaMavzusi(Brightness.dark),
      // Sozlamalarda tanlangan mavzu: telefon bo'yicha, yorug' yoki qorong'i.
      themeMode: context.watch<SozlamalarProvider>().mavzu,
      // Sana va vaqt tanlash oynalari ham o'zbekcha bo'lishi uchun.
      locale: const Locale('uz'),
      supportedLocales: const [Locale('uz')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeScreen(),
    );
  }
}
