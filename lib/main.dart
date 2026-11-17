// Ilovaning kirish nuqtasi: dastur shu yerdan boshlanadi.
//
// 1. O'zbekcha sana nomlarini ("dekabr", "seshanba") yuklaydi.
// 2. Provider'larni yaratadi: SoatProvider (har soniyalik taymer) va
//    HodisaProvider (hodisalar ro'yxati, bazadan o'qiladi).
// 3. Mavzu (yorug'/qorong'i) va o'zbek tilini sozlab, bosh ekranni ochadi.

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'constants/matnlar.dart';
import 'providers/hodisa_provider.dart';
import 'providers/soat_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Flutter tayyor bo'lishini kutamiz (baza va boshqa xizmatlar uchun kerak).
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('uz');
  Intl.defaultLocale = 'uz';

  runApp(
    MultiProvider(
      providers: [
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
      themeMode: ThemeMode.system, // telefon sozlamasiga qarab
      // Sana va vaqt tanlash oynalari ham o'zbekcha bo'lishi uchun.
      locale: const Locale('uz'),
      supportedLocales: const [Locale('uz')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeScreen(),
    );
  }
}
