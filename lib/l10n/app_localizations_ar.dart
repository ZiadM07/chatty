// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get theme => 'السمة';

  @override
  String get dark => 'داكن';

  @override
  String get light => 'فاتح';

  @override
  String get defaultSystem => 'النظام';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get error => 'خطأ';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get done => 'تم';

  @override
  String get clear => 'مسح';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get required => 'مطلوب';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get textIsRequired => 'هذا الحقل مطلوب';

  @override
  String get textIsTooShort => 'قصير للغاية';

  @override
  String get notValidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get invalidPhoneNumber => 'رقم هاتف غير صالح';

  @override
  String get invalidEgyptianPhoneNumber => 'رقم مصري غير صالح. الصيغة: 01XXXXXXXXX';

  @override
  String get newPhoneNumberError => 'لا يمكنك استخدام رقم هاتفك القديم';

  @override
  String get validNumber => 'يرجى إدخال رقم صالح';

  @override
  String get atLeast18 => 'العمر يجب أن يكون 18 أو أكثر';

  @override
  String get accessKeyCannotBeEmpty => 'لا يمكن أن يكون مفتاح الوصول فارغًا';

  @override
  String get welcome => 'مرحباً';

  @override
  String get enterAccessKeyToContinue => 'أدخل مفتاح الوصول للمتابعة';

  @override
  String get accessKey => 'مفتاح الوصول';

  @override
  String get enterAccessKey => 'أدخل مفتاح الوصول';

  @override
  String get authenticate => 'تسجيل الدخول';

  @override
  String get authenticationSuccessful => 'تم تسجيل الدخول بنجاح';

  @override
  String get invalidAccessKey => 'مفتاح وصول غير صالح';

  @override
  String failedToAuthenticate(String error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get chats => 'الدردشات';

  @override
  String get calls => 'المكالمات';

  @override
  String get contacts => 'جهات الاتصال';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get stories => 'القصص';

  @override
  String get users => 'المستخدمون';

  @override
  String get newUser => 'مستخدم جديد';

  @override
  String get myUsers => 'المستخدمين';

  @override
  String get conversations => 'المحادثات';

  @override
  String get addStory => 'إضافة قصة';

  @override
  String get viewStory => 'عرض القصة';

  @override
  String get storyViews => 'مشاهدات القصة';

  @override
  String get storyExpired => 'انتهت صلاحية هذه القصة';

  @override
  String get noStoriesYet => 'لا توجد قصص بعد';

  @override
  String get deleteStory => 'حذف القصة';

  @override
  String get deleteStoryConfirm => 'هل أنت متأكد أنك تريد حذف هذه القصة؟';

  @override
  String get newChat => 'دردشة جديدة';

  @override
  String get searchChats => 'بحث في الدردشات...';

  @override
  String get noChatsFound => 'لا توجد دردشات';

  @override
  String get pinned => 'مثبّت';

  @override
  String get unreadMessages => 'رسائل غير مقروءة';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get send => 'إرسال';

  @override
  String get record => 'تسجيل';

  @override
  String get uploadMedia => 'رفع وسائط';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get document => 'ملف';

  @override
  String get audio => 'صوت';

  @override
  String get video => 'فيديو';

  @override
  String get location => 'الموقع';

  @override
  String get contactCard => 'مشاركة جهة اتصال';

  @override
  String get sendMessageFailed => 'فشل إرسال الرسالة';

  @override
  String get messageCopied => 'تم نسخ الرسالة';

  @override
  String get editMessage => 'تعديل الرسالة';

  @override
  String get deleteForEveryone => 'حذف للجميع';

  @override
  String get deleteForMe => 'حذف لي فقط';

  @override
  String get edited => 'معدّلة';

  @override
  String get sending => 'جارٍ الإرسال...';

  @override
  String get sent => 'تم الإرسال';

  @override
  String get delivered => 'تم التسليم';

  @override
  String get seen => 'تمت القراءة';

  @override
  String get failed => 'فشل الإرسال';

  @override
  String get voiceCall => 'مكالمة صوتية';

  @override
  String get videoCall => 'مكالمة فيديو';

  @override
  String get missedCall => 'مكالمة فائتة';

  @override
  String get callEnded => 'انتهت المكالمة';

  @override
  String get calling => 'جارٍ الاتصال...';

  @override
  String get incomingCall => 'مكالمة واردة';

  @override
  String get addContact => 'إضافة جهة اتصال';

  @override
  String get addNewContact => 'إضافة جهة اتصال جديدة';

  @override
  String get addGroup => 'إنشاء مجموعة';

  @override
  String get archived => 'الأرشيف';

  @override
  String get contactsList => 'قائمة جهات الاتصال';

  @override
  String get noContactsFound => 'لا توجد جهات اتصال';

  @override
  String get searchContacts => 'بحث في جهات الاتصال...';

  @override
  String get searchUsers => 'البحث عن المستخدمين...';

  @override
  String get searchViewers => 'البحث عن المشاهدين...';

  @override
  String get tapToAddPhoto => 'انقر لإضافة صورة';

  @override
  String get reply => 'رد';

  @override
  String get replyToYourStory => 'رد على قصتك';

  @override
  String get messageDeleted => 'تم حذف الرسالة';

  @override
  String get less => 'أقل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف (اختياري)';

  @override
  String get address => 'العنوان';

  @override
  String get enterAddressOptional => 'أدخل العنوان (اختياري)';

  @override
  String get call => 'اتصال';

  @override
  String get chatWhatsApp => 'الدردشة عبر واتساب';

  @override
  String get couldNotMakeCall => 'تعذّر إجراء المكالمة';

  @override
  String get couldNotOpenWhatsApp => 'تعذّر فتح واتساب';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get enterGroupName => 'أدخل اسم المجموعة';

  @override
  String get groupCreated => 'تم إنشاء المجموعة';

  @override
  String get addParticipants => 'إضافة أعضاء';

  @override
  String get removeFromGroup => 'إزالة من المجموعة';

  @override
  String get groupInfo => 'معلومات المجموعة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get bio => 'نبذة';

  @override
  String get enterBio => 'أدخل النبذة';

  @override
  String get lastSeen => 'آخر ظهور';

  @override
  String get online => 'متصل الآن';

  @override
  String get typing => 'يكتب...';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get security => 'الأمان';

  @override
  String get chatSettings => 'إعدادات الدردشة';

  @override
  String get privacySettings => 'إعدادات الخصوصية';

  @override
  String get customizeYourExperience => 'خصص تجربتك';

  @override
  String get blockedContacts => 'جهات الاتصال المحظورة';

  @override
  String get unblock => 'إلغاء الحظر';

  @override
  String get blockConfirm => 'هل أنت متأكد أنك تريد حظر هذا المستخدم؟';

  @override
  String get blockedSuccessfully => 'تم الحظر بنجاح';

  @override
  String get unblockedSuccessfully => 'تم إلغاء الحظر';

  @override
  String get readReceipts => 'إيصالات القراءة';

  @override
  String get typingIndicators => 'مؤشر الكتابة';

  @override
  String get showLastSeen => 'إظهار آخر ظهور';

  @override
  String get download => 'تنزيل';

  @override
  String get downloading => 'جارٍ التنزيل...';

  @override
  String get fileNotSupported => 'هذا النوع من الملفات غير مدعوم';

  @override
  String get openFile => 'فتح الملف';

  @override
  String get viewImage => 'عرض الصورة';

  @override
  String get viewVideo => 'عرض الفيديو';

  @override
  String get mute => 'كتم';

  @override
  String get unmute => 'إلغاء الكتم';

  @override
  String get pinChat => 'تثبيت الدردشة';

  @override
  String get unpinChat => 'إلغاء تثبيت الدردشة';

  @override
  String get markAsUnread => 'تحديد كغير مقروء';

  @override
  String get markAsRead => 'تحديد كمقروء';

  @override
  String get report => 'إبلاغ';

  @override
  String get searchInChat => 'بحث داخل الدردشة';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get forward => 'إعادة توجيه';

  @override
  String get forwarded => 'تمت إعادة التوجيه';

  @override
  String get selectMessages => 'تحديد الرسائل';

  @override
  String get you => 'أنت';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutDescription => 'تسجيل الخروج من حسابك';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get loggedOutSuccessfully => 'تم تسجيل الخروج بنجاح';

  @override
  String failedToLogout(String error) {
    return 'فشل تسجيل الخروج: $error';
  }

  @override
  String get updateRequired => 'يتطلب تحديث';

  @override
  String get updateRequiredMessage => 'يتوفر إصدار جديد من التطبيق. يرجى التحديث للمتابعة.';

  @override
  String get latestVersion => 'أحدث إصدار';

  @override
  String get updateNow => 'حدّث الآن';

  @override
  String get couldNotOpenUpdateUrl => 'تعذّر فتح رابط التحديث';

  @override
  String get version => 'إصدار التطبيق';

  @override
  String get madeWith => 'صُنع بواسطة مؤمن وزياد محمد';

  @override
  String get pleaseEnterName => 'الرجاء إدخال الاسم';

  @override
  String get welcomeHeadline => 'نجمع الأصدقاء معًا';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get password => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loggingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get byLoggingInYouAgree => 'بتسجيل الدخول، فإنك توافق على';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get and => 'و';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get name => 'الاسم';

  @override
  String get enterYourPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get signUpButton => 'إنشاء حساب';

  @override
  String get signingUp => 'جارٍ إنشاء الحساب...';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get fillProfile => 'املأ ملفك الشخصي';

  @override
  String get completeProfileMessage => 'أكمل ملفك الشخصي للبدء';

  @override
  String get continueButton => 'تابع';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String get enterYourBio => 'أخبرنا عن نفسك';

  @override
  String get searchConversations => 'بحث في الدردشات..';

  @override
  String get messages => 'الرسائل';

  @override
  String totalUsers(Object count) {
    return 'إجمالي المستخدمين ($count)';
  }

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get newContact => 'جهة اتصال جديدة';

  @override
  String get archive => 'الأرشيف';

  @override
  String get myContacts => 'جهات الاتصال الخاصة بي';

  @override
  String get notification => 'الإشعارات';

  @override
  String get privacySubtitle => 'تحكم في إعدادات الخصوصية الخاصة بك';

  @override
  String get chatsSubtitle => 'الخلفية، سجل الدردشة';

  @override
  String get languageSubtitle => 'اختر لغتك';

  @override
  String get notificationSubtitle => 'الرسائل والمكالمات والتنبيهات';

  @override
  String get appearance => 'المظهر';

  @override
  String get systemDefault => 'النظام الافتراضي';

  @override
  String get chatWallpaper => 'خلفيات الدردشة';

  @override
  String get defaultText => 'النص الافتراضي';

  @override
  String get chatBackup => 'النسخ الاحتياطي للدردشة';

  @override
  String get googleDrive => 'جوجل درايف';

  @override
  String get storageAndBackup => 'التخزين والنسخ الاحتياطي';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get enterIsSend => 'الإدخال هو الإرسال';

  @override
  String get pressEnterToSend => 'اضغط على Enter للإرسال';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get clearAllChats => 'مسح جميع الدردشات';

  @override
  String get deleteAllConversationHistory => 'حذف سجل المحادثات بالكامل';

  @override
  String get deleteAllConversationHistoryConfirm => 'هل أنت متأكد أنك تريد حذف جميع المحادثات؟';

  @override
  String get themeSettings => 'إعدادات المظهر';

  @override
  String get chooseYourPreferredTheme => 'اختر المظهر الذي يناسبك';

  @override
  String get brightAndClean => 'مظهر فاتح وواضح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get easierOnEyes => 'أريح للعين في الإضاءة المنخفضة';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get matchDeviceSettings => 'مطابقة إعدادات الجهاز';

  @override
  String get preview => 'معاينة';

  @override
  String get colorsAndContrast => 'معاينة الألوان والتباين';

  @override
  String get themeChangesApplyImmediately => 'تُطبّق تغييرات المظهر مباشرة وتحفظ تلقائيًا';

  @override
  String get sampleMessage => 'رسالة تجريبية';

  @override
  String get thisIsHowYourAppWillLook => 'هكذا سيبدو تطبيقك';

  @override
  String get about => 'حول التطبيق';

  @override
  String get aboutApp => 'aboutApp';

  @override
  String get pleaseSelectAtLeastOneContact => 'الرجاء تحديد جهة اتصال واحدة على الأقل';

  @override
  String get groupCreatedSuccessfully => 'تم إنشاء المجموعة بنجاح';

  @override
  String get pleaseEnterGroupName => 'الرجاء إدخال اسم المجموعة';

  @override
  String get createNewGroup => 'إنشاء مجموعة جديدة';

  @override
  String get addMembersToYourGroup => 'إضافة أعضاء إلى مجموعتك';

  @override
  String get selected => 'مُحدد';

  @override
  String get noContactsAvailable => 'لا توجد جهات اتصال متاحة';

  @override
  String get noGroupsAvailable => 'لا توجد مجموعات متاحة';

  @override
  String get noMessagesAvailable => 'لا توجد رسائل متاحة';

  @override
  String get noCallsAvailable => 'لا توجد مكالمات متاحة';

  @override
  String get noStoriesAvailable => 'لا توجد قصص متاحة';

  @override
  String get noNotificationsAvailable => 'لا توجد إشعارات متاحة';

  @override
  String get noSettingsAvailable => 'لا توجد إعدادات متاحة';

  @override
  String get noChatsAvailable => 'لا توجد دردشات متاحة';

  @override
  String get noConversationsAvailable => 'لا توجد محادثات متاحة';

  @override
  String get groups => 'مجموعات';

  @override
  String get selectYourLanguage => 'اختر لغتك';

  @override
  String get languageAppliesInstantly => 'يتم تطبيق اللغة على الفور - لا حاجة لإعادة التشغيل';

  @override
  String get unexpectedError => 'خطأ غير متوقع';

  @override
  String get work => 'عمل';

  @override
  String get study => 'دراسة';

  @override
  String get gaming => 'ألعاب';

  @override
  String get fitness => 'لياقة';

  @override
  String get creative => 'إبداعي';

  @override
  String get social => 'اجتماعي';

  @override
  String get step1Of2 => 'الخطوة 1 من 2 • تفاصيل المجموعة';

  @override
  String get requiredField => 'حقل مطلوب';

  @override
  String get groupNameExample => 'على سبيل المثال، اسم المجموعة،';

  @override
  String get groupDescriptionHint => 'عن ماذا تدور هذه المجموعة؟';

  @override
  String get category => 'الفئة';

  @override
  String get nextAddMembers => 'التالي: إضافة أعضاء';

  @override
  String get addMembers => 'إضافة أعضاء';

  @override
  String get step2Of2 => 'الخطوة 2 من 2 • حدد أعضاء المجموعة';

  @override
  String get searchByNameOrEmail => 'ابحث بالاسم أو البريد الإلكتروني...';

  @override
  String membersSelected(int count) {
    return 'تم تحديد $count عضو (أعضاء)';
  }

  @override
  String groupMembers(int count) {
    return 'أعضاء المجموعة ($count)';
  }

  @override
  String get back => 'رجوع';

  @override
  String get privateGroup => 'مجموعة خاصة';

  @override
  String get publicGroup => 'مجموعة عامة';

  @override
  String get onlyInvitedMembersCanJoin => 'يمكن للأعضاء المدعوين فقط الانضمام';

  @override
  String get anyoneCanDiscoverAndJoin => 'يمكن لأي شخص اكتشاف المجموعة والانضمام إليها';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get tryAdjustingYourSearch => 'حاول تعديل بحثك';

  @override
  String get description => 'الوصف';

  @override
  String get backToDetails => 'العودة إلى التفاصيل';

  @override
  String get create => 'إنشاء';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'أخرى';

  @override
  String get inviteFriends => 'دعوة الأصدقاء';

  @override
  String get blockedUsers => 'المستخدمون المحظورون';

  @override
  String get shareInviteDescription => 'مشاركة وصف الدعوة';

  @override
  String get linkCopied => 'تم نسخ رابط الدعوة';

  @override
  String get shareInvite => 'مشاركة الدعوة';

  @override
  String get inviteProfessionalDesc => 'ادعُ أصدقاءك ووسّع شبكتك';

  @override
  String get yourInviteCode => 'كود الدعوة الخاص بك';

  @override
  String get inviteLink => 'رابط الدعوة';

  @override
  String invitedCount(Object count) {
    return 'عدد الأصدقاء الذين تمت دعوتهم: $count';
  }

  @override
  String get inviteSubtitle => 'شارك التطبيق مع أصدقائك';

  @override
  String get inviteCode => 'كود الدعوة';

  @override
  String get shareVia => 'مشاركة عبر';

  @override
  String get more => 'المزيد';

  @override
  String get copy => 'نسخ';

  @override
  String get qrCode => 'رمز QR';

  @override
  String get inviteShareText => 'انضم إليّ على هذا التطبيق الرائع!';

  @override
  String get inviteSent => 'تم إرسال الدعوة بنجاح';

  @override
  String get storyFileTooLarge => 'حجم الملف يجب أن يكون أقل من 50 ميجابايت';

  @override
  String get storyPickFailed => 'فشل اختيار الوسائط';

  @override
  String get storyVideoLoadFailed => 'فشل تحميل الفيديو';

  @override
  String get storyUploadFailed => 'فشل رفع القصة';

  @override
  String get storyPosted => 'تم نشر القصة 🎉';

  @override
  String get storyReplyPrefix => '📷 تم الرد على قصتك:';

  @override
  String get storyReplySentTitle => 'تم إرسال الرد';

  @override
  String get storyReplySentBody => 'تم توصيل رسالتك بنجاح';

  @override
  String get storyReplySentOk => 'حسناً';

  @override
  String get storyLoading => 'جاري تحميل الصورة...';

  @override
  String get storyLikes => 'إعجاب';

  @override
  String get storyJustViewed => 'شاهد فقط';

  @override
  String get storyAll => 'الكل';

  @override
  String get storyLiked => 'أعجبوا';

  @override
  String get storyViewed => 'تمت المشاهدة';

  @override
  String get storyNoViewers => 'لا يوجد مشاهدون بعد';

  @override
  String get storyUploading => 'جارٍ رفع القصة';

  @override
  String storyUploadPercent(Object percent) {
    return '$percent% مكتمل';
  }

  @override
  String get storyTypeSomething => 'اكتب شيئاً...';

  @override
  String get storyBackground => 'خلفية';

  @override
  String get storyDone => 'تم';

  @override
  String get chatWallpaperTitle => 'خلفية الدردشة';

  @override
  String get chooseWallpaper => 'اختر الخلفية';

  @override
  String get wallpaperClassic => 'كلاسيك';

  @override
  String get wallpaperAbstractBlue => 'أزرق تجريدي';

  @override
  String get wallpaperGreenTexture => 'ملمس أخضر';

  @override
  String get wallpaperYourPhoto => 'صورتك';

  @override
  String get previewAndAdjust => 'معاينة وتعديل';

  @override
  String get previewWallpaper => 'معاينة الخلفية';

  @override
  String get brightness => 'السطوع';

  @override
  String get save => 'حفظ';

  @override
  String get sampleHello => 'مرحباً 👋';

  @override
  String get sampleLooksGreat => 'تبدو رائعة!';

  @override
  String get locked => 'مغلق';

  @override
  String get alertTypes => 'أنواع التنبيهات';

  @override
  String get messageNotifications => 'إشعارات الرسائل';

  @override
  String get messageNotificationsDesc => 'تلقي إشعار عند وصول رسالة جديدة';

  @override
  String get groupNotifications => 'إشعارات المجموعات';

  @override
  String get groupNotificationsDesc => 'ابقَ على اطلاع بنشاطات المجموعات';

  @override
  String get notificationPreferences => 'إعدادات الإشعارات';

  @override
  String get showPreview => 'عرض محتوى الرسالة';

  @override
  String get showPreviewDesc => 'إظهار نص الرسالة داخل الإشعار';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get userDetails => 'تفاصيل المستخدم';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get bioLabel => 'النبذة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get profilePhoto => 'الصورة الشخصية';

  @override
  String get profilePhotoAction => 'ماذا تريد أن تفعل؟';

  @override
  String get change => 'تغيير';

  @override
  String get nameDescription => 'هكذا سيظهر اسمك للمستخدمين الآخرين';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get nameEmptyError => 'لا يمكن أن يكون الاسم فارغًا';

  @override
  String get nameUpdatedSuccess => 'تم تحديث الاسم بنجاح';

  @override
  String get bioDescription => 'شارك نبذة عن نفسك في الملف الشخصي';

  @override
  String get yourBio => 'نبذتك';

  @override
  String get bioTip => 'نصيحة: اجعلها قصيرة ومميزة واذكر هواياتك!';

  @override
  String get noStories => 'لا توجد قصص';

  @override
  String get mediaComing => 'ميزة الوسائط قريبًا';

  @override
  String get createGroupComing => 'ميزة إنشاء المجموعة قريبًا';

  @override
  String groupsInCommon(int count) {
    return '$count مجموعات مشتركة';
  }

  @override
  String get message => 'مراسلة';

  @override
  String get muteNotifications => 'كتم الإشعارات';

  @override
  String get silenceAlerts => 'إسكات التنبيهات';

  @override
  String get mediaLinks => 'الوسائط والروابط';

  @override
  String get sharedFiles => 'الملفات المشتركة';

  @override
  String get joined => 'انضم في';

  @override
  String block(String username) {
    return 'حظر $username';
  }

  @override
  String get blockDesc => 'حظر هذا المستخدم';

  @override
  String get reportDesc => 'الإبلاغ عن هذا المستخدم';

  @override
  String get blockUser => 'حظر المستخدم';

  @override
  String get blockUserConfirm => 'هل أنت متأكد أنك تريد حظر هذا المستخدم؟';

  @override
  String get reportUser => 'الإبلاغ عن المستخدم';

  @override
  String get reportUserConfirm => 'هل أنت متأكد أنك تريد الإبلاغ عن هذا المستخدم؟';

  @override
  String get reportReason => 'سبب الإبلاغ';

  @override
  String get reportReasonHint => 'أخبرنا لماذا تقوم بالإبلاغ عن هذا المستخدم';

  @override
  String showMore(int count) {
    return 'عرض المزيد ($count)';
  }

  @override
  String get showLess => 'عرض أقل';

  @override
  String createGroupWith(String username) {
    return 'إنشاء مجموعة مع $username';
  }

  @override
  String get startNewCommunity => 'ابدأ مجتمعًا جديدًا';

  @override
  String get bioUpdatedSuccess => 'Bio updated successfully';

  @override
  String get profileTapToAddBio => 'اضغط لإضافة نبذة';

  @override
  String get profileViewProfile => 'عرض الملف الشخصي';

  @override
  String get profileEditProfile => 'تعديل الملف الشخصي';

  @override
  String get yourStory => 'قصتك';

  @override
  String get createStory => 'إنشاء قصة';

  @override
  String get optional => 'اختياري';

  @override
  String get recording => 'جارٍ التسجيل…';

  @override
  String get stop => 'إيقاف';

  @override
  String get image => 'صورة';

  @override
  String get loadingImage => 'جارٍ تحميل الصورة…';

  @override
  String get members => 'أعضاء';

  @override
  String get member => 'عضو';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get groupNotFound => 'المجموعة غير موجودة';

  @override
  String get noStory => 'لا توجد قصة';

  @override
  String get err => 'خطأ';

  @override
  String get recordingLabel => 'جارٍ التسجيل…';

  @override
  String get failedToLoadImage => 'فشل تحميل الصورة';

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أعضاء',
      one: 'عضو',
    );
    return '$count $_temp0';
  }

  @override
  String get chatAlreadyExists => 'الدردشة موجودة بالفعل مع هذا المستخدم';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من الاتصال';

  @override
  String get authenticationError => 'خطأ في المصادقة. يرجى تسجيل الدخول مرة أخرى';

  @override
  String get failedToCreateChat => 'فشل إنشاء الدردشة. يرجى المحاولة مرة أخرى';

  @override
  String get groupNameRequired => 'اسم المجموعة مطلوب';

  @override
  String get selectAtLeastOneMember => 'اختر عضوًا واحدًا على الأقل';

  @override
  String failedToUploadImage(String error) {
    return 'فشل رفع الصورة: $error';
  }

  @override
  String get profileImage => 'صورة الملف الشخصي';

  @override
  String get groupPicture => 'صورة المجموعة';

  @override
  String get profilePicture => 'صورة الملف الشخصي';

  @override
  String get views => 'المشاهدات';

  @override
  String get likes => 'إعجاب';

  @override
  String get all => 'الكل';

  @override
  String get liked => 'أعجبوا';

  @override
  String get noViewersYet => 'لا يوجد مشاهدون بعد';

  @override
  String get justViewed => 'شاهد فقط';

  @override
  String get uploadingStory => 'جارٍ رفع القصة';

  @override
  String uploadPercent(int percent) {
    return '$percent% مكتمل';
  }

  @override
  String get typeSomething => 'اكتب شيئاً...';

  @override
  String get background => 'خلفية';

  @override
  String get noViewersFound => 'لم يتم العثور على مشاهدين';

  @override
  String get pdf => 'pdf';

  @override
  String get file => 'ملف';

  @override
  String get offline => 'غير متصل';

  @override
  String get notificationInfo => 'يتم تطبيق إعداداتك فورًا';

  @override
  String get groupPictureUpdated => 'تم تحديث صورة المجموعة';

  @override
  String get groupImageDesc => 'اجعل مجموعتك مميزة بصورة.';

  @override
  String get admin => 'مسؤل';

  @override
  String get media => 'الوسائط';

  @override
  String get searchMedia => 'ابحث في الوسائط...';

  @override
  String get mediaAll => 'الكل';

  @override
  String get mediaPhotos => 'الصور';

  @override
  String get mediaVideos => 'الفيديوهات';

  @override
  String get mediaAudio => 'الصوتيات';

  @override
  String get mediaDocs => 'المستندات';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get noMediaYet => 'لا توجد وسائط بعد';

  @override
  String get adjustSearchKeywords => 'حاول تعديل كلمات البحث';

  @override
  String get mediaEmptyDescription => 'الصور والفيديوهات والصوتيات والمستندات\nالتي يتم مشاركتها في هذه المحادثة ستظهر هنا';

  @override
  String searchLabel(Object query) {
    return 'بحث: \"$query\"';
  }

  @override
  String get createYourStory => 'أنشئ قصتك';

  @override
  String get shareMomentWithFriends => 'شارك لحظة مع أصدقائك';

  @override
  String get storyUploadHint => 'الحد الأقصى 50 ميجا • صور وفيديوهات';

  @override
  String get chooseMedia => 'اختيار وسائط';

  @override
  String get post => 'نشر';

  @override
  String uploadProgress(Object percent) {
    return 'اكتمل $percent%';
  }

  @override
  String get gender => 'الجنس';

  @override
  String get confirmYourPassword => 'تأكيد كلمة المرور';

  @override
  String get bySigningUpYouAgree => 'بالتسجيل، يوافقك على';

  @override
  String get profileSettings => 'إعدادات الملف الشخصي';

  @override
  String get loginSuccessful => 'تم تسجيل الدخول بنجاح';

  @override
  String get signupSuccessful => 'تم التسجيل بنجاح';

  @override
  String get profileCompletedSuccessfully => 'تم إكمال الملف الشخصي بنجاح';

  @override
  String get pleaseSelectProfileImage => 'الرجاء اختيار صورة الملف الشخصي';

  @override
  String get nameIsRequired => 'الاسم مطلوب';

  @override
  String get updatedSuccessfully => 'تم التحديث بنجاح';

  @override
  String get languageSettings => 'إعدادات اللغة';

  @override
  String get addCaption => 'إضافة التسمية';

  @override
  String get chatsSettings => 'إعدادات الدردشات';

  @override
  String get chatsWallpaperSubtitle => 'تغيير الخلفية للدردشات';

  @override
  String get mediaAndFiles => 'الوسائط والملفات';

  @override
  String get mediaEmptyTitle => 'لا توجد وسائط بعد';

  @override
  String get mediaErrorDescription => 'فشل تحميل الوسائط. يرجى المحاولة مرة أخرى.';

  @override
  String get mediaErrorTitle => 'خطأ في تحميل الوسائط';

  @override
  String get noSharedFiles => 'لا توجد ملفات مشتركة';

  @override
  String get photo => 'الصورة';

  @override
  String get attachment => 'الإرفاق';

  @override
  String get am => 'صباحا';

  @override
  String get pm => 'مساء';

  @override
  String get storagePermissionDenied => 'تم رفض إذن تخزين';

  @override
  String get downloadedSuccessfully => 'تم التحميل بنجاح';

  @override
  String get downloadFailed => 'فشل التحميل';

  @override
  String get now => 'الآن';

  @override
  String get minutesAgo => 'دقائق مضت';

  @override
  String get hoursAgo => 'ساعات مضت';

  @override
  String get daysAgo => 'أيام مضت';

  @override
  String get notificationsMuted => 'تم إغلاق الإشعارات';

  @override
  String get videoPlayer => 'مشغل الفيديو';

  @override
  String get videoPlayerComingSoon => 'مشغل الفيديو قريبا';

  @override
  String get permissionDenied => 'تم رفض إذن';

  @override
  String get createdAt => 'أنشئ في';

  @override
  String get group => 'مجموعة';

  @override
  String get editGroupName => 'تعديل اسم المجموعة';

  @override
  String get editGroupDescription => 'تعديل وصف المجموعة';

  @override
  String get addGroupDescription => 'إضافة وصف للمجموعة';

  @override
  String get editGroupPicture => 'تعديل صورة المجموعة';

  @override
  String get removeMember => 'إزالة عضو';

  @override
  String get removeMemberConfirm => 'هل أنت متأكد من رغبتك في إزالة هذا العضو؟';

  @override
  String get removeMemberSuccess => 'تم إزالة العضو بنجاح';

  @override
  String get removeMemberFailed => 'فشل إزالة العضو';

  @override
  String get owner => 'المالك';

  @override
  String get storyReplyNotifications => 'إشعارات الرد على القصص';

  @override
  String get storyReplyNotificationsDesc => 'Receive notifications when someone replies to your story';

  @override
  String get notificationSound => 'صوت الإشعارات';

  @override
  String get notificationSoundDesc => 'اختر الصوت للإشعارات';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get vibrationDesc => 'تمكين أو تعطيل الاهتزاز للإشعارات';

  @override
  String get messagePreview => 'معاينة الرسالة';

  @override
  String get messagePreviewDesc => 'عرض معاينة للرسالة';

  @override
  String get inAppSound => 'صوت داخل التطبيق';

  @override
  String get inAppSoundDesc => 'تشغيل صوت للرسائل الواردة';

  @override
  String get noStoryFound => 'لا توجد قصة';

  @override
  String get goBack => 'العودة';

  @override
  String get paused => 'متوقف';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف';

  @override
  String get like => 'إعجاب';

  @override
  String get unlike => 'إلغاء الإعجاب';

  @override
  String get viewed => 'تمت المشاهدة';

  @override
  String get viewers => 'المشاهدين';

  @override
  String get viewersSheetTitle => 'المشاهدين';

  @override
  String get viewersSheetDescription => 'المشاهدين لهذه القصة';

  @override
  String get tapToSeeWhoViewed => 'اضغط لعرض من قرأ هذه القصة';

  @override
  String get replyToStory => 'رد على القصة...';

  @override
  String get voiceMessage => 'رسالة صوتية';

  @override
  String get slideToCancel => 'اسحب للإلغاء';

  @override
  String get releaseToCancel => 'اترك للإلغاء';

  @override
  String get deleteMessage => 'حذف الرسالة';

  @override
  String get deleteMessageConfirm => 'هل أنت متأكد من رغبتك في حذف هذه الرسالة؟';

  @override
  String get deleteMessageSuccess => 'تم حذف الرسالة بنجاح';

  @override
  String get deleteMessageFailed => 'فشل حذف الرسالة';

  @override
  String get pinchToZoomTapToClose => 'اسحب للتكبير · اضغط للإغلاق';

  @override
  String get chatInfo => 'معلومات الدردشة';

  @override
  String get minute => 'دقيقة';

  @override
  String get hour => 'ساعة';

  @override
  String get day => 'يوم';

  @override
  String get ago => 'مضت';

  @override
  String get justNow => 'الآن';

  @override
  String get noViewsYet => 'لا توجد مشاهدات بعد';

  @override
  String addCount(Object count) {
    return 'إضافة ($count)';
  }

  @override
  String createCount(Object count) {
    return 'إنشاء ($count)';
  }

  @override
  String get leaveGroup => 'مغادرة المجموعة';

  @override
  String get leaveGroupConfirm => 'هل أنت متأكد من رغبتك في مغادرة هذه المجموعة؟';

  @override
  String get leaveGroupOwnerConfirm => 'أنت المالك. سيتم نقل الملكية إلى العضو التالي عند المغادرة.';

  @override
  String get leaveAndTransfer => 'مغادرة ونقل الملكية';

  @override
  String get createAGroupWithThisUser => 'أنشئ مجموعة مع هذا المستخدم';

  @override
  String get commonGroups => 'المجموعات المشتركة';

  @override
  String get emailOrPasswordIncorrect => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get thisOperationFailed => 'فشلت هذه العملية.';

  @override
  String get emailCannotBeChanged => 'لا يمكن تغيير البريد الإلكتروني';

  @override
  String get usernameCannotBeChanged => 'لا يمكن تغيير اسم المستخدم';

  @override
  String get couldNotLoadFile => 'تعذر تحميل الملف';

  @override
  String get brightnessDescription => 'اضبط مستوى الظلام لتحسين إمكانية قراءة النص';
}
