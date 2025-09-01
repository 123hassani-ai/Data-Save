# محیط توسعه - Development Environment

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/README.md`, `/.vscode/`, `/pubspec.yaml`

## 🎯 Overview
راهنمای کامل راه‌اندازی محیط توسعه برای پروژه DataSave شامل تنظیمات XAMPP، Flutter، VS Code، و ابزارهای مورد نیاز برای توسعه‌دهندگان.

## 📋 Table of Contents
- [پیش‌نیازهای سیستم](#پیشنیازهای-سیستم)
- [نصب و راه‌اندازی XAMPP](#نصب-و-راهاندازی-xampp)
- [نصب و تنظیم Flutter](#نصب-و-تنظیم-flutter)
- [تنظیمات VS Code](#تنظیمات-vs-code)
- [کلون و راه‌اندازی پروژه](#کلون-و-راهاندازی-پروژه)
- [ابزارهای کمکی](#ابزارهای-کمکی)
- [تست محیط](#تست-محیط)
- [عیب‌یابی مشکلات رایج](#عیبیابی-مشکلات-رایج)

## 💻 پیش‌نیازهای سیستم - System Requirements

### سیستم عامل
```yaml
macOS:
  Version: macOS 10.14+ (Mojave یا جدیدتر)
  RAM: حداقل 8GB، توصیه 16GB
  Storage: حداقل 10GB فضای خالی
  Processor: Intel یا Apple Silicon

Windows:
  Version: Windows 10 64-bit یا جدیدتر
  RAM: حداقل 8GB، توصیه 16GB
  Storage: حداقل 10GB فضای خالی
  
Linux:
  Ubuntu 18.04+، Debian 10+، یا معادل
  RAM: حداقل 8GB، توصیه 16GB
  Storage: حداقل 10GB فضای خالی
```

### نرم‌افزارهای پایه
```yaml
Essential:
  - Git (version control)
  - Web Browser (Chrome/Firefox/Safari)
  - Terminal/Command Line
  - Text Editor یا IDE

Recommended:
  - VS Code (Primary IDE)
  - Postman (API testing)
  - Sequel Pro/phpMyAdmin (Database management)
  - Firefox Developer Edition (Web debugging)
```

---

## 🗄️ نصب و راه‌اندازی XAMPP - XAMPP Setup

### دانلود و نصب
```bash
# macOS - دانلود از سایت رسمی
# https://www.apachefriends.org/download.html

# نصب از طریق Homebrew (اختیاری)
brew install --cask xampp

# Windows - دانلود installer
# همان لینک بالا

# Linux Ubuntu/Debian
wget https://www.apachefriends.org/xampp-files/8.2.12/xampp-linux-x64-8.2.12-0-installer.run
chmod +x xampp-linux-x64-8.2.12-0-installer.run
sudo ./xampp-linux-x64-8.2.12-0-installer.run
```

### تنظیمات XAMPP برای DataSave
```bash
# macOS - مسیر XAMPP
/Applications/XAMPP/xamppfiles/

# شروع XAMPP
sudo /Applications/XAMPP/xamppfiles/xampp start

# یا استفاده از XAMPP Control Panel
open /Applications/XAMPP/XAMPP\ Control.app

# Windows
# استفاده از XAMPP Control Panel از Start Menu
```

### پیکربندی MySQL برای فارسی
```sql
-- دسترسی به MySQL
mysql -h localhost -P 3307 -u root -pMojtab@123

-- تنظیم character set برای فارسی
SET character_set_server = utf8mb4;
SET collation_server = utf8mb4_persian_ci;

-- بررسی تنظیمات
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
```

### ایجاد دیتابیس DataSave
```sql
-- ایجاد دیتابیس با charset صحیح
CREATE DATABASE datasave 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_persian_ci;

-- بررسی ایجاد موفقیت‌آمیز
USE datasave;
SHOW TABLES;
```

### تنظیمات Apache برای CORS
```apache
# فایل: /Applications/XAMPP/xamppfiles/etc/httpd.conf
# اضافه کردن این خطوط:

LoadModule rewrite_module modules/mod_rewrite.so
LoadModule headers_module modules/mod_headers.so

# در بخش <Directory> مربوط به htdocs:
<Directory "/Applications/XAMPP/xamppfiles/htdocs">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    
    # CORS برای Flutter web
    Header always set Access-Control-Allow-Origin "http://localhost:8085"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
</Directory>
```

---

## 📱 نصب و تنظیم Flutter - Flutter Setup

### نصب Flutter SDK
```bash
# macOS - استفاده از Homebrew
brew install flutter

# یا دانلود دستی
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# اضافه کردن به PATH
export PATH="$PATH:`pwd`/flutter/bin"
echo 'export PATH="$PATH:~/development/flutter/bin"' >> ~/.zshrc

# Windows - دانلود از سایت رسمی Flutter
# https://docs.flutter.dev/get-started/install/windows

# Linux
sudo snap install flutter --classic
```

### تنظیم Flutter برای وب
```bash
# فعال‌سازی web support
flutter config --enable-web

# بروزرسانی Flutter
flutter upgrade

# بررسی وضعیت
flutter doctor -v
```

### نصب Dependencies
```bash
# Android Studio (برای Android development)
# iOS development tools (فقط macOS)

# Chrome برای Flutter web debugging
# که معمولاً از قبل نصب است

# بررسی تمام dependencies
flutter doctor

# خروجی مورد انتظار:
# ✓ Flutter (Channel stable, 3.16.0)
# ✓ Android toolchain 
# ✓ Chrome - develop for the web
# ✓ VS Code
```

---

## 🛠️ تنظیمات VS Code - VS Code Setup

### نصب VS Code
```bash
# macOS - Homebrew
brew install --cask visual-studio-code

# یا دانلود از سایت رسمی
# https://code.visualstudio.com/

# Windows/Linux - دانلود از همان سایت
```

### Extensions ضروری
```json
// فایل: .vscode/extensions.json
{
  "recommendations": [
    // Flutter & Dart
    "Dart-Code.flutter",
    "Dart-Code.dart-code",
    
    // PHP Development
    "bmewburn.vscode-intelephense-client",
    "xdebug.php-debug",
    "rifi2k.format-html-in-php",
    
    // Database
    "ms-mssql.mssql",
    "cweijan.vscode-mysql-client2",
    
    // Git & Version Control
    "eamodio.gitlens",
    "mhutchie.git-graph",
    
    // General Development
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-json",
    "ms-vscode.live-server",
    "bradlc.vscode-tailwindcss",
    
    // Persian Support
    "mshr-h.persian-rtl",
    "mahob.persian-input-tools",
    
    // Productivity
    "ms-vscode.vscode-snippet-manager",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense"
  ]
}
```

### تنظیمات VS Code برای DataSave
```json
// فایل: .vscode/settings.json
{
  // Flutter Settings
  "flutter.previewEmbeddedAndroidViews": true,
  "flutter.previewFlutterUiGuides": true,
  "flutter.previewFlutterUiGuidesCustomTracking": true,
  "dart.previewLsp": true,
  "dart.lineLength": 100,
  "dart.insertArgumentPlaceholders": false,
  
  // PHP Settings
  "php.suggest.basic": false,
  "intelephense.files.maxSize": 5000000,
  "intelephense.format.braces": "k&r",
  
  // Persian RTL Support
  "editor.unicodeHighlight.ambiguousCharacters": false,
  "editor.unicodeHighlight.invisibleCharacters": false,
  "bidi.enabled": true,
  
  // File Associations
  "files.associations": {
    "*.php": "php",
    "*.dart": "dart"
  },
  
  // Auto Save
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  
  // Git
  "git.autofetch": true,
  "git.confirmSync": false,
  
  // Terminal
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.fontSize": 14,
  
  // Formatting
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### Launch Configurations
```json
// فایل: .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "DataSave Flutter Web",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "deviceId": "chrome",
      "args": [
        "--web-port=8085",
        "--web-hostname=localhost"
      ]
    },
    {
      "name": "DataSave Flutter Debug",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart"
    },
    {
      "name": "Listen for Xdebug (PHP)",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/Applications/XAMPP/xamppfiles/htdocs/datasave": "${workspaceFolder}"
      }
    }
  ]
}
```

### Tasks Configuration
```json
// فایل: .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Flutter Clean & Get",
      "type": "shell",
      "command": "flutter clean && flutter pub get",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Start XAMPP",
      "type": "shell",
      "command": "sudo /Applications/XAMPP/xamppfiles/xampp start",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "Stop XAMPP", 
      "type": "shell",
      "command": "sudo /Applications/XAMPP/xamppfiles/xampp stop",
      "group": "build"
    },
    {
      "label": "Flutter Run Web",
      "type": "shell", 
      "command": "flutter run -d chrome --web-port=8085",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    }
  ]
}
```

---

## 📂 کلون و راه‌اندازی پروژه - Project Setup

### کلون کردن مخزن
```bash
# کلون پروژه از GitHub
git clone https://github.com/123hassani-ai/Data-Save.git
cd Data-Save

# یا کلون در مسیر XAMPP htdocs
cd /Applications/XAMPP/xamppfiles/htdocs/
git clone https://github.com/123hassani-ai/Data-Save.git datasave
cd datasave
```

### راه‌اندازی Backend PHP
```bash
# کپی کردن فایل‌های پیکربندی
cp backend/config/database.example.php backend/config/database.php

# ویرایش تنظیمات دیتابیس
nano backend/config/database.php
```

```php
// تنظیمات دیتابیس در database.php
private static $host = 'localhost';
private static $port = '3307';  // XAMPP MySQL port
private static $database = 'datasave';
private static $username = 'root';
private static $password = 'Mojtab@123';  // طبق roles.instructions.md
```

### راه‌اندازی دیتابیس
```bash
# وارد شدن به MySQL
mysql -h localhost -P 3307 -u root -pMojtab@123

# اجرای script ایجاد جداول
mysql -h localhost -P 3307 -u root -pMojtab@123 datasave < database_setup.sql

# بررسی جداول ایجاد شده
mysql -h localhost -P 3307 -u root -pMojtab@123 -e "USE datasave; SHOW TABLES;"
```

### راه‌اندازی Frontend Flutter
```bash
# نصب dependencies
flutter pub get

# اجرای flutter doctor برای بررسی مشکلات
flutter doctor

# اجرای پروژه
flutter run -d chrome --web-port=8085
```

### تست اتصال API
```bash
# تست Backend API
curl -X GET "http://localhost/datasave/backend/api/settings/get.php"

# باید پاسخ JSON دریافت کنید:
# {"success":true,"data":[...],"count":9}
```

---

## 🔧 ابزارهای کمکی - Development Tools

### Database Management
```bash
# phpMyAdmin (web-based)
http://localhost/phpmyadmin
# User: root, Password: Mojtab@123

# Sequel Pro (macOS)
brew install --cask sequel-pro

# MySQL Workbench (Cross-platform)
brew install --cask mysqlworkbench
```

### API Testing
```bash
# Postman
brew install --cask postman

# یا HTTPie (command line)
brew install httpie

# تست API با HTTPie
http GET localhost/datasave/backend/api/settings/get.php
```

### Git GUI Tools
```bash
# GitKraken
brew install --cask gitkraken

# SourceTree
brew install --cask sourcetree

# GitHub Desktop
brew install --cask github
```

### Performance Monitoring
```bash
# Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# PHP Debug Bar (اختیاری)
composer require maximebf/debugbar
```

---

## ✅ تست محیط - Environment Testing

### چک‌لیست راه‌اندازی
```bash
# 1. بررسی XAMPP
sudo /Applications/XAMPP/xamppfiles/xampp status
# باید Apache و MySQL running باشند

# 2. بررسی دیتابیس
mysql -h localhost -P 3307 -u root -pMojtab@123 -e "SELECT COUNT(*) FROM datasave.system_settings;"
# باید تعداد تنظیمات (مثل 9) نمایش دهد

# 3. بررسی Flutter
flutter doctor
# همه چیز باید ✓ باشد

# 4. تست Backend API
curl "http://localhost/datasave/backend/api/settings/get.php"
# باید JSON معتبر برگرداند

# 5. اجرای Flutter
flutter run -d chrome --web-port=8085
# باید برنامه در Chrome باز شود
```

### تست کامل سیستم
```bash
#!/bin/bash
echo "🧪 شروع تست کامل محیط توسعه DataSave..."

# تست 1: XAMPP
echo "1️⃣ بررسی XAMPP..."
if sudo /Applications/XAMPP/xamppfiles/xampp status | grep -q "running"; then
    echo "✅ XAMPP در حال اجرا است"
else
    echo "❌ XAMPP اجرا نمی‌شود"
    exit 1
fi

# تست 2: دیتابیس
echo "2️⃣ بررسی دیتابیس..."
if mysql -h localhost -P 3307 -u root -pMojtab@123 -e "USE datasave; SELECT 1;" &> /dev/null; then
    echo "✅ اتصال دیتابیس موفق"
else
    echo "❌ مشکل در اتصال دیتابیس"
    exit 1
fi

# تست 3: Flutter
echo "3️⃣ بررسی Flutter..."
if flutter doctor --machine | jq -r '.[] | select(.category=="FlutterValidator") | .status' | grep -q "installed"; then
    echo "✅ Flutter نصب است"
else
    echo "❌ مشکل در Flutter"
    exit 1
fi

# تست 4: API Backend
echo "4️⃣ بررسی API Backend..."
if curl -s "http://localhost/datasave/backend/api/settings/get.php" | jq -e '.success' &> /dev/null; then
    echo "✅ API Backend فعال است"
else
    echo "❌ مشکل در API Backend"
    exit 1
fi

echo "🎉 همه تست‌ها موفق! محیط توسعه آماده است."
```

---

## 🔥 عیب‌یابی مشکلات رایج - Common Issues

### مشکل 1: XAMPP اجرا نمی‌شود
```bash
# علت: Port های اشغال شده
sudo lsof -i :80 -i :443 -i :3307

# حل: متوقف کردن سرویس‌های تداخلی
sudo killall httpd
sudo brew services stop mysql

# یا تغییر port در XAMPP
# Edit: /Applications/XAMPP/xamppfiles/etc/httpd.conf
# Listen 8080 بجای Listen 80
```

### مشکل 2: اتصال دیتابیس
```bash
# علت: رمز عبور اشتباه
# حل: ریست کردن رمز MySQL
sudo /Applications/XAMPP/xamppfiles/xampp security

# یا manual تنظیم
mysql -h localhost -P 3307 -u root
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('Mojtab@123');
FLUSH PRIVILEGES;
```

### مشکل 3: Flutter web اجرا نمی‌شود
```bash
# علت: web support فعال نیست
flutter config --enable-web

# بررسی devices
flutter devices

# مشکل Chrome
flutter run -d web-server --web-port=8085
```

### مشکل 4: CORS Error
```apache
# اضافه کردن به .htaccess در backend
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
```

### مشکل 5: Persian text نمایش نمی‌دهد
```sql
-- بررسی charset
SHOW VARIABLES LIKE 'character_set%';

-- تنظیم مجدد
ALTER DATABASE datasave CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;
```

---

## 📚 منابع و مراجع - Resources

### مستندات رسمی
- [Flutter Documentation](https://docs.flutter.dev/)
- [XAMPP Documentation](https://www.apachefriends.org/docs/)
- [PHP Manual](https://www.php.net/manual/en/)
- [MySQL 8.0 Reference](https://dev.mysql.com/doc/refman/8.0/en/)

### ابزارها و لینک‌ها
```yaml
Downloads:
  - Flutter SDK: https://flutter.dev/docs/get-started/install
  - XAMPP: https://www.apachefriends.org/download.html
  - VS Code: https://code.visualstudio.com/
  - Git: https://git-scm.com/downloads

Useful Links:
  - Flutter DevTools: https://docs.flutter.dev/development/tools/devtools
  - PHP Debug Bar: http://phpdebugbar.com/
  - Persian Web Tools: https://github.com/Persian-Web-Tools

Community:
  - Flutter Community: https://flutter.dev/community
  - Persian Developers: https://github.com/Persian-Developers
```

### Scripts خودکارسازی
```bash
# ایجاد script startup
#!/bin/bash
# فایل: start_datasave_dev.sh
echo "🚀 راه‌اندازی محیط توسعه DataSave..."

# شروع XAMPP
sudo /Applications/XAMPP/xamppfiles/xampp start

# انتظار 5 ثانیه برای بارگذاری کامل
sleep 5

# اجرای Flutter
cd /Applications/XAMPP/xamppfiles/htdocs/datasave
flutter run -d chrome --web-port=8085

echo "✅ محیط توسعه آماده است!"
```

---

## ⚠️ Important Notes

### نکات امنیتی
- همیشه رمزهای پیچیده استفاده کنید
- XAMPP را فقط برای development استفاده کنید
- فایل‌های .env را به Git اضافه نکنید
- دسترسی‌های MySQL را محدود کنید

### Performance Tips
- SSD برای سرعت بیشتر استفاده کنید
- RAM کافی (16GB+) تخصیص دهید
- Antivirus را برای پوشه پروژه disable کنید
- Background processes غیرضروری را ببندید

### Backup & Recovery
- پشتیبان‌گیری منظم از دیتابیس
- استفاده از Git برای version control
- Snapshot از محیط کاری
- مستندسازی تغییرات مهم

---

## 🔄 Related Documentation
- [Project Structure](../01-Architecture/project-structure.md)
- [Code Standards](code-standards.md)
- [Testing Strategy](testing-strategy.md)
- [Troubleshooting Guide](../99-Quick-Reference/troubleshooting-guide.md)
- [Database Integration](../02-Backend-APIs/database-integration.md)

---
*Last updated: 2025-09-01*  
*File: docs/07-Development-Workflow/development-environment.md*