// Kichik raqamli blok: belgi, katta son va izoh ("3 / Yaqinlashayotgan").

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.belgi,
    required this.son,
    required this.nomi,
  });

  final IconData belgi;
  final int son;
  final String nomi;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(belgi, size: 20, color: r.matn),
            const SizedBox(height: 10),
            Text(
              '$son',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFeatures: tengRaqamlar,
              ),
            ),
            Text(nomi, style: TextStyle(fontSize: 12, color: r.ikkinchiMatn)),
          ],
        ),
      ),
    );
  }
}
