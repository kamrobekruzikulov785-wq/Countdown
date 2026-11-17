// Lokal bildirishnomalar xizmati.
//
// Internet va server kerak emas: eslatma telefonning o'zida, Android'ning
// "budilnik" tizimi (AlarmManager) orqali rejalashtiriladi.
//
// Vazifalari:
// - hodisa saqlanganda: har bir tanlangan eslatma uchun bitta bildirishnoma;
// - tahrirlanganda: eskilarini bekor qilib, qaytadan rejalashtirish;
// - o'chirilganda: bekor qilish;
// - ilova ochilganda: bazadagi kelajakdagi hodisalar uchun hammasini tiklash.
//
// Nima uchun `timezone` kerak: plagin vaqtni vaqt mintaqasi (masalan,
// "Asia/Tashkent") bilan birga oladi. Shunda telefon soati yoki mintaqasi
// o'zgarsa ham eslatma to'g'ri vaqtda chiqadi.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/hodisa.dart';
import '../utils/eslatma_matni.dart';

class NotificationService {
  NotificationService._();

  /// Yagona nusxa (singleton).
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plagin =
      FlutterLocalNotificationsPlugin();

  bool _tayyor = false;

  /// Sinov bildirishnomasi ID si (hodisa eslatmalari 10 dan boshlanadi).
  static const int _sinovId = 0;

  /// Android "kanali": telefon sozlamalarida "Hodisa eslatmalari" nomi bilan ko'rinadi.
  static const NotificationDetails _korinish = NotificationDetails(
    android: AndroidNotificationDetails(
      'hodisa_eslatmalari',
      'Hodisa eslatmalari',
      channelDescription: 'Imtihon va tadbirlar yaqinlashganda eslatadi',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_bildirishnoma',
    ),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plagin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Ilova ochilishida bir marta chaqiriladi (main.dart).
  Future<void> ishgaTushirish() async {
    if (_tayyor) return;
    tz.initializeTimeZones();
    try {
      final mintaqa = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(mintaqa.identifier));
    } catch (_) {
      // Mintaqani aniqlab bo'lmasa ham ishlayveradi: `TZDateTime.from`
      // vaqt nuqtasini to'g'ri o'girib beradi.
    }
    await _plagin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_bildirishnoma'),
      ),
    );
    _tayyor = true;
  }

  /// Bildirishnomalar yoqilganmi (foydalanuvchi ruxsat berganmi).
  Future<bool> yoqilganmi() async {
    return await _android?.areNotificationsEnabled() ?? false;
  }

  /// Ruxsat so'raydi (Android 13+ da oyna chiqadi). Natija: yoqildimi.
  /// Rad etilsa, ilova qulamaydi — shunchaki `false` qaytadi.
  Future<bool> ruxsatSorash() async {
    if (await yoqilganmi()) return true;
    await _android?.requestNotificationsPermission();
    return yoqilganmi();
  }

  /// Telefonning shu ilova uchun bildirishnoma sozlamalarini ochadi.
  Future<void> sozlamalarniOchish() async {
    await _plagin.openAppNotificationSettings();
  }

  /// Darhol bitta sinov bildirishnomasini ko'rsatadi.
  Future<void> sinovKorsatish() async {
    await _plagin.show(
      id: _sinovId,
      title: 'Sinov bildirishnomasi',
      body: 'Bildirishnomalar ishlayapti. Eslatmalar shu ko\'rinishda keladi.',
      notificationDetails: _korinish,
    );
  }

  /// Hodisaning eslatmalarini (qaytadan) rejalashtiradi.
  Future<void> rejalashtirish(Hodisa hodisa) async {
    final id = hodisa.id;
    if (id == null) return;
    // Tahrirlashda eski vaqtdagi eslatmalar qolib ketmasligi uchun avval bekor qilamiz.
    await bekorQilish(id);

    for (final oraliq in rejalashtiriladiganEslatmalar(hodisa, DateTime.now())) {
      final matn = eslatmaMatni(hodisa, oraliq);
      await _plagin.zonedSchedule(
        id: eslatmaId(id, oraliq),
        title: matn.sarlavha,
        body: matn.matn,
        scheduledDate: tz.TZDateTime.from(oraliq.vaqti(hodisa.sana), tz.local),
        notificationDetails: _korinish,
        // "Taxminiy" rejim: aniq budilnik ruxsati kerak emas. Android
        // batareyani tejash uchun eslatmani bir necha daqiqaga surishi mumkin.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '$id',
      );
    }
  }

  /// Hodisaning barcha eslatmalarini bekor qiladi.
  Future<void> bekorQilish(int hodisaId) async {
    for (final oraliq in EslatmaOraligi.values) {
      await _plagin.cancel(id: eslatmaId(hodisaId, oraliq));
    }
  }

  /// Ilova ochilganda: barcha rejalashtirilganlarni tozalab, bazadagi
  /// kelajakdagi hodisalar uchun qaytadan rejalashtiradi.
  Future<void> hammasiniTiklash(List<Hodisa> hodisalar) async {
    await _plagin.cancelAllPendingNotifications();
    final hozir = DateTime.now();
    for (final hodisa in hodisalar) {
      if (!hodisa.otganmi(hozir)) await rejalashtirish(hodisa);
    }
  }
}
