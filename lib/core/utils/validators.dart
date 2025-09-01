class Validators {
  // اعتبارسنجی ایمیل
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ایمیل الزامی است';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'فرمت ایمیل صحیح نیست';
    }
    
    return null;
  }
  
  // اعتبارسنجی رمز عبور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز عبور الزامی است';
    }
    
    if (value.length < 6) {
      return 'رمز عبور باید حداقل 6 کاراکتر باشد';
    }
    
    return null;
  }
  
  // اعتبارسنجی متن الزامی
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName الزامی است';
    }
    return null;
  }
  
  // اعتبارسنجی شماره تلفن
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'شماره تلفن الزامی است';
    }
    
    // Pattern برای شماره‌های ایرانی
    final phoneRegex = RegExp(r'^(\+98|0)?9\d{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'فرمت شماره تلفن صحیح نیست';
    }
    
    return null;
  }
  
  // اعتبارسنجی URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'فرمت URL صحیح نیست';
    }
    
    return null;
  }
}
