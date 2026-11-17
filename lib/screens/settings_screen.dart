// Sozlamalar ekrani: ism, mavzu (yorug'/qorong'i) va standart eslatma.
// Har bir o'zgarish darhol saqlanadi, alohida "Saqlash" tugmasi kerak emas.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../constants/matnlar.dart';
import '../models/hodisa.dart';
import '../providers/sozlamalar_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/section_label.dart';
import '../widgets/selectable_pill.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SozlamalarProvider>();
    final r = context.ranglar;

    // Mavzu variantlari va ularning nomlari.
    const mavzular = {
      ThemeMode.system: Matnlar.mavzuTelefon,
      ThemeMode.light: Matnlar.mavzuYorug,
      ThemeMode.dark: Matnlar.mavzuQorongi,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 22),
          child: Text(
            Matnlar.sozlamalar,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 24),
        const SectionLabel(Matnlar.ismingiz),
        TextFormField(
          // Sozlamalar ilova ochilishidan oldin yuklangani uchun
          // boshlang'ich qiymat shu yerda tayyor turadi.
          initialValue: s.ism,
          maxLength: SozlamalarProvider.ismMaxUzunlik,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: Matnlar.ismMisol,
            helperText: Matnlar.ismIzoh,
          ),
          onChanged: context.read<SozlamalarProvider>().ismniOzgartirish,
        ),
        const SizedBox(height: 16),
        const SectionLabel(Matnlar.mavzu),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in mavzular.entries)
              SelectablePill(
                matn: m.value,
                tanlangan: s.mavzu == m.key,
                onTap: () => s.mavzuniOzgartirish(m.key),
              ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionLabel(Matnlar.standartEslatma),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final oraliq in EslatmaOraligi.values)
              SelectablePill(
                matn: oraliq.nomi,
                tanlangan: s.standartEslatma == oraliq,
                onTap: () => s.standartEslatmaniOzgartirish(oraliq),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8),
          child: Text(
            Matnlar.standartEslatmaIzoh,
            style: TextStyle(fontSize: 12, color: r.ikkinchiMatn),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          Matnlar.ilovaHaqida,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: r.ikkinchiMatn),
        ),
      ],
    );
  }
}
