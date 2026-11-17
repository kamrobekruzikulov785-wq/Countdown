// Hodisa qo'shish va tahrirlash ekrani.
//
// Bitta ekran ikkala ishni bajaradi: `hodisa` berilsa — tahrirlash,
// berilmasa — yangi hodisa qo'shish.
//
// Tekshiruvlar:
// - nom bo'sh bo'lmasin (60 belgigacha), izoh 200 belgigacha;
// - sana va vaqt o'tmishda bo'lmasin;
// - tanlangan eslatma vaqti o'tib ketgan bo'lsa, ogohlantirish chiqadi.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../constants/matnlar.dart';
import '../models/hodisa.dart';
import '../providers/hodisa_provider.dart';
import '../providers/sozlamalar_provider.dart';
import '../theme/app_theme.dart';
import '../utils/sana_format.dart';
import '../utils/validators.dart';
import '../widgets/section_label.dart';
import '../widgets/selectable_pill.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, this.hodisa});

  /// Tahrirlanadigan hodisa. Yangi hodisa uchun `null`.
  final Hodisa? hodisa;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Forma kaliti: barcha maydonlarni birdaniga tekshirish uchun.
  final _formKaliti = GlobalKey<FormState>();

  late final TextEditingController _nomController;
  late final TextEditingController _izohController;
  late DateTime _kun; // faqat sana (soatsiz)
  late TimeOfDay _vaqt; // faqat soat va daqiqa
  late HodisaTuri _turi;
  late Set<EslatmaOraligi> _eslatmalar;
  late int _rang;
  String? _sanaXatosi;
  bool _saqlanmoqda = false;

  bool get _tahrirlashmi => widget.hodisa != null;

  /// Tanlangan kun va vaqtni bitta sanaga birlashtiradi.
  DateTime get _tanlanganSana =>
      DateTime(_kun.year, _kun.month, _kun.day, _vaqt.hour, _vaqt.minute);

  @override
  void initState() {
    super.initState();
    final h = widget.hodisa;
    // Yangi hodisa uchun standart qiymat: ertaga soat 09:00.
    final ertaga = DateTime.now().add(const Duration(days: 1));
    final sana = h?.sana ?? DateTime(ertaga.year, ertaga.month, ertaga.day, 9);

    _nomController = TextEditingController(text: h?.nomi ?? '');
    _izohController = TextEditingController(text: h?.izoh ?? '');
    _kun = DateTime(sana.year, sana.month, sana.day);
    _vaqt = TimeOfDay(hour: sana.hour, minute: sana.minute);
    _turi = h?.turi ?? HodisaTuri.imtihon;
    // Yangi hodisada sozlamalardagi standart eslatma oldindan belgilanadi.
    _eslatmalar = Set.of(
      h?.eslatmalar ?? [context.read<SozlamalarProvider>().standartEslatma],
    );
    _rang = h?.rang ?? hodisaRanglari.first.toARGB32();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _izohController.dispose();
    super.dispose();
  }

  Future<void> _sanaTanlash() async {
    final bugun = DateUtils.dateOnly(DateTime.now());
    final tanlangan = await showDatePicker(
      context: context,
      initialDate: _kun.isBefore(bugun) ? bugun : _kun,
      firstDate: bugun, // o'tgan kunlarni tanlab bo'lmaydi
      lastDate: DateTime(bugun.year + 10, 12, 31),
      // Faqat kalendar: vaqt oynasidagi kabi klaviatura rejimi o'chirilgan.
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (tanlangan == null) return; // foydalanuvchi bekor qildi
    setState(() {
      _kun = tanlangan;
      _sanaXatosi = null;
    });
  }

  Future<void> _vaqtTanlash() async {
    final tanlangan = await showTimePicker(
      context: context,
      initialTime: _vaqt,
      // Faqat soat siferblati. Klaviatura rejimi o'chirilgan: kichik
      // ekranlarda klaviatura ochilganda Flutter'ning vaqt oynasi
      // sig'may qolib, xato beradi (material_ui 1.11.1 kutubxonasi xatosi).
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
    if (tanlangan == null) return;
    setState(() {
      _vaqt = tanlangan;
      _sanaXatosi = null;
    });
  }

  void _eslatmaniAlmashtirish(EslatmaOraligi oraliq, bool? belgilandi) {
    setState(() {
      if (belgilandi ?? false) {
        _eslatmalar.add(oraliq);
      } else {
        _eslatmalar.remove(oraliq);
      }
    });
  }

  Future<void> _saqlash() async {
    final hozir = DateTime.now();
    final formaTogri = _formKaliti.currentState!.validate();
    final sanaXatosi = Validatorlar.sana(_tanlanganSana, hozir);
    setState(() => _sanaXatosi = sanaXatosi);
    if (!formaTogri || sanaXatosi != null) return; // xato bor: saqlamaymiz

    // `await` dan keyin `context` ishlatmaslik uchun kerakli narsalarni
    // oldindan olib qo'yamiz.
    final provider = context.read<HodisaProvider>();
    final xabarchi = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final eski = widget.hodisa;
    final hodisa = Hodisa(
      id: eski?.id,
      nomi: _nomController.text.trim(),
      sana: _tanlanganSana,
      turi: _turi,
      izoh: _izohController.text.trim(),
      // Eslatmalar har doim bir xil tartibda saqlanadi.
      eslatmalar: EslatmaOraligi.values.where(_eslatmalar.contains).toList(),
      rang: _rang,
      yaratilgan: eski?.yaratilgan ?? hozir,
    );

    setState(() => _saqlanmoqda = true);
    try {
      if (eski == null) {
        await provider.qoshish(hodisa);
      } else {
        await provider.yangilash(hodisa);
      }
      xabarchi.showSnackBar(const SnackBar(content: Text(Matnlar.saqlandi)));
      navigator.pop();
    } catch (_) {
      if (mounted) setState(() => _saqlanmoqda = false);
      xabarchi.showSnackBar(
        const SnackBar(content: Text(Matnlar.saqlashXatosi)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    final otganEslatmalar = Validatorlar.otganEslatmalar(
      _tanlanganSana,
      _eslatmalar,
      DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_tahrirlashmi ? Matnlar.tahrirlash : Matnlar.yangiHodisa),
      ),
      body: SafeArea(
        child: Form(
          key: _formKaliti,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const SectionLabel(Matnlar.nomi),
              TextFormField(
                controller: _nomController,
                maxLength: Validatorlar.nomMaxUzunlik,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: Matnlar.nomiMisol),
                validator: Validatorlar.nom,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TanlashKartochkasi(
                      sarlavha: Matnlar.sana,
                      qiymat: kunVaOy(_kun),
                      belgi: Icons.calendar_today_outlined,
                      xato: _sanaXatosi != null,
                      onTap: _sanaTanlash,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TanlashKartochkasi(
                      sarlavha: Matnlar.vaqt,
                      qiymat: soatMinut(_vaqt.hour, _vaqt.minute),
                      belgi: Icons.schedule,
                      xato: _sanaXatosi != null,
                      onTap: _vaqtTanlash,
                    ),
                  ),
                ],
              ),
              if (_sanaXatosi != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Text(
                    _sanaXatosi!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const SectionLabel(Matnlar.tur),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tur in HodisaTuri.values)
                    SelectablePill(
                      matn: tur.nomi,
                      tanlangan: tur == _turi,
                      onTap: () => setState(() => _turi = tur),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const SectionLabel(Matnlar.eslatmalar),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final oraliq in EslatmaOraligi.values)
                      CheckboxListTile(
                        value: _eslatmalar.contains(oraliq),
                        title: Text(oraliq.nomi),
                        activeColor: r.urgu,
                        checkColor: r.urguUstida,
                        onChanged: (belgi) =>
                            _eslatmaniAlmashtirish(oraliq, belgi),
                      ),
                  ],
                ),
              ),
              if (otganEslatmalar.isNotEmpty)
                _Ogohlantirish(
                  matn: Matnlar.eslatmaOtgan(
                    otganEslatmalar.map((e) => e.nomi).join(', '),
                  ),
                ),
              const SizedBox(height: 20),
              const SectionLabel(Matnlar.rang),
              _RangTanlash(
                tanlangan: _rang,
                onTanlash: (rang) => setState(() => _rang = rang),
              ),
              const SizedBox(height: 20),
              const SectionLabel(Matnlar.izoh),
              TextFormField(
                controller: _izohController,
                maxLength: Validatorlar.izohMaxUzunlik,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: Matnlar.izohMisol),
                validator: Validatorlar.izoh,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saqlanmoqda ? null : _saqlash,
                child: _saqlanmoqda
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text(Matnlar.saqlash),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sana yoki vaqtni ko'rsatadigan va bosilganda tanlash oynasini ochadigan blok.
class _TanlashKartochkasi extends StatelessWidget {
  const _TanlashKartochkasi({
    required this.sarlavha,
    required this.qiymat,
    required this.belgi,
    required this.xato,
    required this.onTap,
  });

  final String sarlavha;
  final String qiymat;
  final IconData belgi;
  final bool xato;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    final xatoRangi = Theme.of(context).colorScheme.error;
    return Material(
      color: r.kartochka,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: xato ? BorderSide(color: xatoRangi) : BorderSide.none,
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    sarlavha,
                    style: TextStyle(fontSize: 12, color: r.ikkinchiMatn),
                  ),
                  const Spacer(),
                  Icon(belgi, size: 18, color: r.ikkinchiMatn),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                qiymat,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sariq fondagi ogohlantirish xabari.
class _Ogohlantirish extends StatelessWidget {
  const _Ogohlantirish({required this.matn});

  final String matn;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: r.ogohlantirishFon,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: r.ogohlantirishMatn),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              matn,
              style: TextStyle(fontSize: 13, color: r.ogohlantirishMatn),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartochka rangini tanlash uchun 5 ta doiracha.
class _RangTanlash extends StatelessWidget {
  const _RangTanlash({required this.tanlangan, required this.onTanlash});

  final int tanlangan;
  final ValueChanged<int> onTanlash;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final (indeks, rang) in hodisaRanglari.indexed)
              Semantics(
                label: '${Matnlar.rang} ${indeks + 1}',
                selected: rang.toARGB32() == tanlangan,
                button: true,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onTanlash(rang.toARGB32()),
                  child: SizedBox.square(
                    dimension: 48, // bosish maydoni 48 dp
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: rang,
                          shape: BoxShape.circle,
                          // Tanlangan rang atrofida halqa chiziladi.
                          border: rang.toARGB32() == tanlangan
                              ? Border.all(color: r.matn, width: 2.5)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
