// Batafsil ekran: bitta hodisa haqida hamma narsa.
//
// - katta halqa va kun / soat / daqiqa / soniya bloklari (har soniyada yangilanadi);
// - sana o'zbekcha: "15-dekabr, 2026, 09:00";
// - tur, eslatmalar, izoh;
// - tahrirlash va o'chirish (o'chirishdan oldin tasdiqlash oynasi chiqadi);
// - vaqti o'tgan hodisa uchun "Hodisa boshlandi / o'tdi" holati.
//
// Ekran hodisaning o'zini emas, faqat `id` sini oladi va hodisani har safar
// provider'dan qidiradi. Shunda tahrirlashdan qaytilganda yangi ma'lumot
// darhol ko'rinadi.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../constants/belgilar.dart';
import '../constants/matnlar.dart';
import '../models/hodisa.dart';
import '../providers/hodisa_provider.dart';
import '../providers/soat_provider.dart';
import '../theme/app_theme.dart';
import '../utils/countdown_format.dart';
import '../utils/sana_format.dart';
import '../widgets/countdown_blocks.dart';
import '../widgets/progress_ring.dart';
import 'edit_screen.dart';

/// Ro'yxatdagi hodisa bosilganda batafsil ekranni ochadi.
void hodisaniOchish(BuildContext context, Hodisa hodisa) {
  final id = hodisa.id;
  if (id == null) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => DetailScreen(hodisaId: id)),
  );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.hodisaId});

  final int hodisaId;

  Future<void> _ochirish(BuildContext context, Hodisa hodisa) async {
    final tasdiq = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(Matnlar.ochirishSavol),
        content: Text(Matnlar.ochirishIzoh(hodisa.nomi)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(Matnlar.bekorQilish),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text(Matnlar.ochirish),
          ),
        ],
      ),
    );
    if (tasdiq != true || !context.mounted) return;

    final provider = context.read<HodisaProvider>();
    final xabarchi = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await provider.ochirish(hodisaId);
      navigator.pop();
      xabarchi.showSnackBar(const SnackBar(content: Text(Matnlar.ochirildi)));
    } catch (_) {
      xabarchi.showSnackBar(
        const SnackBar(content: Text(Matnlar.ochirishXatosi)),
      );
    }
  }

  void _tahrirlash(BuildContext context, Hodisa hodisa) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditScreen(hodisa: hodisa)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hozir = context.watch<SoatProvider>().hozir;
    final hodisa = context.watch<HodisaProvider>().idBoyicha(hodisaId);
    final r = context.ranglar;

    // O'chirilgan hodisa (ekran yopilishidan oldingi bir lahza uchun).
    if (hodisa == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Matnlar.batafsil)),
        body: const Center(child: Text(Matnlar.hodisaTopilmadi)),
      );
    }

    final qolgan = hodisa.qolganVaqt(hozir);
    final otgan = hodisa.otganmi(hozir);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Matnlar.batafsil),
        actions: [
          IconButton(
            tooltip: Matnlar.tahrirlash,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _tahrirlash(context, hodisa),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HalqaKartochkasi(hodisa: hodisa, hozir: hozir),
            if (!otgan) ...[
              const SizedBox(height: 10),
              CountdownBlocks(qolgan: qolgan),
            ],
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MalumotQatori(
                      nomi: Matnlar.sana,
                      qiymat: Text(toliqSana(hodisa.sana)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _MalumotQatori(
                      nomi: Matnlar.tur,
                      qiymat: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(turBelgisi(hodisa.turi), size: 18),
                          const SizedBox(width: 6),
                          Text(hodisa.turi.nomi),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Text(
                      Matnlar.eslatmalar,
                      style: TextStyle(color: r.ikkinchiMatn),
                    ),
                    const SizedBox(height: 10),
                    if (hodisa.eslatmalar.isEmpty)
                      const Text(Matnlar.eslatmaYoq)
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final e in hodisa.eslatmalar)
                            _EslatmaBelgisi(matn: e.nomi),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (hodisa.izoh.isNotEmpty) ...[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Matnlar.izoh,
                        style: TextStyle(fontSize: 12, color: r.ikkinchiMatn),
                      ),
                      const SizedBox(height: 6),
                      Text(hodisa.izoh, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _ochirish(context, hodisa),
              icon: const Icon(Icons.delete_outline),
              label: const Text(Matnlar.ochirish),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: r.ajratuvchi),
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yashil kartochka: katta halqa, nom va holat yozuvi.
class _HalqaKartochkasi extends StatelessWidget {
  const _HalqaKartochkasi({required this.hodisa, required this.hozir});

  final Hodisa hodisa;
  final DateTime hozir;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    final qolgan = hodisa.qolganVaqt(hozir);
    final otgan = hodisa.otganmi(hozir);
    final ulush = kutishUlushi(
      yaratilgan: hodisa.yaratilgan,
      sana: hodisa.sana,
      hozir: hozir,
    );
    final foiz = (ulush * 100).round();

    // Halqa markazi va ostidagi holat matni.
    final Widget markaz;
    final String holat;
    if (otgan) {
      // Vaqti kelganiga 1 soatdan oshmagan bo'lsa — "boshlandi", aks holda "o'tdi".
      final otganVaqt = -qolgan;
      holat = otganVaqt.inHours < 1
          ? Matnlar.hodisaBoshlandi
          : '${Matnlar.hodisaOtdi} · ${otganVaqtMatni(otganVaqt)}';
      markaz = Icon(Icons.flag_outlined, size: 40, color: r.urguMatn);
    } else {
      final halqa = halqaQiymati(qolgan);
      holat = Matnlar.kutishFoizi(foiz);
      markaz = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${halqa.son}',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              height: 1.1,
              color: r.urguMatn,
              fontFeatures: tengRaqamlar,
            ),
          ),
          Text(
            '${halqa.birlik} ${Matnlar.qoldi}',
            style: TextStyle(fontSize: 13, color: r.urguIkkinchiMatn),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: r.urguFon,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ProgressRing(
            qiymat: ulush,
            olcham: 132,
            qalinlik: 9,
            rang: r.urgu,
            izRangi: r.urguIz,
            semantikMatn: holat,
            child: markaz,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(hodisa.rang),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  hodisa.nomi,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: r.urguMatn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            holat,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: r.urguIkkinchiMatn),
          ),
        ],
      ),
    );
  }
}

/// "Sana ........ 15-dekabr, 2026, 09:00" ko'rinishidagi qator.
class _MalumotQatori extends StatelessWidget {
  const _MalumotQatori({required this.nomi, required this.qiymat});

  final String nomi;
  final Widget qiymat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(nomi, style: TextStyle(color: context.ranglar.ikkinchiMatn)),
        const SizedBox(width: 12),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: qiymat),
        ),
      ],
    );
  }
}

/// Yashil fondagi kichik eslatma belgisi: "🔔 1 kun oldin".
class _EslatmaBelgisi extends StatelessWidget {
  const _EslatmaBelgisi({required this.matn});

  final String matn;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: r.urguFon,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 16, color: r.urguMatn),
          const SizedBox(width: 4),
          Text(matn, style: TextStyle(fontSize: 13, color: r.urguMatn)),
        ],
      ),
    );
  }
}
