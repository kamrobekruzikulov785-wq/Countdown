// Ro'yxatdagi bitta hodisa kartochkasi.
//
// Tepada: sana (chapda) va vaqt (o'ngda), ingichka chiziq.
// Pastda: rang nuqtasi, nom va tur, o'ngda jonli sanoq.
// Hodisa o'tgan bo'lsa, sanoq o'rniga "3 kun oldin" yoziladi.

import 'package:material_ui/material_ui.dart';

import '../constants/belgilar.dart';
import '../models/hodisa.dart';
import '../theme/app_theme.dart';
import '../utils/countdown_format.dart';
import '../utils/sana_format.dart';

class CountdownCard extends StatelessWidget {
  const CountdownCard({
    super.key,
    required this.hodisa,
    required this.hozir,
    required this.onTap,
  });

  final Hodisa hodisa;
  final DateTime hozir;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    final qolgan = hodisa.qolganVaqt(hozir);
    final otgan = hodisa.otganmi(hozir);
    final birKundanKam = !otgan && qolgan.inHours < 24;

    // O'ng tomondagi matn va uning rangi.
    final sanoq = otgan ? otganVaqtMatni(-qolgan) : sanoqMatni(qolgan);
    final sanoqRangi = otgan
        ? r.ikkinchiMatn
        : (birKundanKam ? r.urgu : r.matn); // 1 kundan kam qolsa — yashil

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    qisqaSana(hodisa.sana),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    vaqtMatni(hodisa.sana),
                    style: TextStyle(color: r.ikkinchiMatn),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(hodisa.rang),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nom uchun joyning 3/5 qismi, sanoq uchun 2/5 qismi.
                  // Tor ekranda yoki katta shriftda ham hech narsa chiqib ketmaydi.
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hodisa.nomi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              turBelgisi(hodisa.turi),
                              size: 14,
                              color: r.ikkinchiMatn,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                hodisa.turi.nomi,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: r.ikkinchiMatn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sanoq sig'masa, o'qiladigan darajada kichrayadi (lekin kesilmaydi).
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          sanoq,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: sanoqRangi,
                            fontFeatures: tengRaqamlar,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
