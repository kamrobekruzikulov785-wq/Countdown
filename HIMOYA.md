# Himoyaga tayyorgarlik: Countdown ilovasi

Bu fayl himoyada ilovani o'zingiz tushuntirib berishingiz uchun yozilgan. Avval 1–4 bo'limlarni o'qing, keyin 5-bo'limdagi savollarga javob berishni mashq qiling. Har bir javobda kodning qayerga qarash kerakligi ham ko'rsatilgan.

---

## 1. Ilova nima qiladi (bir jumlada)

Foydalanuvchi imtihon yoki tadbir sanasini kiritadi, ilova esa unga qancha vaqt qolganini **har soniyada** ko'rsatib turadi va sana yaqinlashganda **bildirishnoma** yuboradi. Hammasi **internetsiz** ishlaydi.

---

## 2. Ilova qanday tuzilgan: ma'lumot oqimi

Kod 4 ta qatlamga bo'lingan. Har bir qatlam faqat o'zidan keyingisi bilan gaplashadi:

```
 Ekran (UI)            screens/, widgets/        foydalanuvchi ko'radigan qism
    │  context.watch / context.read
    ▼
 Provider              providers/hodisa_provider.dart   holat: hodisalar ro'yxati
    │
    ▼
 Repository            data/hodisa_repository.dart      Map ⇄ Hodisa obyekti
    │
    ▼
 DatabaseHelper        data/database_helper.dart        SQL so'rovlar (sqflite)
    │
    ▼
 SQLite fayl           telefonda: countdown.db
```

**Misol: foydalanuvchi yangi hodisani saqlasa nima bo'ladi?**

1. `EditScreen` (`screens/edit_screen.dart`) maydonlarni tekshiradi: nom bo'sh emasmi, sana kelajakdami.
2. Hammasi to'g'ri bo'lsa, `Hodisa` obyektini yasab, `provider.qoshish(hodisa)` ni chaqiradi.
3. `HodisaProvider` uni `HodisaRepository` ga beradi.
4. Repository `hodisa.toMap()` bilan obyektni jadval qatoriga aylantiradi va `DatabaseHelper.qoshish()` orqali bazaga yozadi. Baza yangi `id` qaytaradi.
5. Provider yangi hodisani ro'yxatga qo'shadi, saralaydi va `notifyListeners()` ni chaqiradi. Shundan keyin bosh ekran **o'zi** qayta chiziladi.
6. So'ng provider `NotificationService.rejalashtirish()` ni chaqirib, eslatmalarni qo'yadi.

**Nega shunday bo'lingan?** Har bir qism bitta ishni qiladi. Masalan, bazani boshqasiga almashtirsak, faqat `data/` papkasi o'zgaradi, ekranlarga tegilmaydi. Testlarda ham bazani "soxta" nusxa bilan almashtira olamiz (`test/soxta_xizmatlar.dart`).

**Model:** `models/hodisa.dart`. Unda `Hodisa` (id, nomi, sana, turi, izoh, eslatmalar, rang, yaratilgan) va ikkita `enum` bor: `HodisaTuri` (Imtihon, Tadbir, Tug'ilgan kun, Boshqa) va `EslatmaOraligi` (1 kun oldin, 1 soat oldin, aynan vaqtida).

**SQLite sana va ro'yxatni to'g'ridan-to'g'ri saqlay olmaydi**, shuning uchun `toMap()` da:
- sana millisekundlardagi son sifatida saqlanadi (`millisecondsSinceEpoch`);
- eslatmalar vergul bilan ajratilgan matnga aylanadi: `"birKunOldin,birSoatOldin"`.

---

## 3. Sanoq qanday yangilanadi: `Timer` va `Duration`

- `providers/soat_provider.dart` da **bitta** `Timer.periodic(Duration(seconds: 1), ...)` bor. U har soniyada joriy vaqtni (`DateTime.now()`) yangilab, `notifyListeners()` chaqiradi.
- Sanoq ko'rsatadigan ekranlar `context.watch<SoatProvider>()` bilan shu "soat"ni tinglaydi va har soniyada qayta chiziladi.
- **Nega bitta taymer?** Har bir kartochkaga alohida taymer qo'yilsa, 20 ta hodisada 20 ta taymer bo'lib, telefon ortiqcha ishlaydi. Bitta umumiy taymer hammasiga yetadi.
- Qolgan vaqt: `hodisa.sana.difference(hozir)`. Natija `Duration` (vaqt oralig'i) bo'ladi.
- `utils/countdown_format.dart` uni bo'laklarga ajratadi:
  - kun = `qolgan.inDays`
  - soat = `qolgan.inHours % 24` (kunlardan ortgan soatlar)
  - daqiqa = `qolgan.inMinutes % 60`
  - soniya = `qolgan.inSeconds % 60`
  - matn: `"12 kun 04:31:09"`. Vaqt kelgan bo'lsa: `"Boshlandi"`.
- Halqa foizi (`kutishUlushi`): `(hozir − yaratilgan) / (sana − yaratilgan)`, natija 0 dan 1 gacha.
- Taymer `dispose()` da to'xtatiladi (`_taymer.cancel()`), shunda xotirada keraksiz ish qolmaydi.

---

## 4. Bildirishnoma qanday rejalashtiriladi va nega `timezone` kerak

Asosiy fayl: `services/notification_service.dart`. Ishlatilgan paket: `flutter_local_notifications`.

- **Lokal bildirishnoma** server yoki internet orqali kelmaydi. Ilova Android'ning o'ziga "shu vaqtda shu xabarni ko'rsat" deb topshiradi (AlarmManager). Shuning uchun ilova yopiq bo'lsa ham eslatma keladi.
- **Saqlashda:** har bir tanlangan eslatma uchun bitta bildirishnoma `zonedSchedule` bilan rejalashtiriladi. Vaqti: `hodisa.sana − oraliq` (masalan, 09:00 − 1 soat = 08:00). Vaqti o'tib ketgan eslatma qo'yilmaydi.
- **ID** (har bir eslatmaning raqami): `hodisaId * 10 + oraliq tartibi`. Masalan, 7-hodisaning "1 soat oldin" eslatmasi 71 bo'ladi. Shunda hodisa o'chirilganda uning eslatmalarini aniq topib bekor qilamiz.
- **Tahrirlashda:** eskilari bekor qilinadi va yangi vaqt bo'yicha qayta qo'yiladi. **O'chirishda:** bekor qilinadi.
- **Ilova ochilganda:** bazadagi kelajakdagi barcha hodisalar uchun eslatmalar qayta tekshirilib tiklanadi (`hammasiniTiklash`). Telefon qayta yoqilganda esa Android'ning o'zi tiklaydi: buning uchun `RECEIVE_BOOT_COMPLETED` ruxsati va `ScheduledNotificationBootReceiver` qo'shilgan.
- **Nega `timezone` kerak?** `zonedSchedule` vaqtni oddiy `DateTime` sifatida emas, **vaqt mintaqasi** bilan birga (`TZDateTime`, masalan `Asia/Tashkent`) oladi. `flutter_timezone` telefonning mintaqasini aniqlaydi, `timezone` esa dunyo mintaqalari bazasini beradi. Shunda telefon soati, mintaqasi yoki yozgi/qishki vaqt o'zgarsa ham eslatma to'g'ri soatda chiqadi.
- **Aniqlik:** telefon ruxsat bergan bo'lsa, `exactAllowWhileIdle` ishlatiladi, ya'ni eslatma aynan belgilangan daqiqada chiqadi. Ruxsat bo'lmasa, `inexactAllowWhileIdle` ishlaydi: Android batareyani tejash uchun eslatmani biroz kechiktirishi mumkin.
- **Android 13+** da bildirishnoma ruxsati foydalanuvchidan so'raladi. Rad etilsa, ilova qulamaydi, faqat "eslatmalar chiqmaydi" degan xabar ko'rsatadi.

---

## 5. O'qituvchi berishi mumkin bo'lgan 10 ta savol

**1. Ilova internetsiz qanday ishlaydi? Ma'lumot qayerda saqlanadi?**
Barcha ma'lumot telefonning o'zidagi SQLite bazasida (`countdown.db`) saqlanadi. Biz `sqflite` paketidan foydalanganmiz. Bildirishnomalar ham lokal, ya'ni Android'ning o'zi ko'rsatadi. Server, Firebase yoki internet ishlatilmaydi. → `data/database_helper.dart`

**2. Nima uchun `provider` tanladingiz? `setState` dan farqi nima?**
`setState` faqat bitta ekran ichidagi holatni boshqaradi. Bizda esa hodisalar ro'yxati bir nechta ekranda kerak: bosh ekran, o'tganlar, batafsil. `ChangeNotifier` + `provider` bilan ro'yxat bir joyda turadi, o'zgarganda `notifyListeners()` hamma ekranlarni yangilaydi. → `providers/hodisa_provider.dart`

**3. Sanoq har soniyada qanday yangilanadi? Nega har kartochkaga alohida taymer qo'ymadingiz?**
`SoatProvider` da bitta `Timer.periodic(1 soniya)` bor. Ekranlar uni `context.watch` bilan tinglaydi. Bitta taymer hamma kartochkaga yetadi. Ko'p taymer telefonni ortiqcha yuklab, batareyani tez tugatadi. → `providers/soat_provider.dart`

**4. Qolgan kun, soat, daqiqani qanday hisoblaysiz?**
`sana.difference(hozir)` bilan `Duration` olinadi. Kun = `inDays`, soat = `inHours % 24`, daqiqa = `inMinutes % 60`, soniya = `inSeconds % 60`. `%` qoldiqni oladi, ya'ni to'liq kunlardan ortgan soatlarni. → `utils/countdown_format.dart`

**5. Noto'g'ri kiritishlar qanday tekshiriladi?**
`utils/validators.dart` da: nom bo'sh bo'lmasin (faqat bo'shliqlar ham bo'sh hisoblanadi) va 60 belgidan oshmasin, izoh 200 belgigacha, sana kelajakda bo'lsin. Tanlangan eslatma vaqti o'tib ketgan bo'lsa, sariq ogohlantirish chiqadi. Xato bo'lsa saqlanmaydi va ekran xato joyiga suriladi. Bularning hammasi testlar bilan tekshirilgan. → `test/validators_test.dart`

**6. Bildirishnoma qanday ishlaydi? Ilova yopiq bo'lsa ham keladimi?**
Ha, keladi. `zonedSchedule` eslatmani Android'ning AlarmManager tizimiga topshiradi. Vaqti kelganda Android ilovani ochmasdan xabar ko'rsatadi. Har bir eslatmaning unikal ID'si bor (`hodisaId*10 + tartib`). Tahrirlashda qayta qo'yiladi, o'chirishda bekor qilinadi. → `services/notification_service.dart`

**7. `timezone` paketi nima uchun kerak?**
Rejalashtirish vaqt mintaqasi bilan ishlaydi (`TZDateTime`). Shunda telefonning mintaqasi yoki soati o'zgarsa ham eslatma to'g'ri vaqtda chiqadi. `flutter_timezone` telefon mintaqasini (`Asia/Tashkent`) aniqlab beradi.

**8. Ilova qulamasligi uchun nima qilingan?**
Baza ochilmasa, xato xabari va "Qayta urinish" tugmasi chiqadi. Bildirishnoma xatolari `try/catch` bilan ushlanadi, ya'ni hodisa baribir saqlanadi. Bazada noma'lum tur bo'lsa, "Boshqa" deb o'qiladi. Kichik ekranda vaqt tanlash oynasi xato berayotgan edi: telefonda sinab topdim va klaviatura rejimini o'chirib tuzatdim. Testlar barcha ekranlarni 360 px kenglik va katta shriftda tekshiradi.

**9. Ma'lumotlar bazasi tuzilishi qanday? Yangi jadval qanday qo'shildi?**
Ikkita jadval bor: `hodisalar` (id, nomi, sana, turi, izoh, eslatmalar, rang, yaratilgan) va `sozlamalar` (kalit, qiymat). Sozlamalar jadvali keyinroq qo'shildi. Buning uchun baza versiyasi 1 dan 2 ga oshirildi va `onUpgrade` da faqat yangi jadval yaratiladi, eski hodisalarga tegilmaydi. → `data/database_helper.dart`

**10. AI'dan qanday foydalandingiz?**
Claude Code yordamida yozdim, bu README'da ochiq yozilgan. Dizayn yo'nalishini o'zim tanladim: 3 ta referens berib, uslubni tasdiqladim. Har bir bosqichni ko'rib, ruxsat berdim. Ilovani o'z telefonimda sinab, xatolarni topdim. Kodni tushunish uchun har bir faylda o'zbekcha izohlar bor va shu qo'llanmani o'rgandim.

---

## 6. Qo'shimcha: tez-tez so'raladigan kichik savollar

- **Qorong'i mavzu qanday ishlaydi?** `theme/app_theme.dart` da ikkita mavzu bor (yorug' va qorong'i). Sozlamadagi tanlov `SozlamalarProvider.mavzu` da saqlanadi va `MaterialApp.themeMode` ga beriladi.
- **Matnlar qayerda?** Hammasi `constants/matnlar.dart` da, bitta joyda.
- **Filtr qanday ishlaydi?** `HodisaProvider._filtr` da tanlangan tur turadi. `kelayotganlar()` faqat shu turdagi hodisalarni qaytaradi (`where`).
- **O'tgan hodisa qanday ajratiladi?** `hodisa.otganmi(hozir)`, ya'ni sana hozirgi vaqtdan keyin emasmi. Har soniyada tekshiriladi, shuning uchun vaqti kelgan hodisa o'zi "O'tgan hodisalar" bo'limiga o'tadi.
- **Testlarni qanday ishga tushirasiz?** `flutter test`. Jami 30 ta test bor.
