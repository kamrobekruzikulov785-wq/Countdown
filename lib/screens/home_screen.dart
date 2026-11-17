// Bosh ekran.
//
// Uch bo'limdan iborat (pastki menyu orqali almashadi):
//   0 — yaqinlashayotgan hodisalar (shu faylda);
//   1 — o'tgan hodisalar (past_screen.dart);
//   2 — sozlamalar (settings_screen.dart).
//
// Sanoqlar har soniyada yangilanadi: ekran SoatProvider'ni "tinglaydi"
// (`context.watch`), soat tiqillaganda qayta chiziladi.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../constants/matnlar.dart';
import '../models/hodisa.dart';
import '../providers/hodisa_provider.dart';
import '../providers/soat_provider.dart';
import '../providers/sozlamalar_provider.dart';
import '../theme/app_theme.dart';
import '../utils/sana_format.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/countdown_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/next_event_card.dart';
import '../widgets/selectable_pill.dart';
import '../widgets/stat_tile.dart';
import '../widgets/week_strip.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';
import 'past_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bolim = 0;

  void _yangiHodisa() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ro'yxat pastki menyu ostidan ham ko'rinib turishi uchun.
      extendBody: true,
      body: SafeArea(
        bottom: false,
        // IndexedStack ikkala bo'limni ham saqlab turadi: almashganda
        // aylantirish (scroll) joyi yo'qolmaydi.
        child: IndexedStack(
          index: _bolim,
          children: [
            _YaqinlashayotganlarBolimi(onQoshish: _yangiHodisa),
            const PastScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomMenu(
        tanlanganIndeks: _bolim,
        onTanlash: (indeks) => setState(() => _bolim = indeks),
        onQoshish: _yangiHodisa,
      ),
    );
  }
}

class _YaqinlashayotganlarBolimi extends StatelessWidget {
  const _YaqinlashayotganlarBolimi({required this.onQoshish});

  final VoidCallback onQoshish;

  @override
  Widget build(BuildContext context) {
    final hozir = context.watch<SoatProvider>().hozir;
    final provider = context.watch<HodisaProvider>();
    final r = context.ranglar;

    if (provider.yuklanmoqda) {
      return const Center(child: CircularProgressIndicator());
    }

    final kelayotganlar = provider.kelayotganlar(hozir);
    final engYaqin = provider.engYaqin(hozir);

    return ListView(
      // Pastdan 120 joy: oxirgi kartochka menyu ostida qolib ketmasligi uchun.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        _Sarlavha(hozir: hozir),
        const SizedBox(height: 20),
        if (provider.xato != null)
          _XatoXabari(matn: provider.xato!, onQayta: provider.yuklash)
        else if (provider.bosh)
          EmptyState(
            belgi: Icons.hourglass_empty_rounded,
            sarlavha: Matnlar.haliHodisaYoq,
            izoh: Matnlar.haliHodisaYoqIzoh,
            tugmaMatni: Matnlar.hodisaQoshish,
            onTugma: onQoshish,
          )
        else ...[
          if (engYaqin != null) ...[
            NextEventCard(
              hodisa: engYaqin,
              hozir: hozir,
              onTap: () => hodisaniOchish(context, engYaqin),
            ),
            const SizedBox(height: 12),
          ],
          WeekStrip(bugun: hozir, hodisaBormi: provider.kundaHodisaBor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  belgi: Icons.event_note_outlined,
                  son: provider.kelayotganSoni(hozir),
                  nomi: Matnlar.yaqinlashayotgan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  belgi: Icons.date_range_outlined,
                  son: provider.yettiKunIchidaSoni(hozir),
                  nomi: Matnlar.shuHafta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FiltrQatori(
            tanlangan: provider.filtr,
            onTanlash: provider.filtrniTanlash,
          ),
          const SizedBox(height: 12),
          if (kelayotganlar.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                provider.filtr == null
                    ? Matnlar.yaqinlashayotganYoq
                    : Matnlar.buTurdaHodisaYoq,
                textAlign: TextAlign.center,
                style: TextStyle(color: r.ikkinchiMatn),
              ),
            ),
          for (final hodisa in kelayotganlar)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CountdownCard(
                hodisa: hodisa,
                hozir: hozir,
                onTap: () => hodisaniOchish(context, hodisa),
              ),
            ),
        ],
      ],
    );
  }
}

/// Bugungi sana va salomlashuv: "Xayrli tong," / "Kamronbek".
/// Ism sozlamalarda kiritilmagan bo'lsa, "xush kelibsiz" yoziladi.
class _Sarlavha extends StatelessWidget {
  const _Sarlavha({required this.hozir});

  final DateTime hozir;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    final ism = context.watch<SozlamalarProvider>().ism;
    const kattaYozuv = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      height: 1.15,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bugungiSarlavha(hozir),
          style: TextStyle(fontSize: 14, color: r.ikkinchiMatn),
        ),
        const SizedBox(height: 12),
        Text('${salomlashuv(hozir)},', style: kattaYozuv),
        Text(
          ism.isEmpty ? Matnlar.xushKelibsiz : ism,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: kattaYozuv.copyWith(color: r.ikkinchiMatn),
        ),
      ],
    );
  }
}

/// Tur bo'yicha filtr: "Barchasi", "Imtihon", "Tadbir"...
class _FiltrQatori extends StatelessWidget {
  const _FiltrQatori({required this.tanlangan, required this.onTanlash});

  final HodisaTuri? tanlangan;
  final ValueChanged<HodisaTuri?> onTanlash;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SelectablePill(
            matn: Matnlar.barchasi,
            tanlangan: tanlangan == null,
            onTap: () => onTanlash(null),
          ),
          for (final tur in HodisaTuri.values) ...[
            const SizedBox(width: 6),
            SelectablePill(
              matn: tur.nomi,
              tanlangan: tanlangan == tur,
              onTap: () => onTanlash(tur),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bazani o'qishda xato bo'lsa ko'rsatiladi. Ilova qulamaydi.
class _XatoXabari extends StatelessWidget {
  const _XatoXabari({required this.matn, required this.onQayta});

  final String matn;
  final VoidCallback onQayta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Icon(Icons.error_outline, size: 40, color: context.ranglar.ikkinchiMatn),
        const SizedBox(height: 12),
        Text(matn, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onQayta, child: const Text(Matnlar.qaytaUrinish)),
      ],
    );
  }
}
