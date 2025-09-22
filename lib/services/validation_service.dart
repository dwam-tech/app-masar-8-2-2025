/// خدمة التحقق من صحة البيانات
class ValidationService {
  /// التحقق من صحة رقم الهاتف
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    // التحقق من الأرقام السعودية
    final phoneRegex = RegExp(r'^(\+966|966|0)?[5][0-9]{8}$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', '').replaceAll('-', ''));
  }

  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// التحقق من صحة كلمة المرور
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    // على الأقل 8 أحرف، حرف كبير، حرف صغير، رقم
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// التحقق من صحة الاسم
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    return name.trim().length >= 2;
  }

  /// التحقق من صحة العنوان
  static bool isValidAddress(String address) {
    if (address.isEmpty) return false;
    return address.trim().length >= 10;
  }

  /// التحقق من صحة السعر
  static bool isValidPrice(String price) {
    if (price.isEmpty) return false;
    final priceValue = double.tryParse(price);
    return priceValue != null && priceValue > 0;
  }

  /// التحقق من صحة الوزن
  static bool isValidWeight(String weight) {
    if (weight.isEmpty) return false;
    final weightValue = double.tryParse(weight);
    return weightValue != null && weightValue > 0 && weightValue <= 1000; // حد أقصى 1000 كيلو
  }

  /// التحقق من صحة المسافة
  static bool isValidDistance(String distance) {
    if (distance.isEmpty) return false;
    final distanceValue = double.tryParse(distance);
    return distanceValue != null && distanceValue > 0 && distanceValue <= 1000; // حد أقصى 1000 كم
  }

  /// التحقق من صحة الإحداثيات
  static bool isValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  /// التحقق من صحة رقم الهوية السعودية
  static bool isValidSaudiId(String id) {
    if (id.isEmpty || id.length != 10) return false;
    
    // التحقق من أن جميع الأحرف أرقام
    if (!RegExp(r'^[0-9]+$').hasMatch(id)) return false;
    
    // خوارزمية التحقق من صحة رقم الهوية السعودية
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(id[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }
      sum += digit;
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(id[9]);
  }

  /// التحقق من صحة رقم الإقامة
  static bool isValidIqamaNumber(String iqama) {
    if (iqama.isEmpty || iqama.length != 10) return false;
    
    // التحقق من أن جميع الأحرف أرقام
    if (!RegExp(r'^[0-9]+$').hasMatch(iqama)) return false;
    
    // رقم الإقامة يجب أن يبدأ بـ 2
    if (!iqama.startsWith('2')) return false;
    
    // نفس خوارزمية التحقق من رقم الهوية
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(iqama[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }
      sum += digit;
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(iqama[9]);
  }

  /// التحقق من صحة رقم لوحة السيارة السعودية
  static bool isValidSaudiPlateNumber(String plateNumber) {
    if (plateNumber.isEmpty) return false;
    
    // نمط لوحة السيارة السعودية: 3 أرقام + 3 أحرف عربية أو إنجليزية
    final plateRegex = RegExp(r'^[0-9]{1,4}[\u0600-\u06FFa-zA-Z]{1,3}$');
    return plateRegex.hasMatch(plateNumber.replaceAll(' ', '').replaceAll('-', ''));
  }

  /// التحقق من صحة IBAN السعودي
  static bool isValidSaudiIBAN(String iban) {
    if (iban.isEmpty) return false;
    
    // إزالة المسافات والشرطات
    iban = iban.replaceAll(' ', '').replaceAll('-', '').toUpperCase();
    
    // التحقق من طول IBAN السعودي (24 حرف)
    if (iban.length != 24) return false;
    
    // التحقق من أن IBAN يبدأ بـ SA
    if (!iban.startsWith('SA')) return false;
    
    // التحقق من أن باقي الأحرف أرقام
    final remainingPart = iban.substring(2);
    if (!RegExp(r'^[0-9]+$').hasMatch(remainingPart)) return false;
    
    return true;
  }

  /// التحقق من صحة رقم الحساب البنكي
  static bool isValidBankAccount(String accountNumber) {
    if (accountNumber.isEmpty) return false;
    
    // رقم الحساب البنكي يجب أن يكون بين 10-20 رقم
    if (accountNumber.length < 10 || accountNumber.length > 20) return false;
    
    // التحقق من أن جميع الأحرف أرقام
    return RegExp(r'^[0-9]+$').hasMatch(accountNumber);
  }

  /// رسائل الخطأ للتحقق من صحة البيانات
  static String getValidationError(String field, String value) {
    switch (field) {
      case 'phone':
        return !isValidPhoneNumber(value) ? 'رقم الهاتف غير صحيح' : '';
      case 'email':
        return !isValidEmail(value) ? 'البريد الإلكتروني غير صحيح' : '';
      case 'password':
        return !isValidPassword(value) ? 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل مع حرف كبير وصغير ورقم' : '';
      case 'name':
        return !isValidName(value) ? 'الاسم يجب أن يحتوي على حرفين على الأقل' : '';
      case 'address':
        return !isValidAddress(value) ? 'العنوان يجب أن يحتوي على 10 أحرف على الأقل' : '';
      case 'price':
        return !isValidPrice(value) ? 'السعر يجب أن يكون رقماً موجباً' : '';
      case 'weight':
        return !isValidWeight(value) ? 'الوزن يجب أن يكون بين 0 و 1000 كيلو' : '';
      case 'distance':
        return !isValidDistance(value) ? 'المسافة يجب أن تكون بين 0 و 1000 كيلومتر' : '';
      case 'saudi_id':
        return !isValidSaudiId(value) ? 'رقم الهوية السعودية غير صحيح' : '';
      case 'iqama':
        return !isValidIqamaNumber(value) ? 'رقم الإقامة غير صحيح' : '';
      case 'plate_number':
        return !isValidSaudiPlateNumber(value) ? 'رقم لوحة السيارة غير صحيح' : '';
      case 'iban':
        return !isValidSaudiIBAN(value) ? 'رقم IBAN غير صحيح' : '';
      case 'bank_account':
        return !isValidBankAccount(value) ? 'رقم الحساب البنكي غير صحيح' : '';
      default:
        return value.isEmpty ? 'هذا الحقل مطلوب' : '';
    }
  }

  /// التحقق من صحة نموذج طلب التوصيل
  static Map<String, String> validateDeliveryRequest({
    required String pickupAddress,
    required String deliveryAddress,
    required String senderPhone,
    required String receiverPhone,
    required String weight,
    required String description,
  }) {
    Map<String, String> errors = {};

    if (!isValidAddress(pickupAddress)) {
      errors['pickupAddress'] = 'عنوان الاستلام يجب أن يحتوي على 10 أحرف على الأقل';
    }

    if (!isValidAddress(deliveryAddress)) {
      errors['deliveryAddress'] = 'عنوان التسليم يجب أن يحتوي على 10 أحرف على الأقل';
    }

    if (!isValidPhoneNumber(senderPhone)) {
      errors['senderPhone'] = 'رقم هاتف المرسل غير صحيح';
    }

    if (!isValidPhoneNumber(receiverPhone)) {
      errors['receiverPhone'] = 'رقم هاتف المستقبل غير صحيح';
    }

    if (!isValidWeight(weight)) {
      errors['weight'] = 'الوزن يجب أن يكون بين 0 و 1000 كيلو';
    }

    if (description.trim().length < 5) {
      errors['description'] = 'وصف الطلب يجب أن يحتوي على 5 أحرف على الأقل';
    }

    return errors;
  }

  /// التحقق من صحة نموذج العرض
  static Map<String, String> validateOffer({
    required String price,
    required String estimatedTime,
    String? notes,
  }) {
    Map<String, String> errors = {};

    if (!isValidPrice(price)) {
      errors['price'] = 'السعر يجب أن يكون رقماً موجباً';
    }

    final timeValue = int.tryParse(estimatedTime);
    if (timeValue == null || timeValue <= 0 || timeValue > 1440) { // حد أقصى 24 ساعة
      errors['estimatedTime'] = 'الوقت المقدر يجب أن يكون بين 1 و 1440 دقيقة';
    }

    if (notes != null && notes.length > 500) {
      errors['notes'] = 'الملاحظات يجب أن تكون أقل من 500 حرف';
    }

    return errors;
  }

  /// التحقق من صحة بيانات السائق
  static Map<String, String> validateDriverProfile({
    required String name,
    required String phone,
    required String email,
    required String nationalId,
    required String licenseNumber,
    required String vehiclePlate,
    required String iban,
  }) {
    Map<String, String> errors = {};

    if (!isValidName(name)) {
      errors['name'] = 'الاسم يجب أن يحتوي على حرفين على الأقل';
    }

    if (!isValidPhoneNumber(phone)) {
      errors['phone'] = 'رقم الهاتف غير صحيح';
    }

    if (!isValidEmail(email)) {
      errors['email'] = 'البريد الإلكتروني غير صحيح';
    }

    if (!isValidSaudiId(nationalId) && !isValidIqamaNumber(nationalId)) {
      errors['nationalId'] = 'رقم الهوية أو الإقامة غير صحيح';
    }

    if (licenseNumber.length < 5) {
      errors['licenseNumber'] = 'رقم رخصة القيادة غير صحيح';
    }

    if (!isValidSaudiPlateNumber(vehiclePlate)) {
      errors['vehiclePlate'] = 'رقم لوحة السيارة غير صحيح';
    }

    if (!isValidSaudiIBAN(iban)) {
      errors['iban'] = 'رقم IBAN غير صحيح';
    }

    return errors;
  }
}