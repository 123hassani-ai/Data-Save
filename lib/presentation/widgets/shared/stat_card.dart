import 'package:flutter/material.dart';

/// کارت نمایش آمار - برای نمایش آمار در داشبورد
/// StatCard for displaying dashboard statistics
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.1),
                cardColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // آیکون با رنگ
              Icon(
                icon,
                size: 32,
                color: cardColor,
              ),
              const SizedBox(height: 8),
              // عنوان
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // مقدار
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cardColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// کارت وضعیت سیستم - برای نمایش وضعیت صحت سیستم
/// System health card for monitoring system status
class SystemHealthCard extends StatelessWidget {
  final bool backendStatus;
  final bool databaseStatus;
  final String? responseTime;

  const SystemHealthCard({
    super.key,
    required this.backendStatus,
    required this.databaseStatus,
    this.responseTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overallHealth = backendStatus && databaseStatus;
    final healthColor = overallHealth ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان کارت
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: healthColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'وضعیت سلامت سیستم',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // نمایش وضعیت‌های مختلف
            Row(
              children: [
                Expanded(
                  child: _HealthIndicator(
                    title: 'Backend',
                    isHealthy: backendStatus,
                    icon: Icons.dns,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HealthIndicator(
                    title: 'Database',
                    isHealthy: databaseStatus,
                    icon: Icons.storage,
                  ),
                ),
              ],
            ),
            if (responseTime != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'زمان پاسخ: $responseTime',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// نشانگر سلامت - برای نمایش وضعیت هر جزء
/// Health indicator for individual components
class _HealthIndicator extends StatelessWidget {
  final String title;
  final bool isHealthy;
  final IconData icon;

  const _HealthIndicator({
    required this.title,
    required this.isHealthy,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = isHealthy ? Colors.green : Colors.red;
    final statusText = isHealthy ? 'فعال' : 'غیرفعال';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
