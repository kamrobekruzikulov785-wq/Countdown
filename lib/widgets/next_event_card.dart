// Bosh ekrandagi yashil "Eng yaqin hodisa" kartochkasi:
// chapda halqa (qancha kutildi), o'ngda nom va jonli sanoq.

import 'package:material_ui/material_ui.dart';

import '../constants/matnlar.dart';
import '../models/hodisa.dart';
import '../theme/app_theme.dart';
import '../utils/countdown_format.dart';
import 'progress_ring.dart';

class NextEventCard extends StatelessWidget {
  const NextEventCard({
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
    final ulush = kutishUlushi(
      yaratilgan: hodisa.yaratilgan,
      sana: hodisa.sana,
      hozir: hozir,
    );
    final halqa = halqaQiymati(qolgan);

    return Material(
      color: r.urguFon,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProgressRing(
                qiymat: ulush,
                olcham: 76,
                qalinlik: 7,
                rang: r.urgu,
                izRangi: r.urguIz,
                semantikMatn:
                    "Kutish vaqtining ${(ulush * 100).round()} foizi o'tdi",
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${halqa.son}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                        color: r.urguMatn,
                        fontFeatures: tengRaqamlar,
                      ),
                    ),
                    Text(
                      halqa.birlik,
                      style: TextStyle(fontSize: 11, color: r.urguIkkinchiMatn),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Matnlar.engYaqinHodisa,
                      style: TextStyle(fontSize: 12, color: r.urguIkkinchiMatn),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hodisa.nomi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: r.urguMatn,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sanoqMatni(qolgan),
                      style: TextStyle(
                        fontSize: 14,
                        color: r.urguIkkinchiMatn,
                        fontFeatures: tengRaqamlar,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
