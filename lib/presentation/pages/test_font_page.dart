import 'package:flutter/material.dart';
import '../../core/theme/persian_fonts.dart';
import '../../widgets/font_test_widget.dart';

class TestFontPage extends StatelessWidget {
  const TestFontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'آزمایش فونت‌های فارسی',
          style: PersianFonts.appBarTitle,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان صفحه
            Text(
              'تست فونت وزیرمتن در اجزای مختلف',
              style: PersianFonts.pageTitle,
            ),
            const SizedBox(height: 24),
            
            // کارت آمار
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آمار سیستم',
                      style: PersianFonts.cardTitle,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('تعداد کاربران', '۱,۲۳۴'),
                        _buildStatItem('تعداد گزارشات', '۵,۶۷۸'),
                        _buildStatItem('تعداد خطاها', '۱۲'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // کارت تنظیمات
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تنظیمات سیستم',
                      style: PersianFonts.cardTitle,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text(
                        'تنظیمات دیتابیس',
                        style: PersianFonts.cardTitle,
                      ),
                      subtitle: Text(
                        'مدیریت اتصال و تنظیمات دیتابیس MySQL',
                        style: PersianFonts.cardSubtitle,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        'تنظیمات امنیتی',
                        style: PersianFonts.cardTitle,
                      ),
                      subtitle: Text(
                        'مدیریت رمز عبور و سطح دسترسی کاربران',
                        style: PersianFonts.cardSubtitle,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // فرم تست
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فرم تست ورودی',
                      style: PersianFonts.cardTitle,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'نام کاربری',
                        hintText: 'نام کاربری خود را وارد کنید',
                        helperText: 'نام کاربری باید حداقل ۳ کاراکتر باشد',
                      ),
                      style: PersianFonts.normal,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'رمز عبور',
                        hintText: 'رمز عبور خود را وارد کنید',
                        helperText: 'رمز عبور باید حداقل ۸ کاراکتر باشد',
                      ),
                      obscureText: true,
                      style: PersianFonts.normal,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('ورود به سیستم'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: Text('انصراف'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('فراموشی رمز'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // تست فونت‌های مختلف
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نمونه‌های فونت‌های مختلف',
                      style: PersianFonts.cardTitle,
                    ),
                    const SizedBox(height: 16),
                    _buildFontSample('فونت عادی', PersianFonts.normal),
                    _buildFontSample('فونت ضخیم', PersianFonts.bold),
                    _buildFontSample('فونت نازک', PersianFonts.light),
                    _buildFontSample('فونت کپشن', PersianFonts.caption),
                    _buildFontSample('فونت دکمه', PersianFonts.button),
                    _buildFontSample('فونت کوچک', PersianFonts.small),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // چیپ‌ها
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'چیپ‌های نمونه',
                      style: PersianFonts.cardTitle,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        Chip(label: Text('فعال')),
                        Chip(label: Text('غیرفعال')),
                        Chip(label: Text('در انتظار')),
                        Chip(label: Text('تکمیل شده')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Widget تست فونت کامل
            Card(
              elevation: 4,
              child: const FontTestWidget(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: PersianFonts.statisticsValue,
        ),
        Text(
          title,
          style: PersianFonts.statisticsTitle,
        ),
      ],
    );
  }
  
  Widget _buildFontSample(String title, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PersianFonts.caption),
          const SizedBox(height: 4),
          Text(
            'این متن نمونه‌ای است که با فونت وزیرمتن نمایش داده می‌شود.',
            style: style,
          ),
        ],
      ),
    );
  }
}
