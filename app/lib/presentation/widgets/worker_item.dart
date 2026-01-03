import 'package:flutter/material.dart';
import '../../core/data/mock_data.dart';
import '../../core/theme/app_theme.dart';

class WorkerItem extends StatelessWidget {
  final Worker worker;
  final bool isDashboardMode; // Compact mode for dashboard

  const WorkerItem({
    super.key,
    required this.worker,
    this.isDashboardMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isDashboardMode) {
      // Dashboard compact view
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${worker.role} • ${worker.location}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-\$${(worker.balance * 0.8).toStringAsFixed(2)}', // Mock deduction
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '10m ago',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Full List Item View
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  worker.role,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMutedDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${worker.balance.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: worker.isLowBalance ? AppColors.error : AppColors.primary,
                  fontFamily: 'Manrope', // Monospace if possible, but Manrope is fine
                ),
              ),
              if (worker.isLowBalance)
                Text(
                  'LOW BALANCE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                )
              else
                 Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                 )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasImage = worker.avatarUrl.isNotEmpty;
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasImage ? Colors.grey.shade200 : AppColors.primary,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(worker.avatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !hasImage
              ? Center(
                  child: Text(
                    worker.name.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        if (worker.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceDark,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
