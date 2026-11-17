// Pastdagi suzuvchi menyu: oq kapsula ichida bo'limlar va yonida
// yashil dumaloq "+" tugmasi.

import 'package:material_ui/material_ui.dart';

import '../constants/matnlar.dart';
import '../theme/app_theme.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({
    super.key,
    required this.tanlanganIndeks,
    required this.onTanlash,
    required this.onQoshish,
  });

  /// Hozir qaysi bo'lim ochiq: 0 — bosh sahifa, 1 — o'tgan hodisalar.
  final int tanlanganIndeks;
  final ValueChanged<int> onTanlash;
  final VoidCallback onQoshish;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: r.kartochka,
              shape: const StadiumBorder(),
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MenyuTugmasi(
                      belgi: Icons.home_outlined,
                      tanlanganBelgi: Icons.home,
                      tavsif: Matnlar.boshSahifa,
                      tanlangan: tanlanganIndeks == 0,
                      onTap: () => onTanlash(0),
                    ),
                    const SizedBox(width: 16),
                    _MenyuTugmasi(
                      belgi: Icons.history,
                      tanlanganBelgi: Icons.history,
                      tavsif: Matnlar.otganHodisalar,
                      tanlangan: tanlanganIndeks == 1,
                      onTap: () => onTanlash(1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: Matnlar.hodisaQoshish,
              child: Material(
                color: r.urgu,
                shape: const CircleBorder(),
                elevation: 6,
                shadowColor: r.urgu.withValues(alpha: 0.5),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onQoshish,
                  child: SizedBox.square(
                    dimension: 56,
                    child: Icon(Icons.add, size: 28, color: r.urguUstida),
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

class _MenyuTugmasi extends StatelessWidget {
  const _MenyuTugmasi({
    required this.belgi,
    required this.tanlanganBelgi,
    required this.tavsif,
    required this.tanlangan,
    required this.onTap,
  });

  final IconData belgi;
  final IconData tanlanganBelgi;
  final String tavsif;
  final bool tanlangan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Semantics(
      selected: tanlangan,
      child: IconButton(
        onPressed: onTap,
        tooltip: tavsif,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(
          tanlangan ? tanlanganBelgi : belgi,
          color: tanlangan ? r.urgu : r.ikkinchiMatn,
        ),
      ),
    );
  }
}
