import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// قاموس ترجمة بسيط للواجهة (بدون أدوات بناء إضافية مثل flutter gen-l10n)
/// — كل مفتاح نص له أربع ترجمات. أي شاشة تستدعي `context.tr('key')` تحصل
/// على النص باللغة الحالية تلقائياً. لو المفتاح غير موجود، يرجع المفتاح
/// نفسه كنص احتياطي بدل ما يكسر الشاشة — يسهّل ملاحظة أي نص لم يُترجم بعد.
///
/// ملاحظة مهمة: هذا الملف يغطي حالياً نصوص الواجهة الأساسية (التنقل،
/// الإعدادات، تصنيفات الأذكار) فقط — محتوى الأذكار نفسه (النصوص الشرعية)
/// له مسار ترجمة منفصل تماماً يحتاج مصدراً معتمداً موثوقاً قبل إدراجه
/// (راجع athkar_localization_plan.md).
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _dict = {
    'app_name': {'ar': 'الأذكار', 'en': 'Athkar', 'id': 'Athkar', 'ur': 'اذکار'},
    // يظهر كعنوان صغير فوق ترجمة الآية/الحديث المعروضة تحت النص العربي
    // الأصلي — راجع القاعدة في dhikr_card.dart و azkar_swipe_screen.dart:
    // النص الشرعي (آية أو حديث) يظهر عربياً كاملاً دائماً أولاً، ثم ترجمته
    // تحته كتوضيح، لا كبديل عنه.
    'translationLabel': {'ar': 'الترجمة', 'en': 'Translation', 'id': 'Terjemahan', 'ur': 'ترجمہ'},
    // عدّاد الإنجاز أعلى شاشة الأذكار المتحركة (مثال: "أنجزت ٣ / ١٢") —
    // يحسب الأذكار ذات العدّاد (المكررة أكثر من مرة) التي أكملها المستخدم
    // خلال الجلسة الحالية.
    'dhikrCompletedLabel': {'ar': 'أنجزت', 'en': 'Completed', 'id': 'Selesai', 'ur': 'مکمل'},
    'settings_title': {
      'ar': 'الإعدادات والتذكيرات',
      'en': 'Settings & Reminders',
      'id': 'Pengaturan & Pengingat',
      'ur': 'ترتیبات اور یاد دہانیاں',
    },
    'language_section_title': {
      'ar': 'لغة التطبيق',
      'en': 'App language',
      'id': 'Bahasa aplikasi',
      'ur': 'ایپ کی زبان',
    },
    'accent_color_title': {
      'ar': 'لون التطبيق الثانوي',
      'en': 'Secondary app color',
      'id': 'Warna sekunder aplikasi',
      'ur': 'ایپ کا ثانوی رنگ',
    },
    'accent_color_desc': {
      'ar': 'الأخضر يبقى دائماً اللون الأساسي للتطبيق — هذا فقط للون الثانوي (الحدود والأيقونات والعناوين).',
      'en': 'Green always stays the app\'s primary color — this only changes the secondary color (borders, icons, headings).',
      'id': 'Hijau selalu menjadi warna utama aplikasi — ini hanya mengubah warna sekunder (garis tepi, ikon, judul).',
      'ur': 'سبز رنگ ہمیشہ ایپ کا بنیادی رنگ رہتا ہے — یہ صرف ثانوی رنگ (حدود، آئیکنز اور عنوانات) کو تبدیل کرتا ہے۔',
    },
    'prayer_notif_title': {
      'ar': 'تفعيل تنبيهات أذان الصلاة',
      'en': 'Enable prayer time alerts',
      'id': 'Aktifkan notifikasi waktu salat',
      'ur': 'نماز کے اوقات کی اطلاعات فعال کریں',
    },
    'prayer_notif_desc': {
      'ar': 'تنبيه فور دخول وقت كل صلاة من الصلوات الخمس، بناءً على حساب فلكي حقيقي لمواقيت جدة.',
      'en': 'A notification the moment each of the five daily prayers begins, based on real astronomical calculation for Jeddah.',
      'id': 'Notifikasi tepat saat waktu setiap salat lima waktu tiba, berdasarkan perhitungan astronomi nyata untuk Jeddah.',
      'ur': 'پانچ نمازوں میں سے ہر ایک کا وقت شروع ہوتے ہی اطلاع، جدہ کے حقیقی فلکیاتی حساب کی بنیاد پر۔',
    },
    'random_dhikr_title': {
      'ar': 'تفعيل تنبيهات ذكر عشوائي',
      'en': 'Enable random dhikr reminders',
      'id': 'Aktifkan pengingat dzikir acak',
      'ur': 'بے ترتیب ذکر کی یاد دہانیاں فعال کریں',
    },
    'random_dhikr_desc': {
      'ar': 'تذكير عرضي بذكر قصير مختلف على مدار اليوم (بين ٧ص و١٠م).',
      'en': 'An occasional short dhikr reminder throughout the day (between 7am and 10pm).',
      'id': 'Pengingat dzikir singkat sesekali sepanjang hari (antara pukul 7 pagi dan 10 malam).',
      'ur': 'دن بھر میں کبھی کبھار مختصر ذکر کی یاد دہانی (صبح ۷ سے رات ۱۰ بجے کے درمیان)۔',
    },
    'morning_evening_reminders_title': {
      'ar': 'تفعيل تذكيرات الصباح والمساء',
      'en': 'Enable morning & evening reminders',
      'id': 'Aktifkan pengingat pagi & petang',
      'ur': 'صبح و شام کی یاد دہانیاں فعال کریں',
    },
    'morning_reminder_time': {
      'ar': 'وقت تذكير الصباح',
      'en': 'Morning reminder time',
      'id': 'Waktu pengingat pagi',
      'ur': 'صبح کی یاد دہانی کا وقت',
    },
    'evening_reminder_time': {
      'ar': 'وقت تذكير المساء',
      'en': 'Evening reminder time',
      'id': 'Waktu pengingat petang',
      'ur': 'شام کی یاد دہانی کا وقت',
    },
    'notif_permission_hint': {
      'ar': 'لو ما وصلك التذكير، تأكد إن إذن الإشعارات مفعّل للتطبيق من إعدادات الجهاز.',
      'en': 'If reminders aren\'t arriving, make sure notification permission is enabled for the app in your device settings.',
      'id': 'Jika pengingat tidak muncul, pastikan izin notifikasi diaktifkan untuk aplikasi ini di pengaturan perangkat Anda.',
      'ur': 'اگر یاد دہانی موصول نہ ہو تو یقینی بنائیں کہ آپ کے آلے کی ترتیبات میں اس ایپ کے لیے نوٹیفیکیشن کی اجازت فعال ہے۔',
    },
    // Bottom navigation / home
    'nav_home': {'ar': 'الرئيسية', 'en': 'Home', 'id': 'Beranda', 'ur': 'ہوم'},
    'nav_favorites': {'ar': 'المفضلة', 'en': 'Favorites', 'id': 'Favorit', 'ur': 'پسندیدہ'},
    'nav_search': {'ar': 'بحث', 'en': 'Search', 'id': 'Cari', 'ur': 'تلاش کریں'},
    'nav_settings': {'ar': 'الإعدادات', 'en': 'Settings', 'id': 'Pengaturan', 'ur': 'ترتیبات'},
    'qibla_title': {'ar': 'اتجاه القبلة', 'en': 'Qibla Direction', 'id': 'Arah Kiblat', 'ur': 'قبلہ کی سمت'},
    'qibla_aligned': {
      'ar': 'أنت متجه الآن نحو القبلة ✅',
      'en': 'You are now facing the Qibla ✅',
      'id': 'Anda sekarang menghadap Kiblat ✅',
      'ur': 'آپ اب قبلہ کی طرف رخ کر چکے ہیں ✅',
    },
    'qibla_align_hint': {
      'ar': 'وجّه الجهاز حتى تتطابق أيقونة الكعبة مع المؤشر',
      'en': 'Rotate your device until the Kaaba icon aligns with the marker',
      'id': 'Putar perangkat Anda hingga ikon Ka\'bah sejajar dengan penanda',
      'ur': 'آلے کو گھمائیں یہاں تک کہ کعبہ کا آئیکن نشان کے ساتھ مل جائے',
    },
    'qibla_no_compass_title': {
      'ar': 'الجهاز ما يدعم البوصلة',
      'en': 'Device has no compass',
      'id': 'Perangkat tidak memiliki kompas',
      'ur': 'آلے میں قطب نما موجود نہیں',
    },
    'qibla_location_required_title': {
      'ar': 'صلاحية الموقع مطلوبة',
      'en': 'Location permission required',
      'id': 'Izin lokasi diperlukan',
      'ur': 'مقام کی اجازت درکار ہے',
    },
    'retry': {'ar': 'إعادة المحاولة', 'en': 'Retry', 'id': 'Coba lagi', 'ur': 'دوبارہ کوشش کریں'},

    // asma_allah_screen.dart
    'asmaTitle': {'ar': 'أسماء الله الحسنى', 'en': 'The 99 Names of Allah', 'id': 'Asmaul Husna', 'ur': 'اللہ کے 99 نام'},
    'asmaIntroDescription': {'ar': 'اسم الله (لفظ الجلالة) هو الاسم الأعظم الجامع، وما يلي هو أسماؤه الحسنى التسعة والتسعون الواردة في حديث الترمذي. أهل العلم مختلفون قليلاً في حصر بعض الأسماء (كـ"الرشيد" و"الصبور")، فأثبتناهما معاً كما هو شائع في أغلب المصادر مع التنبيه لذلك.', 'en': 'Allah (the greatest, all-encompassing name) is the supreme name, and below are His 99 beautiful names as reported in the hadith of al-Tirmidhi. Scholars differ slightly on a few names (such as "Ar-Rasheed" and "As-Saboor"), so we included both as is common in most sources, with this note for clarity.', 'id': 'Allah (lafal jalalah) adalah nama teragung yang mencakup semuanya, dan berikut adalah 99 Asmaul Husna-Nya sebagaimana disebutkan dalam hadits At-Tirmidzi. Para ulama sedikit berbeda pendapat dalam menetapkan beberapa nama (seperti "Ar-Rasyid" dan "Ash-Shabur"), sehingga kami mencantumkan keduanya sebagaimana lazim di kebanyakan sumber, disertai catatan ini.', 'ur': 'اللہ (لفظِ جلالہ) سب سے بڑا اور جامع نام ہے، اور ذیل میں اس کے ننانوے اسماء حسنیٰ ہیں جو حدیثِ ترمذی میں مذکور ہیں۔ اہلِ علم بعض ناموں (جیسے "الرشید" اور "الصبور") کے شمار میں قدرے مختلف الرائے ہیں، اس لیے ہم نے دونوں کو شامل کیا ہے جیسا کہ اکثر مصادر میں رائج ہے، اور اس کی وضاحت کر دی گئی ہے۔'},

    // athkar_categories_screen.dart
    'athkarCatTitle': {'ar': 'الأذكار', 'en': 'Athkar', 'id': 'Dzikir', 'ur': 'اذکار'},
    'athkarCatEmptyCategory': {'ar': 'لا توجد أذكار في هذه الفئة بعد', 'en': 'No athkar in this category yet', 'id': 'Belum ada dzikir dalam kategori ini', 'ur': 'اس زمرے میں ابھی کوئی اذکار موجود نہیں'},

    // counters_screen.dart
    'countersTitle': {'ar': 'العدادات', 'en': 'Counters', 'id': 'Penghitung', 'ur': 'کاؤنٹرز'},
    'countersTasbihTitle': {'ar': 'سبحان الله', 'en': 'SubhanAllah', 'id': 'Subhanallah', 'ur': 'سبحان اللہ'},
    'countersTasbihSubtitle': {'ar': 'تسبيح', 'en': 'Tasbih', 'id': 'Tasbih', 'ur': 'تسبیح'},
    'countersHamdTitle': {'ar': 'الحمد لله', 'en': 'Alhamdulillah', 'id': 'Alhamdulillah', 'ur': 'الحمد للہ'},
    'countersHamdSubtitle': {'ar': 'حمد', 'en': 'Praise', 'id': 'Puji', 'ur': 'حمد'},
    'countersIstighfarTitle': {'ar': 'أستغفر الله', 'en': 'Astaghfirullah', 'id': 'Astaghfirullah', 'ur': 'استغفر اللہ'},
    'countersIstighfarSubtitle': {'ar': 'استغفار', 'en': 'Istighfar', 'id': 'Istighfar', 'ur': 'استغفار'},
    'countersMisbahaTitle': {'ar': 'المسبحة العامة', 'en': 'General Tasbih', 'id': 'Tasbih Umum', 'ur': 'عام تسبیح'},
    'countersMisbahaSubtitle': {'ar': 'عداد حر بدون هدف يومي', 'en': 'Free counter with no daily target', 'id': 'Penghitung bebas tanpa target harian', 'ur': 'روزانہ ہدف کے بغیر آزاد کاؤنٹر'},
    'countersTargetLabel': {'ar': 'الهدف', 'en': 'Target', 'id': 'Target', 'ur': 'ہدف'},
    'countersResetTooltip': {'ar': 'إعادة تصفير', 'en': 'Reset', 'id': 'Atur ulang', 'ur': 'دوبارہ صفر کریں'},
    'countersTargetReached': {'ar': 'ما شاء الله، حققت الهدف اليوم ✅', 'en': 'MashaAllah, you reached today\'s target ✅', 'id': 'MasyaAllah, Anda telah mencapai target hari ini ✅', 'ur': 'ماشاءاللہ، آپ نے آج کا ہدف حاصل کر لیا ✅'},

    // dhikr_screen.dart
    'dhikrEmptyList': {'ar': 'لا توجد أذكار', 'en': 'No athkar found', 'id': 'Tidak ada dzikir', 'ur': 'کوئی اذکار موجود نہیں'},

    // favorites_screen.dart
    'favoritesTitle': {'ar': 'المفضلة', 'en': 'Favorites', 'id': 'Favorit', 'ur': 'پسندیدہ'},
    'favoritesEmptyTitle': {'ar': 'لا توجد أذكار مفضّلة بعد', 'en': 'No favorite adhkar yet', 'id': 'Belum ada dzikir favorit', 'ur': 'ابھی تک کوئی پسندیدہ ذکر نہیں'},
    'favoritesEmptyHint': {'ar': 'اضغط على أيقونة النجمة بجانب أي ذكر لإضافته هنا', 'en': 'Tap the star icon next to any dhikr to add it here', 'id': 'Ketuk ikon bintang di samping dzikir mana pun untuk menambahkannya di sini', 'ur': 'کسی بھی ذکر کے ساتھ موجود ستارے کے آئیکن پر ٹیپ کریں تاکہ اسے یہاں شامل کریں'},

    // habits_screen.dart
    'habitsTitle': {'ar': 'متعقب العادات', 'en': 'Habit Tracker', 'id': 'Pelacak Kebiasaan', 'ur': 'عادات ٹریکر'},
    'habitsCompletedPrefix': {'ar': 'أنجزت', 'en': 'Completed', 'id': 'Selesai', 'ur': 'مکمل کیا'},
    'habitsOfMiddle': {'ar': 'من', 'en': 'of', 'id': 'dari', 'ur': 'میں سے'},
    'habitsTodaySuffix': {'ar': 'اليوم', 'en': 'today', 'id': 'hari ini', 'ur': 'آج'},
    'habitsStreakSuffix': {'ar': 'يوم متتالي', 'en': 'day streak', 'id': 'hari berturut-turut', 'ur': 'دن مسلسل'},

    // hijri_calendar_screen.dart
    'hijriTitle': {'ar': 'التقويم الهجري', 'en': 'Hijri Calendar', 'id': 'Kalender Hijriah', 'ur': 'ہجری کیلنڈر'},
    'hijriEventsThisMonth': {'ar': 'مناسبات هذا الشهر', 'en': 'Events this month', 'id': 'Acara bulan ini', 'ur': 'اس مہینے کے مواقع'},
    'hijriApproxNote': {'ar': 'ملاحظة: التقويم حسابي تقريبي، وقد يختلف بيوم أو يومين عن إعلان رؤية الهلال الرسمي في بلدك.', 'en': 'Note: this calendar is an approximate calculation and may differ by a day or two from your country\'s official moon-sighting announcement.', 'id': 'Catatan: kalender ini adalah perhitungan perkiraan dan mungkin berbeda satu atau dua hari dari pengumuman rukyat hilal resmi di negara Anda.', 'ur': 'نوٹ: یہ کیلنڈر ایک تخمینی حساب ہے اور آپ کے ملک کے سرکاری رویت ہلال کے اعلان سے ایک یا دو دن مختلف ہو سکتا ہے۔'},
    'hijriRamadanDayPrefix': {'ar': 'اليوم', 'en': 'Day', 'id': 'Hari', 'ur': 'دن'},
    'hijriRamadanDaySuffix': {'ar': 'من رمضان المبارك', 'en': 'of blessed Ramadan', 'id': 'dari bulan Ramadhan yang penuh berkah', 'ur': 'بابرکت رمضان کا'},
    'hijriRemainingPrefix': {'ar': 'بقي', 'en': 'Remaining', 'id': 'Tersisa', 'ur': 'باقی ہیں'},
    'hijriDaySingular': {'ar': 'يوم', 'en': 'day', 'id': 'hari', 'ur': 'دن'},
    'hijriDaysPlural': {'ar': 'أيام', 'en': 'days', 'id': 'hari', 'ur': 'دن'},
    'hijriEidSuffix': {'ar': 'على عيد الفطر المبارك، تقبل الله منا ومنكم', 'en': 'until the blessed Eid al-Fitr, may Allah accept it from us all', 'id': 'menuju Idul Fitri yang penuh berkah, semoga Allah menerima amal kita semua', 'ur': 'بابرکت عید الفطر تک، اللہ ہم سب سے قبول فرمائے'},
    'hijriEidTomorrow': {'ar': 'غداً عيد الفطر المبارك بإذن الله، تقبل الله منا ومنكم صالح الأعمال', 'en': 'Tomorrow is the blessed Eid al-Fitr, God willing; may Allah accept our good deeds', 'id': 'Besok adalah Idul Fitri yang penuh berkah, insyaAllah; semoga Allah menerima amal saleh kita', 'ur': 'کل ان شاء اللہ بابرکت عید الفطر ہے، اللہ ہمارے نیک اعمال قبول فرمائے'},
    'hijriRamadanMonthTitle': {'ar': 'شهر رمضان المبارك', 'en': 'The Blessed Month of Ramadan', 'id': 'Bulan Ramadhan yang Penuh Berkah', 'ur': 'بابرکت ماہ رمضان'},
    'hijriDaysLeftPrefix': {'ar': 'يفصلنا', 'en': 'We are', 'id': 'Kita', 'ur': 'ہم'},
    'hijriDayAccusativePlural': {'ar': 'يوماً', 'en': 'days', 'id': 'hari', 'ur': 'دن'},
    'hijriRamadanComingSuffix': {'ar': 'عن استقبال رمضان، اللهم بلّغنا رمضان', 'en': 'away from welcoming Ramadan; O Allah, let us reach Ramadan', 'id': 'dari menyambut Ramadhan; ya Allah, sampaikan kami ke bulan Ramadhan', 'ur': 'رمضان کے استقبال سے دور ہیں، اے اللہ ہمیں رمضان تک پہنچا'},
    'hijriRamadanSoon': {'ar': 'رمضان على الأبواب بإذن الله', 'en': 'Ramadan is near, God willing', 'id': 'Ramadhan sudah dekat, insyaAllah', 'ur': 'رمضان قریب ہے، ان شاء اللہ'},

    // عنوان عام للتطبيق (احتياطي، غير مرتبط بشاشة معيّنة حالياً)
    'homeAppTitle': {'ar': 'الأذكار', 'en': 'Athkar', 'id': 'Dzikir', 'ur': 'اذکار'},

    // nearby_mosque_screen.dart
    'mosqueTitle': {'ar': 'أقرب مسجد', 'en': 'Nearest Mosque', 'id': 'Masjid Terdekat', 'ur': 'قریب ترین مسجد'},
    'mosqueServiceDisabledTitle': {'ar': 'خدمة الموقع غير مفعّلة', 'en': 'Location service is off', 'id': 'Layanan lokasi tidak aktif', 'ur': 'مقام کی سروس غیر فعال ہے'},
    'mosqueServiceDisabledBody': {
      'ar': 'فعّل خدمة تحديد الموقع (GPS) من إعدادات جهازك ثم أعد المحاولة.',
      'en': 'Turn on location services (GPS) in your device settings, then try again.',
      'id': 'Aktifkan layanan lokasi (GPS) di pengaturan perangkat Anda, lalu coba lagi.',
      'ur': 'اپنے آلے کی ترتیبات میں مقام کی سروس (GPS) فعال کریں پھر دوبارہ کوشش کریں۔',
    },
    'mosqueLocationPermissionBody': {
      'ar': 'نحتاج صلاحية الوصول لموقعك حتى نفتح لك تطبيق الخرائط مع البحث عن أقرب مسجد.',
      'en': 'We need access to your location to open the maps app with a nearby-mosque search for you.',
      'id': 'Kami memerlukan akses lokasi Anda untuk membuka aplikasi peta dengan pencarian masjid terdekat.',
      'ur': 'ہمیں آپ کے مقام تک رسائی چاہیے تاکہ قریب ترین مسجد کی تلاش کے ساتھ نقشہ ایپ کھول سکیں۔',
    },
    'mosqueLocationDeniedForeverTitle': {'ar': 'صلاحية الموقع مرفوضة', 'en': 'Location permission denied', 'id': 'Izin lokasi ditolak', 'ur': 'مقام کی اجازت مسترد کر دی گئی'},
    'mosqueLocationDeniedForeverBody': {
      'ar': 'تم رفض صلاحية الموقع بشكل دائم. فعّلها يدوياً من إعدادات الجهاز > الخصوصية > خدمات الموقع > الأذكار.',
      'en': 'Location permission was permanently denied. Enable it manually from device Settings > Privacy > Location Services > Athkar.',
      'id': 'Izin lokasi ditolak secara permanen. Aktifkan secara manual dari Pengaturan perangkat > Privasi > Layanan Lokasi > Athkar.',
      'ur': 'مقام کی اجازت مستقل طور پر مسترد کر دی گئی۔ اسے آلے کی ترتیبات > پرائیویسی > لوکیشن سروسز > اذکار سے دستی طور پر فعال کریں۔',
    },
    'mosqueErrorTitle': {'ar': 'تعذّر تحديد موقعك', 'en': 'Couldn\'t determine your location', 'id': 'Tidak dapat menentukan lokasi Anda', 'ur': 'آپ کا مقام معلوم نہیں ہو سکا'},
    'mosqueErrorBody': {
      'ar': 'حدث خطأ غير متوقع أثناء محاولة تحديد موقعك، حاول مرة أخرى.',
      'en': 'An unexpected error occurred while trying to determine your location. Please try again.',
      'id': 'Terjadi kesalahan tak terduga saat mencoba menentukan lokasi Anda. Silakan coba lagi.',
      'ur': 'آپ کا مقام معلوم کرنے کی کوشش کے دوران ایک غیر متوقع خرابی پیش آئی، دوبارہ کوشش کریں۔',
    },
    'mosqueReadyTitle': {'ar': 'تم تحديد موقعك', 'en': 'Your location has been found', 'id': 'Lokasi Anda telah ditemukan', 'ur': 'آپ کا مقام معلوم کر لیا گیا ہے'},
    'mosqueReadyBody': {
      'ar': 'اضغط الزر لفتح تطبيق الخرائط والبحث عن أقرب مسجد إليك.',
      'en': 'Tap the button to open the maps app and search for the nearest mosque.',
      'id': 'Ketuk tombol untuk membuka aplikasi peta dan mencari masjid terdekat.',
      'ur': 'نقشہ ایپ کھولنے اور قریب ترین مسجد تلاش کرنے کے لیے بٹن دبائیں۔',
    },
    'mosqueOpenMapsButton': {'ar': 'فتح الخرائط والبحث عن مسجد', 'en': 'Open Maps & Search for a Mosque', 'id': 'Buka Peta & Cari Masjid', 'ur': 'نقشہ کھولیں اور مسجد تلاش کریں'},

    // qibla_screen.dart (new keys — existing qibla_* keys reused)
    'qibla2NoCompassBody': {
      'ar': 'هذا الجهاز ما فيه حساس بوصلة، أو إنك تجرّب على محاكي (Simulator) — بوصلة القبلة تحتاج جهاز حقيقي فيه حساس بوصلة فعلي.',
      'en': 'This device has no compass sensor, or you\'re testing on a Simulator — the Qibla compass needs a real device with an actual compass sensor.',
      'id': 'Perangkat ini tidak memiliki sensor kompas, atau Anda sedang mencoba di Simulator — kompas Kiblat memerlukan perangkat asli dengan sensor kompas nyata.',
      'ur': 'اس آلے میں قطب نما کا سینسر نہیں ہے، یا آپ سیمولیٹر پر آزما رہے ہیں — قبلہ کمپاس کو حقیقی قطب نما سینسر والا اصل آلہ درکار ہے۔',
    },
    'qibla2LocationBody': {
      'ar': 'نحتاج صلاحية الوصول لموقعك لحساب اتجاه القبلة بدقة.',
      'en': 'We need access to your location to calculate the Qibla direction accurately.',
      'id': 'Kami memerlukan akses lokasi Anda untuk menghitung arah Kiblat secara akurat.',
      'ur': 'قبلہ کی سمت درست طور پر معلوم کرنے کے لیے ہمیں آپ کے مقام تک رسائی چاہیے۔',
    },
    'qibla2North': {'ar': 'ش', 'en': 'N', 'id': 'U', 'ur': 'ش'},
    'qibla2DegreesFromQibla': {
      'ar': 'عن اتجاه القبلة',
      'en': 'from the Qibla direction',
      'id': 'dari arah Kiblat',
      'ur': 'قبلہ کی سمت سے',
    },

    // settings_screen.dart (new keys — existing keys reused)
    'settings2RandomDhikrDesc': {
      'ar': 'تذكير عرضي بذكر قصير مختلف على مدار اليوم (بين ٧ص و١٠م)، زي تطبيق أذكاري.',
      'en': 'An occasional short dhikr reminder throughout the day (between 7am and 10pm), like the Athkary app.',
      'id': 'Pengingat dzikir singkat sesekali sepanjang hari (antara pukul 7 pagi dan 10 malam), seperti aplikasi Athkary.',
      'ur': 'دن بھر میں کبھی کبھار مختصر ذکر کی یاد دہانی (صبح ۷ سے رات ۱۰ بجے کے درمیان)، ایتھکاری ایپ کی طرح۔',
    },
    'settings2Am': {'ar': 'ص', 'en': 'AM', 'id': 'AM', 'ur': 'ص'},
    'settings2Pm': {'ar': 'م', 'en': 'PM', 'id': 'PM', 'ur': 'م'},

    // stats_screen.dart
    'statsTitle': {'ar': 'إحصائياتي', 'en': 'My Stats', 'id': 'Statistik Saya', 'ur': 'میرے اعداد و شمار'},
    'statsStreakLabel': {'ar': 'يوم متتالي', 'en': 'Day streak', 'id': 'Hari berturut-turut', 'ur': 'مسلسل دن'},
    'statsBestStreakLabel': {'ar': 'أفضل سلسلة', 'en': 'Best streak', 'id': 'Rentetan terbaik', 'ur': 'بہترین سلسلہ'},
    'statsTodayLabel': {'ar': 'أذكار اليوم', 'en': 'Today\'s adhkar', 'id': 'Dzikir hari ini', 'ur': 'آج کے اذکار'},
    'statsTotalLabel': {'ar': 'إجمالي كل الأوقات', 'en': 'All-time total', 'id': 'Total sepanjang waktu', 'ur': 'مجموعی کل تعداد'},
    'statsNote': {
      'ar': 'يُحسب "الذكر المكتمل" لما تخلّص عدّ التكرار المطلوب لذكر معيّن (زي التسبيح 33 مرة). واصل يومياً عشان تحافظ على سلسلتك 🔥',
      'en': 'A dhikr counts as "completed" once you finish its required repetition count (like saying Tasbih 33 times). Keep it up daily to maintain your streak 🔥',
      'id': 'Dzikir dihitung "selesai" saat Anda menyelesaikan jumlah pengulangan yang diperlukan untuk dzikir tersebut (seperti Tasbih 33 kali). Lanjutkan setiap hari untuk menjaga rentetan Anda 🔥',
      'ur': '"مکمل ذکر" اس وقت شمار ہوتا ہے جب آپ کسی مخصوص ذکر کے لیے مطلوبہ تکرار مکمل کر لیں (جیسے ۳۳ بار تسبیح)۔ اپنے سلسلے کو برقرار رکھنے کے لیے روزانہ جاری رکھیں 🔥',
    },

    // zakat_calculator_sheet.dart
    'zakatTitle': {'ar': 'حاسبة الزكاة', 'en': 'Zakat Calculator', 'id': 'Kalkulator Zakat', 'ur': 'زکوٰۃ کیلکولیٹر'},
    'zakatSubtitle': {
      'ar': 'أدخل القيم بالريال السعودي حسب علمك بالأسعار الحالية',
      'en': 'Enter values in Saudi riyals based on your knowledge of current prices',
      'id': 'Masukkan nilai dalam Riyal Saudi sesuai pengetahuan Anda tentang harga saat ini',
      'ur': 'موجودہ قیمتوں کے بارے میں اپنی معلومات کے مطابق سعودی ریال میں قدریں درج کریں',
    },
    'zakatCashLabel': {
      'ar': 'المال النقدي (رصيد + مدخرات)',
      'en': 'Cash (balance + savings)',
      'id': 'Uang tunai (saldo + tabungan)',
      'ur': 'نقد رقم (بیلنس + بچت)',
    },
    'zakatGoldLabel': {'ar': 'قيمة الذهب والفضة', 'en': 'Value of gold and silver', 'id': 'Nilai emas dan perak', 'ur': 'سونے اور چاندی کی قیمت'},
    'zakatTradeLabel': {
      'ar': 'عروض التجارة (إن وُجدت)',
      'en': 'Trade goods (if any)',
      'id': 'Barang dagangan (jika ada)',
      'ur': 'تجارتی مال (اگر ہو)',
    },
    'zakatDebtLabel': {
      'ar': 'الديون المستحقة عليك (تُطرح)',
      'en': 'Debts owed by you (deducted)',
      'id': 'Utang yang harus Anda bayar (dikurangkan)',
      'ur': 'آپ کے ذمہ قرض (منہا کیا جائے گا)',
    },
    'zakatNisabLabel': {'ar': 'النصاب التقريبي بالريال', 'en': 'Approximate Nisab in riyals', 'id': 'Perkiraan Nisab dalam Riyal', 'ur': 'ریال میں تخمینی نصاب'},
    'zakatNisabHint': {
      'ar': 'حدّثه حسب سعر الذهب الحالي (~85غ)',
      'en': 'Update it based on the current gold price (~85g)',
      'id': 'Perbarui berdasarkan harga emas saat ini (~85g)',
      'ur': 'اسے سونے کی موجودہ قیمت کے مطابق اپ ڈیٹ کریں (~85 گرام)',
    },
    'zakatCalculateButton': {'ar': 'احسب الزكاة', 'en': 'Calculate Zakat', 'id': 'Hitung Zakat', 'ur': 'زکوٰۃ کا حساب لگائیں'},
    'zakatBelowNisab': {
      'ar': 'المال لم يبلغ النصاب — لا زكاة عليك',
      'en': 'Your wealth hasn\'t reached the Nisab — no Zakat is due',
      'id': 'Harta Anda belum mencapai Nisab — tidak ada Zakat yang wajib',
      'ur': 'آپ کا مال نصاب تک نہیں پہنچا — آپ پر زکوٰۃ واجب نہیں',
    },
    'zakatDueLabel': {'ar': 'الزكاة الواجبة', 'en': 'Zakat due', 'id': 'Zakat yang wajib', 'ur': 'واجب الادا زکوٰۃ'},
    'zakatCurrency': {'ar': 'ريال', 'en': 'riyal', 'id': 'Riyal', 'ur': 'ریال'},
    'zakatFootnote': {
      'ar': 'هذه حاسبة تقديرية للنقد والذهب/الفضة وعروض التجارة فقط، ولا تشمل زكاة الأنعام والزروع. للحالات الخاصة يُستحسن مراجعة أهل العلم.',
      'en': 'This is an estimate calculator for cash, gold/silver and trade goods only — it does not cover Zakat on livestock and crops. For special cases, it\'s best to consult knowledgeable scholars.',
      'id': 'Ini adalah kalkulator perkiraan untuk uang tunai, emas/perak, dan barang dagangan saja — tidak mencakup Zakat ternak dan hasil pertanian. Untuk kasus khusus, sebaiknya konsultasikan dengan para ulama.',
      'ur': 'یہ صرف نقد، سونے/چاندی اور تجارتی مال کے لیے ایک تخمینی کیلکولیٹر ہے، اس میں مویشیوں اور فصلوں کی زکوٰۃ شامل نہیں۔ خاص صورتحال میں اہل علم سے رجوع کرنا بہتر ہے۔',
    },

    // dashboard_home_screen.dart
    'dashSectionAyahHadith': {'ar': 'آية وحديث اليوم', 'en': "Today's Ayah & Hadith", 'id': 'Ayat & Hadis Hari Ini', 'ur': 'آج کی آیت اور حدیث'},
    'dashSectionToolsToday': {'ar': 'أدواتك اليوم', 'en': 'Your tools today', 'id': 'Alat Anda hari ini', 'ur': 'آج کے آلات'},
    'dashToolsSectionCount': {'ar': '٩ أقسام', 'en': '9 sections', 'id': '9 bagian', 'ur': '9 حصے'},
    'dashSectionFreshContent': {'ar': 'محتوى متجدد', 'en': 'Fresh content', 'id': 'Konten terbaru', 'ur': 'تازہ مواد'},
    'dashPrayerTimesFooterNote': {'ar': 'مواقيت جدة (حساب فلكي حقيقي) — تحديد الموقع تلقائياً قريباً', 'en': 'Jeddah prayer times (real astronomical calculation) — automatic location detection coming soon', 'id': 'Waktu salat Jeddah (perhitungan astronomi nyata) — deteksi lokasi otomatis segera hadir', 'ur': 'جدہ کے نماز کے اوقات (حقیقی فلکیاتی حساب) — خودکار مقام کی شناخت جلد آ رہی ہے'},

    'dashToolAthkarTitle': {'ar': 'الأذكار', 'en': 'Athkar', 'id': 'Dzikir', 'ur': 'اذکار'},
    'dashToolAthkarSubtitle': {'ar': 'صباح · مساء', 'en': 'Morning · Evening', 'id': 'Pagi · Petang', 'ur': 'صبح · شام'},
    'dashToolQiblaTitle': {'ar': 'القبلة', 'en': 'Qibla', 'id': 'Kiblat', 'ur': 'قبلہ'},
    'dashToolQiblaSubtitle': {'ar': 'اتجاه دقيق', 'en': 'Precise direction', 'id': 'Arah akurat', 'ur': 'درست سمت'},
    'dashToolZakatTitle': {'ar': 'الزكاة', 'en': 'Zakat', 'id': 'Zakat', 'ur': 'زکوٰۃ'},
    'dashToolZakatSubtitle': {'ar': 'مال · ذهب', 'en': 'Cash · Gold', 'id': 'Uang · Emas', 'ur': 'رقم · سونا'},
    'dashToolKhatmaTitle': {'ar': 'ورد الختمة', 'en': 'Khatma Plan', 'id': 'Rencana Khatam', 'ur': 'ختمہ کا معمول'},
    'dashKhatmaTodayPrefix': {'ar': 'اليوم', 'en': 'Day', 'id': 'Hari ke', 'ur': 'دن'},
    'dashKhatmaOfThirty': {'ar': 'من ٣٠', 'en': 'of 30', 'id': 'dari 30', 'ur': '30 میں سے'},
    'dashKhatmaAlreadyDoneMsg': {'ar': 'أتممت ورد اليوم بالفعل، جزاك الله خيراً 🌙', 'en': "You've already completed today's portion, may Allah reward you 🌙", 'id': 'Anda sudah menyelesaikan bacaan hari ini, semoga Allah membalas kebaikan Anda 🌙', 'ur': 'آپ آج کا ورد پہلے ہی مکمل کر چکے ہیں، اللہ آپ کو اجر دے 🌙'},
    'dashKhatmaDoneMsg': {'ar': 'بارك الله فيك، تم تسجيل ورد اليوم ✅', 'en': "May Allah bless you, today's portion has been recorded ✅", 'id': 'Semoga Allah memberkahi Anda, bacaan hari ini telah dicatat ✅', 'ur': 'اللہ آپ میں برکت ڈالے، آج کا ورد درج کر لیا گیا ✅'},
    'dashToolHijriCalendarTitle': {'ar': 'التقويم الهجري', 'en': 'Hijri Calendar', 'id': 'Kalender Hijriah', 'ur': 'ہجری کیلنڈر'},
    'dashToolCountersTitle': {'ar': 'العدادات', 'en': 'Counters', 'id': 'Penghitung', 'ur': 'شمار کار'},
    'dashToolCountersSubtitle': {'ar': 'تسبيح · حمد · استغفار', 'en': 'Tasbih · Tahmid · Istighfar', 'id': 'Tasbih · Tahmid · Istighfar', 'ur': 'تسبیح · تحمید · استغفار'},
    'dashToolHabitsTitle': {'ar': 'العادات', 'en': 'Habits', 'id': 'Kebiasaan', 'ur': 'عادات'},
    'dashToolHabitsSubtitle': {'ar': 'تعقّب يومي', 'en': 'Daily tracking', 'id': 'Pelacakan harian', 'ur': 'روزانہ نگرانی'},
    'dashToolAsmaAllahTitle': {'ar': 'أسماء الله', 'en': "Names of Allah", 'id': 'Asmaul Husna', 'ur': 'اسمائے الٰہی'},
    'dashToolAsmaAllahSubtitle': {'ar': 'الحسنى', 'en': 'The Most Beautiful', 'id': 'Yang Terindah', 'ur': 'الحسنیٰ'},
    'dashToolNearbyMosqueTitle': {'ar': 'أقرب مسجد', 'en': 'Nearest Mosque', 'id': 'Masjid Terdekat', 'ur': 'قریب ترین مسجد'},
    'dashToolNearbyMosqueSubtitle': {'ar': 'عبر الخرائط', 'en': 'Via maps', 'id': 'Melalui peta', 'ur': 'نقشے کے ذریعے'},
    'dashComingSoonBadge': {'ar': 'قريباً', 'en': 'Coming soon', 'id': 'Segera hadir', 'ur': 'جلد آ رہا ہے'},

    'dashAyahOfDayLabel': {'ar': 'آية اليوم', 'en': "Ayah of the Day", 'id': 'Ayat Hari Ini', 'ur': 'آج کی آیت'},
    'dashTafsirLabel': {'ar': 'التفسير الميسّر:', 'en': 'Simplified interpretation:', 'id': 'Tafsir sederhana:', 'ur': 'آسان تفسیر:'},
    'dashHadithOfDayLabel': {'ar': 'حديث اليوم', 'en': "Hadith of the Day", 'id': 'Hadis Hari Ini', 'ur': 'آج کی حدیث'},
    'dashNarratedByPrefix': {'ar': 'عن', 'en': 'Narrated by', 'id': 'Diriwayatkan dari', 'ur': 'روایت ہے'},
    'dashExplanationLabel': {'ar': 'الشرح:', 'en': 'Explanation:', 'id': 'Penjelasan:', 'ur': 'وضاحت:'},

    'dashTabDailyWird': {'ar': 'الورد اليومي', 'en': 'Daily Portion', 'id': 'Bacaan Harian', 'ur': 'روزانہ ورد'},
    'dashTabListenQuran': {'ar': 'استماع للقرآن', 'en': 'Listen to Quran', 'id': 'Dengarkan Al-Quran', 'ur': 'قرآن سنیں'},
    'dashKhatmaCompletedLabel': {'ar': 'تم إتمام ورد اليوم', 'en': "Today's portion completed", 'id': 'Bacaan hari ini selesai', 'ur': 'آج کا ورد مکمل ہو گیا'},
    'dashKhatmaCompleteButtonLabel': {'ar': 'أتممت هذا الورد', 'en': "Mark today's portion complete", 'id': 'Tandai bacaan hari ini selesai', 'ur': 'اس ورد کو مکمل نشان زد کریں'},
    'dashListenQuranTitle': {'ar': 'الاستماع للقرآن', 'en': 'Listening to Quran', 'id': 'Mendengarkan Al-Quran', 'ur': 'قرآن سننا'},
    'dashListenQuranComingSoonDesc': {'ar': 'مشغّل صوتي بأصوات القرّاء — قريباً بإذن الله', 'en': "An audio player with reciters' voices — coming soon, God willing", 'id': 'Pemutar audio dengan suara qari — segera hadir, insya Allah', 'ur': 'قراء کی آوازوں کے ساتھ آڈیو پلیئر — جلد ان شاء اللہ'},

    'dashFridayTitle': {'ar': 'يوم الجمعة — سيد الأيام', 'en': 'Friday — Master of Days', 'id': 'Hari Jumat — Penghulu Hari', 'ur': 'جمعہ — دنوں کا سردار'},
    'dashFridayDesc': {'ar': 'يُستحبّ اليوم الإكثار من الصلاة على النبي ﷺ، وقراءة سورة الكهف، وتحرّي ساعة الإجابة في آخر ساعة قبل المغرب.', 'en': 'Today it is recommended to send abundant blessings on the Prophet ﷺ, recite Surah Al-Kahf, and seek the hour of acceptance in the last hour before Maghrib.', 'id': 'Hari ini dianjurkan memperbanyak shalawat kepada Nabi ﷺ, membaca Surah Al-Kahfi, dan mencari waktu mustajab di jam terakhir sebelum Maghrib.', 'ur': 'آج نبی کریم ﷺ پر کثرت سے درود بھیجنا، سورہ کہف پڑھنا، اور مغرب سے پہلے آخری گھڑی میں قبولیت کی ساعت تلاش کرنا مستحب ہے۔'},
    'dashRamadanTitle': {'ar': 'رمضان مبارك', 'en': 'Blessed Ramadan', 'id': 'Ramadan Mubarak', 'ur': 'رمضان مبارک'},
    'dashRamadanImsakLabel': {'ar': 'الإمساك (الفجر)', 'en': 'Imsak (Fajr)', 'id': 'Imsak (Subuh)', 'ur': 'امساک (فجر)'},
    'dashRamadanIftarLabel': {'ar': 'الإفطار (المغرب)', 'en': 'Iftar (Maghrib)', 'id': 'Iftar (Maghrib)', 'ur': 'افطار (مغرب)'},
    'dashRamadanDuaText': {'ar': 'من أدعية الإفطار المأثورة: «اللهم لك صمت، وعلى رزقك أفطرت»، و«ذهب الظمأ وابتلت العروق وثبت الأجر إن شاء الله».', 'en': 'From the traditional iftar supplications: "O Allah, for You I fasted and with Your provision I broke my fast," and "Thirst has gone, the veins are moistened, and the reward is confirmed, God willing."', 'id': 'Doa berbuka yang diriwayatkan: "Ya Allah, untuk-Mu aku berpuasa dan dengan rezeki-Mu aku berbuka," dan "Rasa haus telah hilang, urat-urat telah basah, dan pahala telah tetap, insya Allah."', 'ur': 'ماثور افطار کی دعاؤں میں سے: "اے اللہ! تیرے لیے روزہ رکھا اور تیرے رزق سے افطار کیا"، اور "پیاس بجھ گئی، رگیں تر ہو گئیں اور اجر ثابت ہو گیا ان شاء اللہ۔"'},

    'dashQuickZakatLabel': {'ar': 'حساب الزكاة', 'en': 'Zakat Calculator', 'id': 'Kalkulator Zakat', 'ur': 'زکوٰۃ کیلکولیٹر'},
    'dashQuickMoonPhaseLabel': {'ar': 'حالة القمر', 'en': 'Moon Phase', 'id': 'Fase Bulan', 'ur': 'چاند کی حالت'},
    'dashCountdownMinutesLabel': {'ar': 'دقيقة', 'en': 'minutes', 'id': 'menit', 'ur': 'منٹ'},
    'dashMoonIlluminationLabel': {'ar': 'نسبة الإضاءة التقريبية', 'en': 'Approximate illumination', 'id': 'Perkiraan penerangan', 'ur': 'تخمینی روشنی کا تناسب'},
    'dashMoonPhaseDisclaimer': {'ar': 'حساب تقريبي بالدورة القمرية — للتقويم الهجري الدقيق راجع مصادر الرؤية الشرعية', 'en': 'An approximate calculation based on the lunar cycle — for precise Hijri dates, consult official moon-sighting sources', 'id': 'Perhitungan perkiraan berdasarkan siklus bulan — untuk tanggal Hijriah yang akurat, rujuk sumber rukyat resmi', 'ur': 'قمری چکر پر مبنی تخمینی حساب — درست ہجری تاریخ کے لیے سرکاری رویت ہلال ذرائع دیکھیں'},

    'dashNavQibla': {'ar': 'القبلة', 'en': 'Qibla', 'id': 'Kiblat', 'ur': 'قبلہ'},
    'dashNavCalendar': {'ar': 'التقويم', 'en': 'Calendar', 'id': 'Kalender', 'ur': 'کیلنڈر'},
    'dashTimeRemainingPrefix': {'ar': 'الوقت المتبقي لأذان', 'en': 'Time remaining until', 'id': 'Waktu tersisa hingga', 'ur': 'باقی وقت تک'},
    'dashOnlinePrayerTimesBadge': {'ar': 'مواقيت أونلاين', 'en': 'Online timings', 'id': 'Waktu online', 'ur': 'آن لائن اوقات'},

    // ============== الميزات الاختيارية عبر الإنترنت (الإعدادات) ==============
    'onlineFeaturesSectionTitle': {'ar': 'ميزات اختيارية عبر الإنترنت', 'en': 'Optional online features', 'id': 'Fitur online opsional', 'ur': 'اختیاری آن لائن خصوصیات'},
    'onlineFeaturesSectionSubtitle': {
      'ar': 'التطبيق يعمل ١٠٠٪ بدون إنترنت دائماً. هذي ميزات إضافية اختيارية فقط، مجانية بالكامل وبدون إعلانات — لو ما فعّلتها أو انقطع الإنترنت، يستمر التطبيق بالحساب المحلي كالمعتاد.',
      'en': 'The app always works 100% offline. These are purely optional extras, completely free with no ads — if you don\'t enable them, or the internet drops, the app keeps using its local calculations as usual.',
      'id': 'Aplikasi selalu bekerja 100% offline. Ini hanya fitur tambahan opsional, sepenuhnya gratis tanpa iklan — jika Anda tidak mengaktifkannya, atau internet terputus, aplikasi tetap menggunakan perhitungan lokal seperti biasa.',
      'ur': 'ایپ ہمیشہ 100% بغیر انٹرنیٹ کام کرتی ہے۔ یہ صرف اختیاری اضافی خصوصیات ہیں، مکمل طور پر مفت اور بغیر اشتہارات کے — اگر آپ انہیں فعال نہ کریں، یا انٹرنیٹ منقطع ہو جائے، تو ایپ معمول کے مطابق مقامی حساب استعمال کرتی رہے گی۔',
    },
    'onlinePrayerTimesToggleLabel': {'ar': 'مواقيت صلاة أدق عبر الإنترنت', 'en': 'More precise prayer times online', 'id': 'Waktu salat lebih akurat via internet', 'ur': 'انٹرنیٹ کے ذریعے زیادہ درست نماز کے اوقات'},
    'onlinePrayerTimesToggleSubtitle': {
      'ar': 'يجلب مواقيت الصلاة من خدمة مجانية عبر موقعك (يحتاج صلاحية الموقع)، مع بقاء الحساب الفلكي المحلي كخيار احتياطي دائم.',
      'en': 'Fetches prayer times from a free service using your location (requires location permission), with the local astronomical calculation always kept as a fallback.',
      'id': 'Mengambil waktu salat dari layanan gratis berdasarkan lokasi Anda (memerlukan izin lokasi), dengan perhitungan astronomi lokal selalu tersedia sebagai cadangan.',
      'ur': 'آپ کے مقام کے ذریعے ایک مفت سروس سے نماز کے اوقات لاتا ہے (مقام کی اجازت درکار ہے)، جبکہ مقامی فلکیاتی حساب ہمیشہ متبادل کے طور پر برقرار رہتا ہے۔',
    },
    'onlineLocationServiceDisabled': {'ar': 'خدمة الموقع غير مفعّلة على جهازك، فعّلها من الإعدادات أولاً.', 'en': 'Location services are off on your device — enable them in Settings first.', 'id': 'Layanan lokasi nonaktif di perangkat Anda — aktifkan dulu di Pengaturan.', 'ur': 'آپ کے آلے پر مقام کی خدمات بند ہیں — پہلے سیٹنگز میں انہیں فعال کریں۔'},
    'onlineLocationPermissionDenied': {'ar': 'تم رفض صلاحية الموقع — لا يمكن تفعيل هذي الميزة بدونها.', 'en': 'Location permission was denied — this feature can\'t be enabled without it.', 'id': 'Izin lokasi ditolak — fitur ini tidak dapat diaktifkan tanpanya.', 'ur': 'مقام کی اجازت مسترد کر دی گئی — اس کے بغیر یہ خصوصیت فعال نہیں ہو سکتی۔'},
    'onlineLocationGenericError': {'ar': 'تعذّر تحديد موقعك، حاول مرة أخرى.', 'en': 'Couldn\'t determine your location, please try again.', 'id': 'Tidak dapat menentukan lokasi Anda, silakan coba lagi.', 'ur': 'آپ کا مقام معلوم نہیں ہو سکا، دوبارہ کوشش کریں۔'},

    // ============== النسخ الاحتياطي (الإعدادات) ==============
    'backupSectionTitle': {'ar': 'نسخ احتياطي', 'en': 'Backup', 'id': 'Cadangan', 'ur': 'بیک اپ'},
    'backupSectionSubtitle': {
      'ar': 'صدّر بياناتك (المفضلة، الإحصائيات، العادات، الإعدادات) كملف واحد وانقله لجهاز آخر بنفسك — بدون أي حساب أو خادم سحابي.',
      'en': 'Export your data (favorites, stats, habits, settings) as one file and move it to another device yourself — no account or cloud server involved.',
      'id': 'Ekspor data Anda (favorit, statistik, kebiasaan, pengaturan) sebagai satu file dan pindahkan sendiri ke perangkat lain — tanpa akun atau server cloud.',
      'ur': 'اپنا ڈیٹا (پسندیدہ، اعداد و شمار، عادات، سیٹنگز) ایک فائل کے طور پر ایکسپورٹ کریں اور خود دوسرے آلے میں منتقل کریں — بغیر کسی اکاؤنٹ یا کلاؤڈ سرور کے۔',
    },
    'backupExportButton': {'ar': 'تصدير نسخة احتياطية', 'en': 'Export backup', 'id': 'Ekspor cadangan', 'ur': 'بیک اپ ایکسپورٹ کریں'},
    'backupImportButton': {'ar': 'استيراد نسخة احتياطية', 'en': 'Import backup', 'id': 'Impor cadangan', 'ur': 'بیک اپ درآمد کریں'},
    'backupExportError': {'ar': 'تعذّر تصدير النسخة الاحتياطية، حاول مرة أخرى.', 'en': 'Couldn\'t export the backup, please try again.', 'id': 'Tidak dapat mengekspor cadangan, silakan coba lagi.', 'ur': 'بیک اپ ایکسپورٹ نہیں ہو سکا، دوبارہ کوشش کریں۔'},
    'backupImportSuccess': {'ar': 'تمت الاستعادة بنجاح ✅ أعد تشغيل التطبيق لتظهر البيانات.', 'en': 'Restored successfully ✅ Restart the app for the data to appear.', 'id': 'Berhasil dipulihkan ✅ Mulai ulang aplikasi agar data muncul.', 'ur': 'کامیابی سے بحال ہو گیا ✅ ڈیٹا ظاہر ہونے کے لیے ایپ دوبارہ شروع کریں۔'},
    'backupImportError': {'ar': 'تعذّر استيراد الملف — تأكد إنه نسخة احتياطية صحيحة من هذا التطبيق.', 'en': 'Couldn\'t import the file — make sure it\'s a valid backup from this app.', 'id': 'Tidak dapat mengimpor file — pastikan itu cadangan valid dari aplikasi ini.', 'ur': 'فائل درآمد نہیں ہو سکی — یقینی بنائیں کہ یہ اس ایپ کا درست بیک اپ ہے۔'},

    // ============== شاشة البحث ==============
    'searchTitle': {'ar': 'البحث بالأذكار', 'en': 'Search Adhkar', 'id': 'Cari Dzikir', 'ur': 'اذکار تلاش کریں'},
    'searchHint': {'ar': 'ابحث بعنوان الذكر أو نصه...', 'en': 'Search by title or text...', 'id': 'Cari berdasarkan judul atau teks...', 'ur': 'عنوان یا متن سے تلاش کریں...'},
    'searchEmptyPrompt': {'ar': 'اكتب كلمة للبحث بين كل الأذكار', 'en': 'Type a word to search across all adhkar', 'id': 'Ketik kata untuk mencari di semua dzikir', 'ur': 'تمام اذکار میں تلاش کے لیے ایک لفظ لکھیں'},
    'searchNoResults': {'ar': 'لا توجد نتائج', 'en': 'No results found', 'id': 'Tidak ada hasil', 'ur': 'کوئی نتیجہ نہیں ملا'},

    // ============== بطاقة الذكر ==============
    'dhikrCopiedMsg': {'ar': 'تم نسخ الذكر', 'en': 'Dhikr copied', 'id': 'Dzikir disalin', 'ur': 'ذکر کاپی ہو گیا'},
  };

  static String of(BuildContext context, String key) {
    final lang = context.watch<LanguageProvider>().language.code;
    return _dict[key]?[lang] ?? _dict[key]?['ar'] ?? key;
  }
}

/// اختصار مريح: `context.tr('settings_title')` بدل `AppStrings.of(context, 'settings_title')`.
extension AppStringsContext on BuildContext {
  String tr(String key) => AppStrings.of(this, key);
}
