// Kapsula shaklidagi tanlov tugmasi: filtrlar ("Barchasi", "Imtihon")
// va qo'shish ekranidagi tur tanlash uchun.

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class SelectablePill extends StatelessWidget {
  const SelectablePill({
    super.key,
    required this.matn,
    required this.tanlangan,
    required this.onTap,
  });

  final String matn;
  final bool tanlangan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Semantics(
      selected: tanlangan,
      button: true,
      child: Material(
        // Tanlangani qora (qorong'i mavzuda oq), qolganlari kartochka rangida.
        color: tanlangan ? r.matn : r.kartochka,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48), // barmoq uchun qulay
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  matn,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: tanlangan ? r.fon : r.ikkinchiMatn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
