# ميزة العقارات المميزة (Featured Properties)

## نظرة عامة
تم تطوير ميزة العقارات المميزة لعرض العقارات التي تم تمييزها من قبل الإدارة كـ "الأفضل" (the_best: 1) في التطبيق.

## الملفات المضافة

### 1. النماذج (Models)
- `lib/models/featured_property.dart` - نموذج العقار المميز مع دعم الترقيم

### 2. الخدمات (Services)
- `lib/services/featured_properties_service.dart` - خدمة API لجلب العقارات المميزة

### 3. مزودي الحالة (Providers)
- `lib/providers/featured_properties_provider.dart` - إدارة حالة العقارات المميزة

### 4. الواجهات (Widgets)
- `lib/widgets/featured_property_card.dart` - كارد عرض العقار المميز
- `lib/widgets/featured_properties_row.dart` - قائمة أفقية للعقارات المميزة

### 5. الصفحات (Screens)
- `lib/screens/user/featured_properties_screen.dart` - صفحة عرض جميع العقارات المميزة

## API المستخدم

### نقطة النهاية
```
GET /api/public-properties?the_best=1&page={page_number}
```

### هيكل الاستجابة
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "address": "123 شارع النيل، الجيزة",
      "type": "شقة",
      "price": "2500000.00",
      "description": "شقة رائعة تطل على النيل مباشرة...",
      "image_url": "http://...",
      "bedrooms": 3,
      "bathrooms": 2,
      "area": "180 متر مربع",
      "the_best": true,
      "created_at": "...",
      "provider": {
        "id": 10,
        "name": "شركة النيل العقارية",
        "phone": "010xxxxxxxx"
      }
    }
  ],
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": "https://.../api/public-properties?the_best=1&page=2"
  },
  "meta": {
    "current_page": 1,
    "total": 50
  }
}
```

## الميزات المطبقة

### 1. عرض العقارات في الصفحة الرئيسية
- قائمة أفقية تعرض أول 6 عقارات مميزة
- تصميم متجاوب مع حالات التحميل والأخطاء
- زر "عرض الكل" للانتقال إلى الصفحة المخصصة

### 2. صفحة العقارات المميزة المخصصة
- عرض شبكي لجميع العقارات المميزة
- تحميل تدريجي (Pagination) عند التمرير
- إمكانية التحديث بالسحب (Pull to Refresh)
- معالجة حالات الخطأ والتحميل

### 3. كارد العقار المميز
- عرض صورة العقار مع معالجة الأخطاء
- شارة "الأفضل" للعقارات المميزة
- عرض تفاصيل العقار (النوع، السعر، العنوان، الغرف)
- تنسيق السعر (تحويل إلى ألف/مليون)
- زر المفضلة

## التحديثات على الملفات الموجودة

### 1. `lib/main.dart`
- إضافة `FeaturedPropertiesProvider` إلى قائمة الـ providers

### 2. `lib/screens/user/user_home_screen.dart`
- استبدال قسم "عقارات موصى بها" بـ `FeaturedPropertiesRow`
- إضافة زر "عرض الكل" للانتقال إلى الصفحة المخصصة

### 3. `lib/router/app_router.dart`
- إضافة مسار `/featured-properties` للصفحة المخصصة

## كيفية الاستخدام

### 1. في الصفحة الرئيسية
العقارات المميزة تظهر تلقائياً في قسم "عقارات موصى بها"

### 2. الوصول إلى الصفحة المخصصة
```dart
context.push('/featured-properties');
```

### 3. استخدام الـ Provider
```dart
// جلب العقارات المميزة
context.read<FeaturedPropertiesProvider>().fetchFeaturedProperties();

// تحميل المزيد
context.read<FeaturedPropertiesProvider>().loadMoreFeaturedProperties();

// تحديث القائمة
context.read<FeaturedPropertiesProvider>().refreshFeaturedProperties();
```

## ملاحظات تقنية

### 1. إدارة الحالة
- استخدام `ChangeNotifier` لإدارة حالة العقارات
- دعم التحميل التدريجي والتحديث
- معالجة شاملة للأخطاء

### 2. الأداء
- تحميل أول 6 عقارات فقط في الصفحة الرئيسية
- تحميل تدريجي في الصفحة المخصصة
- تخزين مؤقت للبيانات المحملة

### 3. تجربة المستخدم
- حالات تحميل واضحة
- رسائل خطأ مفيدة
- إمكانية إعادة المحاولة
- تصميم متجاوب

## المتطلبات
- Flutter SDK
- Provider package
- go_router package
- http package (للـ API calls)

## الاختبار
تأكد من:
1. عمل API endpoint بشكل صحيح
2. عرض العقارات في الصفحة الرئيسية
3. عمل التنقل إلى الصفحة المخصصة
4. التحميل التدريجي والتحديث
5. معالجة حالات الخطأ