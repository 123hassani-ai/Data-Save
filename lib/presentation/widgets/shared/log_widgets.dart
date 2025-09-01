import 'package:flutter/material.dart';

/// کارت آمار لاگ - برای نمایش آمار لاگ‌ها
/// Log statistics card for analytics display
class LogStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const LogStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  count.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// کارت آیتم لاگ - برای نمایش هر ورودی لاگ
/// Log item card for individual log entry display
class LogItemCard extends StatelessWidget {
  final Map<String, dynamic> logEntry;
  final VoidCallback? onTap;

  const LogItemCard({
    super.key,
    required this.logEntry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logLevel = logEntry['log_level']?.toString().toUpperCase() ?? 'INFO';
    final message = logEntry['log_message']?.toString() ?? 'پیام خالی';
    final category = logEntry['log_category']?.toString() ?? 'عمومی';
    final createdAt = logEntry['created_at']?.toString() ?? '';
    
    // تعیین رنگ بر اساس سطح لاگ
    Color levelColor;
    IconData levelIcon;
    
    switch (logLevel) {
      case 'ERROR':
        levelColor = Colors.red;
        levelIcon = Icons.error;
        break;
      case 'WARNING':
        levelColor = Colors.orange;
        levelIcon = Icons.warning;
        break;
      case 'INFO':
        levelColor = Colors.blue;
        levelIcon = Icons.info;
        break;
      case 'DEBUG':
        levelColor = Colors.purple;
        levelIcon = Icons.bug_report;
        break;
      default:
        levelColor = Colors.grey;
        levelIcon = Icons.circle;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(
              right: BorderSide(
                color: levelColor,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ردیف اول: سطح لاگ و زمان
              Row(
                children: [
                  Icon(
                    levelIcon,
                    color: levelColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      logLevel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // پیام لاگ
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // اطلاعات اضافی اگر موجود باشد
              if (logEntry['ip_address'] != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'IP: ${logEntry['ip_address']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// فرمت زمان برای نمایش
  /// Format datetime for display
  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'هم‌اکنون';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} دقیقه پیش';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} ساعت پیش';
      } else {
        return '${difference.inDays} روز پیش';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
}

/// کارت فعالیت‌های اخیر - برای نمایش آخرین لاگ‌ها در داشبورد
/// Recent activity card for dashboard display
class RecentLogsCard extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final VoidCallback? onViewAll;

  const RecentLogsCard({
    super.key,
    required this.logs,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان کارت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'فعالیت‌های اخیر',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('مشاهده همه'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // لیست لاگ‌ها
            if (logs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'هیچ فعالیتی یافت نشد',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.take(5).length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _RecentLogItem(log: log);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// آیتم لاگ در فعالیت‌های اخیر
/// Recent log item for compact display
class _RecentLogItem extends StatelessWidget {
  final Map<String, dynamic> log;

  const _RecentLogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logLevel = log['log_level']?.toString().toUpperCase() ?? 'INFO';
    final message = log['log_message']?.toString() ?? 'پیام خالی';
    final createdAt = log['created_at']?.toString() ?? '';

    Color levelColor;
    switch (logLevel) {
      case 'ERROR':
        levelColor = Colors.red;
        break;
      case 'WARNING':
        levelColor = Colors.orange;
        break;
      case 'INFO':
        levelColor = Colors.blue;
        break;
      default:
        levelColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // نقطه رنگی برای سطح لاگ
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: levelColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // محتوای لاگ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'هم‌اکنون';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} دقیقه پیش';
      } else {
        return '${difference.inHours} ساعت پیش';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
}
