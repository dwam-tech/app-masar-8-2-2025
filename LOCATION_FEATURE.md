# ميزة الحصول على الموقع الحالي

## الوصف
تم إضافة ميزة جديدة لحقل "عنوان المكتب" في شاشة تسجيل مكتب العقارات تسمح للمستخدم بالحصول على موقعه الحالي تلقائياً من Google Maps.

## الميزات المضافة

### 1. Packages المضافة
- `geolocator: ^10.1.0` - للحصول على الإحداثيات الحالية
- `geocoding: ^3.0.0` - لتحويل الإحداثيات إلى عنوان نصي

### 2. الصلاحيات المضافة

#### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول للموقع لتحديد عنوان المكتب تلقائياً</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول للموقع لتحديد عنوان المكتب تلقائياً</string>
```

### 3. الوظائف المضافة

#### `_handleLocationPermission()`
- التحقق من تفعيل خدمة الموقع
- طلب صلاحيات الوصول للموقع
- معالجة حالات الرفض المختلفة

#### `_getCurrentLocation()`
- الحصول على الإحداثيات الحالية بدقة عالية
- تحويل الإحداثيات إلى عنوان نصي باللغة العربية
- تحديث حقل العنوان تلقائياً
- عرض رسائل نجاح/فشل للمستخدم

### 4. تحسينات واجهة المستخدم
- إضافة زر موقع بجانب حقل العنوان
- عرض مؤشر تحميل أثناء الحصول على الموقع
- نص توضيحي للمستخدم
- تعطيل الزر أثناء التحميل

## كيفية الاستخدام
1. في شاشة تسجيل مكتب العقارات
2. اضغط على أيقونة الموقع 📍 بجانب حقل "عنوان المكتب"
3. اسمح للتطبيق بالوصول للموقع عند الطلب
4. سيتم ملء الحقل تلقائياً بالعنوان الحالي

## معالجة الأخطاء
- التحقق من تفعيل خدمة الموقع
- معالجة رفض الصلاحيات
- معالجة انتهاء مهلة الاتصال (15 ثانية)
- عرض الإحداثيات في حالة عدم توفر عنوان نصي

## الملفات المعدلة
- `lib/screens/business/RealStateScreens/SubscriptionRegistrationOfficeScreen.dart`
- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`