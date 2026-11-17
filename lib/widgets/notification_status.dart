// Sozlamalardagi "Bildirishnomalar" bo'limi:
// - ruxsat holati (yashil: yoqilgan / sariq: o'chirilgan);
// - o'chirilgan bo'lsa, "Ruxsat berish" tugmasi;
// - "Sinov bildirishnomasi" tugmasi.
//
// Foydalanuvchi telefon sozlamalariga chiqib, ruxsatni o'zgartirib qaytsa,
// holat avtomatik yangilanadi (ilova qayta ochilganda tekshiriladi).

import 'package:material_ui/material_ui.dart';

import '../constants/matnlar.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationStatus extends StatefulWidget {
  const NotificationStatus({super.key});

  @override
  State<NotificationStatus> createState() => _NotificationStatusState();
}

class _NotificationStatusState extends State<NotificationStatus>
    with WidgetsBindingObserver {
  final _xizmat = NotificationService.instance;
  bool? _yoqilgan; // null — hali tekshirilmagan

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tekshirish();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Ilova fondan qaytganda (masalan, telefon sozlamalaridan) qayta tekshiramiz.
  @override
  void didChangeAppLifecycleState(AppLifecycleState holat) {
    if (holat == AppLifecycleState.resumed) _tekshirish();
  }

  Future<void> _tekshirish() async {
    bool natija;
    try {
      natija = await _xizmat.yoqilganmi();
    } catch (_) {
      natija = false;
    }
    if (mounted) setState(() => _yoqilgan = natija);
  }

  Future<void> _ruxsatBerish() async {
    try {
      final berildi = await _xizmat.ruxsatSorash();
      // Avval rad etilgan bo'lsa, Android oyna chiqarmaydi:
      // unda telefon sozlamalarini ochib beramiz.
      if (!berildi) await _xizmat.sozlamalarniOchish();
    } catch (_) {}
    await _tekshirish();
  }

  Future<void> _sinov() async {
    final xabarchi = ScaffoldMessenger.of(context);
    try {
      await _xizmat.sinovKorsatish();
      xabarchi.showSnackBar(
        const SnackBar(content: Text(Matnlar.sinovYuborildi)),
      );
    } catch (_) {
      xabarchi.showSnackBar(
        const SnackBar(content: Text(Matnlar.bildirishnomaOchiqIzoh)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.ranglar;
    final yoqilgan = _yoqilgan ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: yoqilgan ? r.urguFon : r.ogohlantirishFon,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                yoqilgan
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                color: yoqilgan ? r.urguMatn : r.ogohlantirishMatn,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yoqilgan
                          ? Matnlar.bildirishnomaYoqilgan
                          : Matnlar.bildirishnomaOchiq,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: yoqilgan ? r.urguMatn : r.ogohlantirishMatn,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      yoqilgan
                          ? Matnlar.bildirishnomaYoqilganIzoh
                          : Matnlar.bildirishnomaOchiqIzoh,
                      style: TextStyle(
                        fontSize: 12,
                        color: yoqilgan
                            ? r.urguIkkinchiMatn
                            : r.ogohlantirishMatn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_yoqilgan == false) ...[
          FilledButton(
            onPressed: _ruxsatBerish,
            child: const Text(Matnlar.ruxsatBerish),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: _sinov,
          icon: const Icon(Icons.notifications_none),
          label: const Text(Matnlar.sinovBildirishnomasi),
          style: OutlinedButton.styleFrom(
            foregroundColor: r.matn,
            side: BorderSide(color: r.ajratuvchi),
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
          ),
        ),
      ],
    );
  }
}
