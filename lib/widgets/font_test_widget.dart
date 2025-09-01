import 'package:flutter/material.dart';
import '../core/theme/persian_fonts.dart';

class FontTestWidget extends StatelessWidget {
  const FontTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تست فونت‌های مختلف
          Text('🎨 تست فونت‌های فارسی', style: PersianFonts.pageTitle),
          const SizedBox(height: 16),
          
          _buildFontTest('Normal', PersianFonts.normal, 'متن عادی فارسی - Test normal Persian text'),
          _buildFontTest('Bold', PersianFonts.bold, 'متن ضخیم فارسی - Test bold Persian text'),
          _buildFontTest('Light', PersianFonts.light, 'متن نازک فارسی - Test light Persian text'),
          _buildFontTest('Caption', PersianFonts.caption, 'کپشن فارسی - Persian caption text'),
          _buildFontTest('Button', PersianFonts.button, 'متن دکمه فارسی - Button text'),
          _buildFontTest('Small', PersianFonts.small, 'متن کوچک فارسی - Small Persian text'),
          
          const Divider(height: 32),
          
          // تست اعداد فارسی
          Text('🔢 تست اعداد فارسی', style: PersianFonts.pageTitle),
          const SizedBox(height: 16),
          
          _buildNumberTest('۱۲۳۴۵۶۷۸۹۰', 'اعداد فارسی'),
          _buildNumberTest('1234567890', 'اعداد انگلیسی'),
          _buildNumberTest('۱,۲۳۴,۵۶۷', 'عدد با ویرگول فارسی'),
          _buildNumberTest('1,234,567', 'عدد با ویرگول انگلیسی'),
          
          const Divider(height: 32),
          
          // تست متن‌های مخلوط
          Text('🌐 تست متن‌های مخلوط', style: PersianFonts.pageTitle),
          const SizedBox(height: 16),
          
          _buildMixedTextTest(),
          
          const Divider(height: 32),
          
          // تست نمادها و علائم
          Text('⚡ تست نمادها و علائم', style: PersianFonts.pageTitle),
          const SizedBox(height: 16),
          
          _buildSymbolTest(),
        ],
      ),
    );
  }
  
  Widget _buildFontTest(String label, TextStyle style, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PersianFonts.caption.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(text, style: style),
        ],
      ),
    );
  }
  
  Widget _buildNumberTest(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(description, style: PersianFonts.caption)),
          Expanded(flex: 2, child: Text(number, style: PersianFonts.normal)),
        ],
      ),
    );
  }
  
  Widget _buildMixedTextTest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'این متن شامل کلمات فارسی و English words می‌باشد.',
          style: PersianFonts.normal,
        ),
        const SizedBox(height: 8),
        Text(
          'DataSave یک سیستم مدیریت Data است که در سال ۲۰۲۵ ساخته شده.',
          style: PersianFonts.normal,
        ),
        const SizedBox(height: 8),
        Text(
          'تست URL: https://example.com/data-save',
          style: PersianFonts.normal,
        ),
        const SizedBox(height: 8),
        Text(
          'ایمیل: test@datasave.com | تلفن: ۰۲۱-۱۲۳۴۵۶۷۸',
          style: PersianFonts.normal,
        ),
      ],
    );
  }
  
  Widget _buildSymbolTest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✅ تیک سبز | ❌ ضربدر قرمز | ⚠️ هشدار زرد', style: PersianFonts.normal),
        const SizedBox(height: 8),
        Text('🚀 راکت | 💾 دیسک | 🔧 ابزار | 📊 نمودار', style: PersianFonts.normal),
        const SizedBox(height: 8),
        Text('« » ( ) [ ] { } " " ' '', style: PersianFonts.normal),
        const SizedBox(height: 8),
        Text('! @ # \$ % ^ & * - + = | \\ / ? . , ; :', style: PersianFonts.normal),
        const SizedBox(height: 8),
        Text('پرانتز: (متن داخل پرانتز) | گیومه: «متن داخل گیومه»', style: PersianFonts.normal),
      ],
    );
  }
}
