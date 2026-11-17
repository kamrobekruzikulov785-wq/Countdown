// Batafsil ekrandagi 4 ta katta blok: kun / soat / daqiqa / soniya.

import 'package:material_ui/material_ui.dart';

import '../constants/matnlar.dart';
import '../theme/app_theme.dart';
import '../utils/countdown_format.dart';
import '../utils/sana_format.dart';

class CountdownBlocks extends StatelessWidget {
  const CountdownBlocks({super.key, required this.qolgan});

  /// Hodisagacha qolgan vaqt.
  final Duration qolgan;

  @override
  Widget build(BuildContext context) {
    final q = sanoqQismlari(qolgan);
    return Row(
      children: [
        _Blok(qiymat: ikkiXonali(q.kun), nomi: Matnlar.kun),
        const SizedBox(width: 6),
        _Blok(qiymat: ikkiXonali(q.soat), nomi: Matnlar.soat),
        const SizedBox(width: 6),
        _Blok(qiymat: ikkiXonali(q.daqiqa), nomi: Matnlar.daqiqa),
        const SizedBox(width: 6),
        _Blok(qiymat: ikkiXonali(q.soniya), nomi: Matnlar.soniya),
      ],
    );
  }
}

class _Blok extends StatelessWidget {
  const _Blok({required this.qiymat, required this.nomi});

  final String qiymat;
  final String nomi;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              // FittedBox: 3 xonali kun (masalan, 120) ham sig'ishi uchun.
              FittedBox(
                child: Text(
                  qiymat,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontFeatures: tengRaqamlar,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(nomi, style: TextStyle(fontSize: 11, color: r.ikkinchiMatn)),
            ],
          ),
        ),
      ),
    );
  }
}
