// Ilovadagi barcha o'zbekcha matnlar shu bir joyda.
//
// Matnni o'zgartirish kerak bo'lsa, ekran fayllarini qidirib o'tirmasdan
// shu faylning o'zida tuzatiladi.

class Matnlar {
  Matnlar._();

  static const ilovaNomi = 'Countdown';

  // --- Bosh ekran ---
  static const xushKelibsiz = 'xush kelibsiz';
  static const engYaqinHodisa = 'Eng yaqin hodisa';
  static const yaqinlashayotgan = 'Yaqinlashayotgan';
  static const shuHafta = '7 kun ichida';
  static const barchasi = 'Barchasi';
  static const haliHodisaYoq = "Hali hodisa yo'q";
  static const haliHodisaYoqIzoh =
      "Imtihon yoki muhim sanani qo'shing. Qolgan vaqtni shu yerda sanab boramiz.";
  static const buTurdaHodisaYoq = "Bu turda yaqinlashayotgan hodisa yo'q";
  static const yaqinlashayotganYoq = "Yaqinlashayotgan hodisa yo'q";
  static const yuklashXatosi =
      "Ma'lumotlarni o'qib bo'lmadi. Qayta urinib ko'ring.";
  static const qaytaUrinish = 'Qayta urinish';

  // --- Pastki menyu ---
  static const boshSahifa = 'Bosh sahifa';
  static const otganHodisalar = "O'tgan hodisalar";
  static const hodisaQoshish = "Hodisa qo'shish";

  // --- O'tgan hodisalar ---
  static const otganYoq = "O'tgan hodisalar yo'q";
  static const otganYoqIzoh = 'Vaqti kelgan hodisalar shu yerda saqlanadi.';
  static const otdi = "O'tdi";

  // --- Sanoq ---
  static const boshlandi = 'Boshlandi';
  static const kun = 'kun';
  static const soat = 'soat';
  static const daqiqa = 'daqiqa';
  static const soniya = 'soniya';
  static const qoldi = 'qoldi';
  static const hozirgina = 'hozirgina';

  // --- Sozlamalar ---
  static const sozlamalar = 'Sozlamalar';
  static const ismingiz = 'Ismingiz';
  static const ismMisol = 'Ismingizni yozing';
  static const ismIzoh = "Bosh ekrandagi salomlashuvda ko'rinadi.";
  static const mavzu = 'Mavzu';
  static const mavzuTelefon = "Telefon bo'yicha";
  static const mavzuYorug = "Yorug'";
  static const mavzuQorongi = "Qorong'i";
  static const standartEslatma = 'Standart eslatma';
  static const standartEslatmaIzoh =
      "Yangi hodisa qo'shganda shu eslatma oldindan belgilanadi.";
  static const ilovaHaqida = 'Countdown 1.0 · Internetsiz ishlaydi';

  // --- Bildirishnomalar ---
  static const bildirishnomalar = 'Bildirishnomalar';
  static const bildirishnomaYoqilgan = 'Bildirishnomalar yoqilgan';
  static const bildirishnomaYoqilganIzoh = "Eslatmalar o'z vaqtida keladi.";
  static const bildirishnomaOchiq = "Bildirishnomalar o'chirilgan";
  static const bildirishnomaOchiqIzoh =
      "Ruxsat berilmasa, eslatmalar chiqmaydi. Sanoq baribir ishlaydi.";
  static const ruxsatBerish = 'Ruxsat berish';
  static const sinovBildirishnomasi = 'Sinov bildirishnomasi';
  static const sinovYuborildi = 'Sinov bildirishnomasi yuborildi';
  static const ruxsatYoqSaqlandi =
      "Saqlandi. Bildirishnomalarga ruxsat yo'q, shuning uchun eslatmalar "
      'chiqmaydi. Uni sozlamalarda yoqish mumkin.';

  // --- Batafsil ---
  static const batafsil = 'Batafsil';
  static const hodisaTopilmadi = 'Hodisa topilmadi';
  static const hodisaBoshlandi = 'Hodisa boshlandi';
  static const hodisaOtdi = "Hodisa o'tdi";
  static const eslatmaYoq = "Eslatma qo'yilmagan";
  static const ochirish = "O'chirish";
  static const ochirishSavol = "Hodisani o'chirasizmi?";
  static const bekorQilish = 'Bekor qilish';
  static const ochirildi = "O'chirildi";
  static const ochirishXatosi = "O'chirib bo'lmadi. Qayta urinib ko'ring.";

  /// O'chirishni tasdiqlash oynasidagi matn.
  static String ochirishIzoh(String nomi) =>
      "\"$nomi\" butunlay o'chiriladi. Buni qaytarib bo'lmaydi.";

  /// Halqa ostidagi matn: "Kutish vaqtining 82% o'tdi".
  static String kutishFoizi(int foiz) => "Kutish vaqtining $foiz% o'tdi";

  // --- Qo'shish va tahrirlash ---
  static const yangiHodisa = 'Yangi hodisa';
  static const tahrirlash = 'Tahrirlash';
  static const nomi = 'Nomi';
  static const nomiMisol = 'Matematika imtihoni';
  static const sana = 'Sana';
  static const vaqt = 'Vaqt';
  static const tur = 'Tur';
  static const eslatmalar = 'Eslatmalar';
  static const rang = 'Rang';
  static const izoh = 'Izoh (ixtiyoriy)';
  static const izohMisol = 'Kalkulyator olib borish';
  static const saqlash = 'Saqlash';
  static const saqlandi = 'Saqlandi';
  static const saqlashXatosi = "Saqlab bo'lmadi. Qayta urinib ko'ring.";

  // --- Tekshiruv (validatsiya) xabarlari ---
  static const nomBosh = 'Hodisa nomini kiriting';
  static const nomUzun = 'Nom 60 belgidan oshmasin';
  static const izohUzun = 'Izoh 200 belgidan oshmasin';
  static const sanaOtgan = "Sana va vaqt kelajakda bo'lishi kerak";

  /// O'tib ketgan eslatmalar haqida ogohlantirish.
  static String eslatmaOtgan(String nomlar) =>
      "Bu eslatmalar vaqti o'tib ketgan va ular chiqmaydi: $nomlar";

  /// Hafta kunlarining qisqa nomlari. `DateTime.weekday` 1 (dushanba) dan
  /// 7 (yakshanba) gacha bo'lgani uchun ro'yxat dushanbadan boshlanadi.
  static const haftaKunlari = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
}
