# راهنمای رابط کاربری - User Interface Guidelines

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Design Team
- **Related Files:** `/lib/core/guidelines/`, `/lib/presentation/widgets/`

## 🎯 Overview
این مستند راهنمای جامع طراحی رابط کاربری DataSave است که شامل اصول طراحی، الگوهای UI، راهنمای RTL، و بهترین شیوه‌های UX برای پلتفرم ایجاد فرم هوشمند با پشتیبانی کامل از زبان فارسی است.

## 📋 Table of Contents
- [اصول طراحی UI](#اصول-طراحی-ui)
- [الگوهای طراحی](#الگوهای-طراحی)
- [رابط کاربری فارسی](#رابط-کاربری-فارسی)
- [Layout Guidelines](#layout-guidelines)
- [الگوهای تعامل](#الگوهای-تعامل)
- [دسترسی‌پذیری](#دسترسی‌پذیری)
- [نمونه‌های کاربردی](#نمونه‌های-کاربردی)

## 🎨 اصول طراحی UI

### اصول بنیادی DataSave
```yaml
Core Design Principles:
  1. Persian-First Design:
     - طراحی با در نظر گیری زبان فارسی
     - پشتیبانی کامل از RTL
     - استفاده از فونت‌های بهینه فارسی
     
  2. Simplicity & Clarity:
     - رابط ساده و قابل فهم
     - حذف عناصر اضافی
     - تمرکز بر محتوا
     
  3. Consistency:
     - یکسانی در تمام بخش‌ها
     - الگوهای قابل پیش‌بینی
     - رفتار منطقی کامپوننت‌ها
     
  4. Accessibility:
     - دسترسی برای همه کاربران
     - پشتیبانی از screen readers
     - کنتراست مناسب رنگ‌ها
     
  5. Mobile-First:
     - طراحی ابتدا برای موبایل
     - واکنش‌گرا در همه اندازه‌ها
     - لمس و تعامل بهینه
```

### سلسله‌مراتب بصری
```yaml
Visual Hierarchy:
  Primary Elements:
    - عنوان اصلی صفحه
    - دکمه‌های اصلی (CTA)
    - محتوای کلیدی
    
  Secondary Elements:
    - عناوین فرعی
    - متن‌های توضیحی
    - آیکون‌های راهنما
    
  Tertiary Elements:
    - برچسب‌ها و تگ‌ها
    - اطلاعات اضافی
    - عناصر کمکی
```

## 🔄 الگوهای طراحی

### الگوی Layout اصلی
```dart
// lib/core/guidelines/layout_patterns.dart

import 'package:flutter/material.dart';

class MainLayoutPattern extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final Widget? bottomNavigation;
  final Widget? floatingActionButton;
  final bool hasSidebar;
  
  const MainLayoutPattern({
    Key? key,
    required this.appBar,
    required this.body,
    this.bottomNavigation,
    this.floatingActionButton,
    this.hasSidebar = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // RTL اولویت
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: appBar,
        ),
        
        // Sidebar برای tablet/desktop
        drawer: hasSidebar ? _buildSidebar(context) : null,
        
        body: SafeArea(
          child: body,
        ),
        
        // Navigation Bottom
        bottomNavigationBar: bottomNavigation,
        
        // FAB
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
  
  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'DataSave',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'داشبورد',
                  onTap: () => Navigator.pop(context),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.article,
                  title: 'فرم‌ها',
                  onTap: () => Navigator.pop(context),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.analytics,
                  title: 'آمار و گزارش',
                  onTap: () => Navigator.pop(context),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.settings,
                  title: 'تنظیمات',
                  onTap: () => Navigator.pop(context),
                ),
                Divider(),
                _buildSidebarItem(
                  context,
                  icon: Icons.help,
                  title: 'راهنما',
                  onTap: () => Navigator.pop(context),
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.support,
                  title: 'پشتیبانی',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
```

### الگوی کارت محتوا
```dart
// lib/core/guidelines/card_patterns.dart

import 'package:flutter/material.dart';

enum CardVariant {
  basic,
  elevated,
  outlined,
  filled,
}

class ContentCardPattern extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? trailing;
  final CardVariant variant;
  final VoidCallback? onTap;
  
  const ContentCardPattern({
    Key? key,
    this.title,
    this.subtitle,
    this.content,
    this.actions,
    this.leading,
    this.trailing,
    this.variant = CardVariant.elevated,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: _getElevation(),
      color: _getBackgroundColor(colorScheme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _getBorderSide(colorScheme),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header با title و subtitle
              if (title != null || subtitle != null || leading != null || trailing != null)
                _buildHeader(context),
              
              // محتوای اصلی
              if (content != null) ...[
                if (title != null || subtitle != null) SizedBox(height: 12),
                content!,
              ],
              
              // دکمه‌های عملیات
              if (actions != null && actions!.isNotEmpty) ...[
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((action) => Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: action,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: 12),
        ],
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        
        if (trailing != null) ...[
          SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
  
  double _getElevation() {
    switch (variant) {
      case CardVariant.basic:
        return 0;
      case CardVariant.elevated:
        return 1;
      case CardVariant.outlined:
        return 0;
      case CardVariant.filled:
        return 0;
    }
  }
  
  Color? _getBackgroundColor(ColorScheme colorScheme) {
    switch (variant) {
      case CardVariant.basic:
        return colorScheme.surface;
      case CardVariant.elevated:
        return colorScheme.surface;
      case CardVariant.outlined:
        return colorScheme.surface;
      case CardVariant.filled:
        return colorScheme.surfaceVariant;
    }
  }
  
  BorderSide _getBorderSide(ColorScheme colorScheme) {
    if (variant == CardVariant.outlined) {
      return BorderSide(color: colorScheme.outline);
    }
    return BorderSide.none;
  }
}
```

### الگوی فرم
```dart
// lib/core/guidelines/form_patterns.dart

import 'package:flutter/material.dart';

class FormPattern extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<FormFieldPattern> fields;
  final List<Widget>? actions;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  
  const FormPattern({
    Key? key,
    required this.title,
    this.subtitle,
    required this.fields,
    this.actions,
    this.onSubmit,
    this.onCancel,
  }) : super(key: key);
  
  @override
  State<FormPattern> createState() => _FormPatternState();
}

class _FormPatternState extends State<FormPattern> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildFormHeader(context),
          
          SizedBox(height: 24),
          
          // Fields
          ...widget.fields.map((field) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: field,
          )),
          
          SizedBox(height: 24),
          
          // Actions
          _buildFormActions(context),
        ],
      ),
    );
  }
  
  Widget _buildFormHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        if (widget.subtitle != null) ...[
          SizedBox(height: 8),
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildFormActions(BuildContext context) {
    final defaultActions = [
      if (widget.onCancel != null)
        OutlinedButton(
          onPressed: widget.onCancel,
          child: Text('لغو'),
        ),
      
      FilledButton(
        onPressed: widget.onSubmit ?? () => _submitForm(),
        child: Text('ذخیره'),
      ),
    ];
    
    final actions = widget.actions ?? defaultActions;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions
          .map((action) => Padding(
                padding: EdgeInsets.only(left: 8),
                child: action,
              ))
          .toList(),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // پردازش فرم
    }
  }
}

// فیلد فرم
class FormFieldPattern extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  
  const FormFieldPattern({
    Key? key,
    required this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onSaved,
    this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // برچسب فیلد
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.labelLarge,
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        
        // فیلد ورودی
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator ?? (required ? _defaultValidator : null),
          onSaved: onSaved,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            
            // Material 3 styling
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'این فیلد الزامی است';
    }
    return null;
  }
}
```

## 🌐 رابط کاربری فارسی

### اصول RTL
```yaml
RTL Design Principles:
  Layout Direction:
    - جهت کلی از راست به چپ
    - آیکون‌ها در سمت راست
    - دکمه‌ها از راست به چپ
    
  Navigation:
    - منوی کشویی از سمت راست
    - برگشت در سمت راست
    - جلو در سمت چپ
    
  Text Alignment:
    - متن فارسی: راست‌چین
    - اعداد انگلیسی: چپ‌چین
    - URL و ایمیل: چپ‌چین
    
  Icons and Graphics:
    - آیکون‌های جهت‌دار معکوس شوند
    - تصاویر طبق نیاز تغییر کنند
    - نمودارها RTL باشند
```

### پیاده‌سازی RTL
```dart
// lib/core/guidelines/rtl_helper.dart

import 'package:flutter/material.dart';

class RTLHelper {
  // تعیین جهت متن براساس محتوا
  static TextDirection getTextDirection(String text) {
    if (text.isEmpty) return TextDirection.rtl;
    
    // بررسی کاراکترهای فارسی
    final persianRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    
    if (persianRegex.hasMatch(text)) {
      return TextDirection.rtl;
    }
    
    // بررسی کاراکترهای عربی
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(text)) {
      return TextDirection.rtl;
    }
    
    return TextDirection.ltr;
  }
  
  // Widget برای تطبیق خودکار جهت
  static Widget adaptiveText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final direction = getTextDirection(text);
    
    return Directionality(
      textDirection: direction,
      child: Text(
        text,
        style: style,
        textAlign: textAlign ?? (direction == TextDirection.rtl ? TextAlign.right : TextAlign.left),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
  
  // تنظیم padding برای RTL
  static EdgeInsets adaptivePadding({
    double top = 0,
    double bottom = 0,
    double start = 0,
    double end = 0,
  }) {
    return EdgeInsetsDirectional.only(
      top: top,
      bottom: bottom,
      start: start,
      end: end,
    );
  }
  
  // تنظیم margin برای RTL
  static EdgeInsets adaptiveMargin({
    double top = 0,
    double bottom = 0,
    double start = 0,
    double end = 0,
  }) {
    return EdgeInsetsDirectional.only(
      top: top,
      bottom: bottom,
      start: start,
      end: end,
    );
  }
  
  // آیکون‌های تطبیق‌یافته
  static IconData adaptiveIcon(IconData ltrIcon, {IconData? rtlIcon}) {
    // در Flutter، آیکون‌ها به صورت خودکار تطبیق می‌یابند
    // اما گاهی نیاز به تنظیمات خاص داریم
    return rtlIcon ?? ltrIcon;
  }
  
  // تنظیم alignment برای RTL
  static AlignmentGeometry adaptiveAlignment(AlignmentGeometry alignment) {
    if (alignment == Alignment.centerRight) {
      return AlignmentDirectional.centerStart;
    } else if (alignment == Alignment.centerLeft) {
      return AlignmentDirectional.centerEnd;
    }
    return alignment;
  }
}

// Widget کمکی برای RTL
class RTLWrapper extends StatelessWidget {
  final Widget child;
  final bool forceRTL;
  
  const RTLWrapper({
    Key? key,
    required this.child,
    this.forceRTL = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (forceRTL) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      );
    }
    return child;
  }
}
```

## 📐 Layout Guidelines

### Grid System
```dart
// lib/core/guidelines/grid_system.dart

class GridSystem {
  // نقاط شکست responsive
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // فاصله‌گذاری استاندارد
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing64 = 64;
  
  // حاشیه‌ها
  static const EdgeInsets mobilePadding = EdgeInsets.all(16);
  static const EdgeInsets tabletPadding = EdgeInsets.all(24);
  static const EdgeInsets desktopPadding = EdgeInsets.all(32);
  
  // تعیین تعداد ستون‌ها براساس اندازه صفحه
  static int getColumnCount(double width) {
    if (width < mobileBreakpoint) return 1;
    if (width < tabletBreakpoint) return 2;
    if (width < desktopBreakpoint) return 3;
    return 4;
  }
  
  // دریافت padding مناسب
  static EdgeInsets getResponsivePadding(double width) {
    if (width < mobileBreakpoint) return mobilePadding;
    if (width < tabletBreakpoint) return tabletPadding;
    return desktopPadding;
  }
}
```

### Responsive Builder
```dart
// lib/core/guidelines/responsive_builder.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/guidelines/grid_system.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;
  
  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (width >= GridSystem.desktopBreakpoint && desktop != null) {
          return desktop!(context, constraints);
        } else if (width >= GridSystem.tabletBreakpoint && tablet != null) {
          return tablet!(context, constraints);
        } else {
          return mobile(context, constraints);
        }
      },
    );
  }
}

// استفاده از ResponsiveBuilder
class ResponsiveExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, constraints) => _buildMobileLayout(),
      tablet: (context, constraints) => _buildTabletLayout(),
      desktop: (context, constraints) => _buildDesktopLayout(),
    );
  }
  
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Layout موبایل - تک ستونه
        Container(
          padding: GridSystem.mobilePadding,
          child: Text('موبایل'),
        ),
      ],
    );
  }
  
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Layout تبلت - دو ستونه
        Expanded(
          child: Container(
            padding: GridSystem.tabletPadding,
            child: Text('تبلت - ستون ۱'),
          ),
        ),
        Expanded(
          child: Container(
            padding: GridSystem.tabletPadding,
            child: Text('تبلت - ستون ۲'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Layout دسکتاپ - سه ستونه
        Expanded(
          child: Container(
            padding: GridSystem.desktopPadding,
            child: Text('دسکتاپ - ستون ۱'),
          ),
        ),
        Expanded(
          child: Container(
            padding: GridSystem.desktopPadding,
            child: Text('دسکتاپ - ستون ۲'),
          ),
        ),
        Expanded(
          child: Container(
            padding: GridSystem.desktopPadding,
            child: Text('دسکتاپ - ستون ۳'),
          ),
        ),
      ],
    );
  }
}
```

## 🎯 الگوهای تعامل

### Loading States
```dart
// lib/core/guidelines/loading_patterns.dart

import 'package:flutter/material.dart';

enum LoadingState {
  initial,
  loading,
  success,
  error,
  empty,
}

class LoadingStateWidget extends StatelessWidget {
  final LoadingState state;
  final Widget? child;
  final String? errorMessage;
  final String? emptyMessage;
  final VoidCallback? onRetry;
  
  const LoadingStateWidget({
    Key? key,
    required this.state,
    this.child,
    this.errorMessage,
    this.emptyMessage,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    switch (state) {
      case LoadingState.initial:
      case LoadingState.loading:
        return _buildLoadingWidget(context);
        
      case LoadingState.success:
        return child ?? SizedBox();
        
      case LoadingState.error:
        return _buildErrorWidget(context);
        
      case LoadingState.empty:
        return _buildEmptyWidget(context);
    }
  }
  
  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'در حال بارگذاری...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16),
            Text(
              errorMessage ?? 'خطا در بارگذاری اطلاعات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            if (onRetry != null)
              FilledButton(
                onPressed: onRetry,
                child: Text('تلاش مجدد'),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            Text(
              emptyMessage ?? 'موردی یافت نشد',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Dialog Patterns
```dart
// lib/core/guidelines/dialog_patterns.dart

import 'package:flutter/material.dart';

class DialogPatterns {
  // دیالوگ تأیید
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon != null ? Icon(icon, color: iconColor) : null,
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? 'لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText ?? 'تأیید'),
          ),
        ],
      ),
    );
  }
  
  // دیالوگ اطلاعات
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? buttonText,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon != null ? Icon(icon, color: iconColor) : null,
        title: Text(title),
        content: Text(content),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'باشه'),
          ),
        ],
      ),
    );
  }
  
  // دیالوگ ورودی
  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
    String? confirmText,
    String? cancelText,
  }) {
    final controller = TextEditingController(text: initialValue);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText ?? 'لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(confirmText ?? 'تأیید'),
          ),
        ],
      ),
    );
  }
}
```

## ♿ دسترسی‌پذیری

### راهنمای Accessibility
```yaml
Accessibility Guidelines:
  Screen Reader Support:
    - استفاده از Semantics widgets
    - تنظیم label و hint مناسب
    - ترتیب منطقی خواندن محتوا
    
  Color & Contrast:
    - حداقل نسبت کنتراست 4.5:1
    - عدم اتکا به رنگ به تنهایی
    - پشتیبانی از high contrast mode
    
  Navigation:
    - پشتیبانی از keyboard navigation
    - focus indicators واضح
    - skip links برای محتوای تکراری
    
  Font Size:
    - پشتیبانی از تنظیمات system font size
    - حداقل 14px برای text
    - قابلیت تغییر اندازه تا 200%
    
  Interactive Elements:
    - حداقل اندازه لمس 44x44 dp
    - فاصله مناسب بین عناصر
    - feedback واضح برای تعاملات
```

### پیاده‌سازی Accessibility
```dart
// lib/core/guidelines/accessibility_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityHelper {
  // تنظیم Semantics برای متن
  static Widget accessibleText(
    String text, {
    String? semanticLabel,
    bool isHeading = false,
    TextStyle? style,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      header: isHeading,
      child: Text(text, style: style),
    );
  }
  
  // دکمه قابل دسترس
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? tooltip,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: enabled,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      ),
    );
  }
  
  // فیلد ورودی قابل دسترس
  static Widget accessibleTextField({
    required String label,
    String? hint,
    String? value,
    bool required = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
  
  // بررسی تنظیمات دسترسی‌پذیری
  static bool isLargeTextEnabled(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.0;
  }
  
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
  
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }
  
  // تنظیم اندازه برای دسترسی‌پذیری
  static double getAccessibleSize(BuildContext context, double baseSize) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return baseSize * textScaleFactor.clamp(1.0, 2.0);
  }
}
```

## 🎨 نمونه‌های کاربردی

### صفحه با الگوی کامل
```dart
// lib/presentation/screens/examples/ui_guidelines_example.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/guidelines/layout_patterns.dart';
import 'package:datasave/core/guidelines/card_patterns.dart';
import 'package:datasave/core/guidelines/form_patterns.dart';
import 'package:datasave/core/guidelines/loading_patterns.dart';

class UIGuidelinesExampleScreen extends StatefulWidget {
  @override
  State<UIGuidelinesExampleScreen> createState() => _UIGuidelinesExampleScreenState();
}

class _UIGuidelinesExampleScreenState extends State<UIGuidelinesExampleScreen> {
  LoadingState _loadingState = LoadingState.success;
  
  @override
  Widget build(BuildContext context) {
    return MainLayoutPattern(
      appBar: AppBar(
        title: Text('نمونه راهنمای UI'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      
      body: LoadingStateWidget(
        state: _loadingState,
        onRetry: _refreshData,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // نمونه کارت‌ها
            ContentCardPattern(
              title: 'کارت نمونه',
              subtitle: 'این یک کارت نمونه است',
              leading: Icon(Icons.star, color: Colors.amber),
              content: Text('محتوای کارت در اینجا قرار می‌گیرد. این متن نشان‌دهنده محتوای اصلی کارت است.'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: Text('عملیات'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: Text('اصلی'),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // نمونه فرم
            ContentCardPattern(
              title: 'فرم نمونه',
              content: FormPattern(
                title: 'اطلاعات کاربری',
                subtitle: 'لطفاً اطلاعات زیر را تکمیل کنید',
                fields: [
                  FormFieldPattern(
                    label: 'نام',
                    hint: 'نام خود را وارد کنید',
                    required: true,
                    prefixIcon: Icons.person,
                  ),
                  FormFieldPattern(
                    label: 'ایمیل',
                    hint: 'example@email.com',
                    required: true,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                  ),
                  FormFieldPattern(
                    label: 'رمز عبور',
                    hint: 'حداقل ۸ کاراکتر',
                    required: true,
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    suffixIcon: Icons.visibility_off,
                  ),
                ],
                onSubmit: _submitForm,
                onCancel: () {},
              ),
            ),
            
            SizedBox(height: 16),
            
            // نمونه انواع کارت
            Row(
              children: [
                Expanded(
                  child: ContentCardPattern(
                    variant: CardVariant.outlined,
                    title: 'کارت حاشیه‌ای',
                    content: Icon(Icons.border_all, size: 48),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ContentCardPattern(
                    variant: CardVariant.filled,
                    title: 'کارت پر شده',
                    content: Icon(Icons.color_lens, size: 48),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // دکمه‌های تست
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _changeLoadingState(LoadingState.loading),
                  child: Text('Loading'),
                ),
                ElevatedButton(
                  onPressed: () => _changeLoadingState(LoadingState.error),
                  child: Text('Error'),
                ),
                ElevatedButton(
                  onPressed: () => _changeLoadingState(LoadingState.empty),
                  child: Text('Empty'),
                ),
              ],
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.add),
        label: Text('جدید'),
      ),
    );
  }
  
  void _refreshData() {
    setState(() {
      _loadingState = LoadingState.loading;
    });
    
    // شبیه‌سازی بارگذاری
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _loadingState = LoadingState.success;
        });
      }
    });
  }
  
  void _changeLoadingState(LoadingState state) {
    setState(() {
      _loadingState = state;
    });
  }
  
  void _submitForm() {
    // پردازش فرم
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فرم ارسال شد')),
    );
  }
}
```

## 🏆 بهترین شیوه‌ها

### کدهای تمیز UI
```yaml
Clean UI Code Practices:
  1. Component Reusability:
     - ایجاد کامپوننت‌های قابل استفاده مجدد
     - پارامترهای مناسب و flexible
     - مستندسازی کامل
     
  2. State Management:
     - جداسازی UI از business logic
     - استفاده از state management مناسب
     - reactive patterns
     
  3. Performance:
     - استفاده از const constructors
     - بهینه‌سازی rebuild ها
     - lazy loading برای لیست‌های طولانی
     
  4. Accessibility:
     - همیشه Semantics را در نظر بگیرید
     - تست با screen readers
     - پشتیبانی از keyboard navigation
     
  5. Responsive Design:
     - طراحی برای همه اندازه‌ها
     - استفاده از LayoutBuilder
     - تست در دستگاه‌های مختلف
```

## 🔄 Related Documentation
- [Material Design 3](material-design-3.md)
- [Typography and Fonts](typography-fonts.md)
- [Color Scheme](color-scheme.md)
- [Persian RTL Implementation](../04-Flutter-Frontend/persian-rtl-implementation.md)
- [UI Components Library](ui-components-library.md)

---
*Last updated: 2025-09-01*  
*File: docs/06-UI-UX-Design/user-interface-guidelines.md*