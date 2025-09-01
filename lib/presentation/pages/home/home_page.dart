import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataSave - فرم‌ساز هوشمند'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // آیکون اصلی داشبورد
            Icon(
              Icons.dashboard,
              size: 80,
              color: Color(0xFF2196F3),
            ),
            SizedBox(height: 24),
            
            // عنوان خوش‌آمدگویی
            Text(
              'به DataSave خوش آمدید',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 16),
            
            // توضیحات برنامه
            Text(
              'پلتفرم هوشمند ایجاد و مدیریت فرم‌ها',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 40),
            
            // کارت ویژگی‌های اصلی
            Card(
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // ایجاد فرم جدید
                    ListTile(
                      leading: Icon(Icons.create, color: Color(0xFF2196F3)),
                      title: Text('ایجاد فرم جدید', textDirection: TextDirection.rtl),
                      subtitle: Text('طراحی فرم‌های کاستوم', textDirection: TextDirection.rtl),
                    ),
                    Divider(),
                    
                    // مدیریت فرم‌ها
                    ListTile(
                      leading: Icon(Icons.list, color: Color(0xFF2196F3)),
                      title: Text('مدیریت فرم‌ها', textDirection: TextDirection.rtl),
                      subtitle: Text('مشاهده و ویرایش فرم‌های موجود', textDirection: TextDirection.rtl),
                    ),
                    Divider(),
                    
                    // گزارش‌گیری
                    ListTile(
                      leading: Icon(Icons.analytics, color: Color(0xFF2196F3)),
                      title: Text('گزارش‌گیری', textDirection: TextDirection.rtl),
                      subtitle: Text('آنالیز داده‌های جمع‌آوری شده', textDirection: TextDirection.rtl),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // دکمه شناور برای افزودن فرم
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فرم‌ساز در حال توسعه است...', textDirection: TextDirection.rtl),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
