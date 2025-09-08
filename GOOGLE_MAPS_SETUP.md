# إعداد Google Maps للتطبيق

## الخطوات المطلوبة لتفعيل خدمة الخرائط:

### 1. الحصول على Google Maps API Key

1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد أو اختر مشروع موجود
3. فعّل Google Maps SDK for Android و Google Maps SDK for iOS
4. أنشئ API Key جديد
5. قم بتقييد الـ API Key للأمان:
   - للأندرويد: أضف SHA-1 fingerprint للتطبيق
   - لـ iOS: أضف Bundle ID للتطبيق

### 2. إضافة API Key للمشروع

#### للأندرويد:
استبدل `YOUR_GOOGLE_MAPS_API_KEY` في الملف:
```
android/app/src/main/AndroidManifest.xml
```

#### لـ iOS:
أضف السطر التالي في ملف `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. الحصول على SHA-1 Fingerprint (للأندرويد)

قم بتشغيل الأمر التالي في terminal:
```bash
cd android
./gradlew signingReport
```

### 4. اختبار التطبيق

بعد إضافة API Key، قم بتشغيل التطبيق واختبر وظيفة اختيار الموقع من الخريطة.

## ملاحظات مهمة:

- تأكد من تفعيل خدمات الموقع على الجهاز
- قد تحتاج إلى إعادة تشغيل التطبيق بعد إضافة API Key
- في حالة ظهور خريطة رمادية، تأكد من صحة API Key والإعدادات
- لا تنس إضافة API Key إلى ملف `.env` وعدم رفعه إلى Git للأمان

## استكشاف الأخطاء:

### خريطة رمادية:
- تحقق من صحة API Key
- تأكد من تفعيل Google Maps SDK
- تحقق من إعدادات التقييد في Google Cloud Console

### عدم ظهور الموقع الحالي:
- تأكد من منح إذن الموقع للتطبيق
- تحقق من تفعيل خدمات الموقع على الجهاز
- في المحاكي، قد تحتاج إلى تعيين موقع وهمي