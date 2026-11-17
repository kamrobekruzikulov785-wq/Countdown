// Bo'lim sarlavhasi: maydonlar ustidagi kichik kulrang yozuv ("Sana", "Tur").

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.matn, {super.key});

  final String matn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        matn,
        style: TextStyle(fontSize: 13, color: context.ranglar.ikkinchiMatn),
      ),
    );
  }
}
