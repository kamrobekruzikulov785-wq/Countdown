// O'tgan hodisalar bo'limi: vaqti kelgan yoki o'tib ketgan hodisalar,
// eng oxirgisi birinchi. Hodisa vaqti kelishi bilan u bosh ekrandan
// avtomatik shu yerga o'tadi.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../constants/matnlar.dart';
import '../providers/hodisa_provider.dart';
import '../providers/soat_provider.dart';
import '../widgets/countdown_card.dart';
import '../widgets/empty_state.dart';
import 'detail_screen.dart';

class PastScreen extends StatelessWidget {
  const PastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hozir = context.watch<SoatProvider>().hozir;
    final provider = context.watch<HodisaProvider>();

    if (provider.yuklanmoqda) {
      return const Center(child: CircularProgressIndicator());
    }

    final otganlar = provider.otganlar(hozir);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 22),
          child: Text(
            Matnlar.otganHodisalar,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 20),
        if (otganlar.isEmpty)
          const EmptyState(
            belgi: Icons.history,
            sarlavha: Matnlar.otganYoq,
            izoh: Matnlar.otganYoqIzoh,
          ),
        for (final hodisa in otganlar)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CountdownCard(
              hodisa: hodisa,
              hozir: hozir,
              onTap: () => hodisaniOchish(context, hodisa),
            ),
          ),
      ],
    );
  }
}
