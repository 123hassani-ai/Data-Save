<?php
require_once 'config/cors.php';
?>
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DataSave Backend API</title>
    <style>
        body { font-family: Tahoma, Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; }
        .endpoint { background: #ecf0f1; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .method { font-weight: bold; color: #e74c3c; }
        .url { background: #34495e; color: white; padding: 5px 10px; border-radius: 3px; font-family: monospace; }
        .status { text-align: center; padding: 20px; background: #2ecc71; color: white; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 DataSave Backend API</h1>
        
        <div class="status">
            ✅ Backend API آماده و در حال اجراست
        </div>
        
        <h2>📋 لیست API Endpoints:</h2>
        
        <div class="endpoint">
            <div class="method">GET</div>
            <div class="url">/api/settings/get.php</div>
            <p>دریافت تمام تنظیمات سیستم</p>
        </div>
        
        <div class="endpoint">
            <div class="method">POST</div>
            <div class="url">/api/settings/update.php</div>
            <p>بروزرسانی تنظیمات (JSON: setting_key, setting_value)</p>
        </div>
        
        <div class="endpoint">
            <div class="method">GET</div>
            <div class="url">/api/settings/test.php</div>
            <p>تست اتصال دیتابیس</p>
        </div>
        
        <div class="endpoint">
            <div class="method">POST</div>
            <div class="url">/api/logs/create.php</div>
            <p>ثبت لاگ جدید (JSON: level, category, message, context)</p>
        </div>
        
        <div class="endpoint">
            <div class="method">GET</div>
            <div class="url">/api/logs/list.php?limit=20</div>
            <p>دریافت لیست لاگ‌ها</p>
        </div>
        
        <div class="endpoint">
            <div class="method">POST</div>
            <div class="url">/api/logs/clear.php</div>
            <p>پاکسازی لاگ‌های قدیمی</p>
        </div>
        
        <div class="endpoint">
            <div class="method">GET</div>
            <div class="url">/api/system/status.php</div>
            <p>وضعیت سیستم و دیتابیس</p>
        </div>
        
        <div class="endpoint">
            <div class="method">GET</div>
            <div class="url">/api/system/info.php</div>
            <p>اطلاعات تفصیلی سرور PHP</p>
        </div>
        
        <hr>
        <p style="text-align: center; color: #7f8c8d;">
            DataSave Backend API v1.0 | PHP <?= phpversion() ?>
        </p>
    </div>
</body>
</html>
