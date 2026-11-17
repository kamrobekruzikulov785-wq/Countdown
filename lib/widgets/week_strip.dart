// Hafta qatori: bugundan boshlab 7 kun.
// Bugungi kun yashil bilan ajratiladi, hodisa bor kunlar ostida nuqta turadi.

import 'package:material_ui/material_ui.dart';

import '../constants/matnlar.dart';
import '../theme/app_theme.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.bugun,
    required this.hodisaBormi,
  });

  final DateTime bugun;

  /// Berilgan kunda hodisa bor-yo'qligini aytuvchi funksiya.
  final bool Function(DateTime kun) hodisaBormi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _KunKatagi(
                // Kunni shunday qo'shish soat o'zgarishlarida ham to'g'ri ishlaydi.
                kun: DateTime(bugun.year, bugun.month, bugun.day + i),
                bugunmi: i == 0,
                hodisaBormi: hodisaBormi,
              ),
            ),
          ),
      ],
    );
  }
}

class _KunKatagi extends StatelessWidget {
  const _KunKatagi({
    required this.kun,
    required this.bugunmi,
    required this.hodisaBormi,
  });

  final DateTime kun;
  final bool bugunmi;
  final bool Function(DateTime kun) hodisaBormi;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    final nuqta = hodisaBormi(kun);
    final kunNomi = Matnlar.haftaKunlari[kun.weekday - 1];

    return Semantics(
      label: '$kunNomi ${kun.day}${nuqta ? ', hodisa bor' : ''}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bugunmi ? r.urguIz : r.kartochka,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              kunNomi,
              style: TextStyle(
                fontSize: 11,
                color: bugunmi ? r.urguMatn : r.ikkinchiMatn,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${kun.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: bugunmi ? r.urguMatn : r.matn,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: nuqta
                    ? (bugunmi ? r.urguMatn : r.urgu)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
