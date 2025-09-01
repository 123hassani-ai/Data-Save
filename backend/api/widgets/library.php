<?php
/**
 * API کتابخانه ویجت‌ها - Widget Library API
 * 
 * @version 5.2.0
 * @author DataSave Development Team  
 * @created 2025-09-01
 * @description دریافت کتابخانه ویجت‌ها برای Form Builder
 */

header('Content-Type: application/json; charset=utf-8');

// import اجزای مورد نیاز
require_once '../../config/cors.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';
require_once '../../classes/Database/FormWidget.php';

// بررسی method درخواست
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    ApiResponse::error('متد درخواست باید GET باشد', 405);
    exit;
}

try {
    $logger = new Logger();
    $widgetModel = new FormWidget();
    
    // دریافت پارامترهای فیلتر
    $category = $_GET['category'] ?? 'all';
    $active_only = filter_var($_GET['active_only'] ?? 'true', FILTER_VALIDATE_BOOLEAN);
    $sort_by = $_GET['sort_by'] ?? 'display_order'; // display_order, usage_count, persian_label
    $limit = max(1, min(100, (int)($_GET['limit'] ?? 50)));
    
    $logger->info('WIDGET_LIBRARY_API', 'درخواست دریافت کتابخانه ویجت‌ها', [
        'category' => $category,
        'active_only' => $active_only,
        'sort_by' => $sort_by,
        'limit' => $limit
    ]);
    
    // آماده‌سازی فیلترها
    $filters = [];
    
    if ($category !== 'all') {
        $filters['category'] = $category;
    }
    
    if ($active_only) {
        $filters['is_active'] = true;
    }
    
    // دریافت ویجت‌ها
    $widgets = $widgetModel->getWidgetLibrary($filters, $active_only);
    
    if (empty($widgets)) {
        $logger->warning('WIDGET_LIBRARY_API', 'هیچ ویجتی یافت نشد', [
            'filters' => $filters
        ]);
    }
    
    // گروه‌بندی ویجت‌ها بر اساس دسته‌بندی
    $categorizedWidgets = [];
    foreach ($widgets as $widget) {
        $widgetCategory = $widget['widget_category'] ?? 'basic';
        if (!isset($categorizedWidgets[$widgetCategory])) {
            $categorizedWidgets[$widgetCategory] = [];
        }
        $categorizedWidgets[$widgetCategory][] = $widget;
    }
    
    // آماده‌سازی پاسخ
    $responseData = [
        'widgets' => $widgets,
        'categorized_widgets' => $categorizedWidgets,
        'total_count' => count($widgets),
        'categories' => array_keys($categorizedWidgets),
        'filters_applied' => [
            'category' => $category,
            'active_only' => $active_only,
            'sort_by' => $sort_by
        ]
    ];
    
    $logger->info('WIDGET_LIBRARY_API', 'کتابخانه ویجت‌ها با موفقیت دریافت شد', [
        'total_widgets' => count($widgets),
        'categories' => array_keys($categorizedWidgets)
    ]);
    
    ApiResponse::success($responseData, 'کتابخانه ویجت‌ها دریافت شد');
    
} catch (Exception $e) {
    $logger = new Logger();
    $logger->error('WIDGET_LIBRARY_API', 'خطای سیستمی در دریافت کتابخانه ویجت‌ها', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
    
    ApiResponse::error('خطای سیستمی در دریافت کتابخانه ویجت‌ها', 500);
}
?>
