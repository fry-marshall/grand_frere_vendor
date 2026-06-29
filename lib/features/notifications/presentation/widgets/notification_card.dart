import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});
  final AppNotification notification;

  IconData get _icon {
    switch (notification.type) {
      case 'ORDER_VALIDATED':
        return Icons.check_circle_outline_rounded;
      case 'ORDER_COMPLETED':
        return Icons.done_all_rounded;
      case 'ORDER_CANCELLED':
        return Icons.cancel_outlined;
      case 'ORDER_EXPIRED':
        return Icons.schedule_rounded;
      case 'WITHDRAWAL_SUCCESS':
        return Icons.arrow_downward_rounded;
      case 'WITHDRAWAL_FAILED':
        return Icons.error_outline_rounded;
      case 'VENDOR_APPROVED':
        return Icons.verified_outlined;
      case 'VENDOR_REJECTED':
        return Icons.block_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'ORDER_VALIDATED':
      case 'ORDER_COMPLETED':
      case 'WITHDRAWAL_SUCCESS':
      case 'VENDOR_APPROVED':
        return AppColors.success;
      case 'ORDER_CANCELLED':
      case 'ORDER_EXPIRED':
      case 'WITHDRAWAL_FAILED':
      case 'VENDOR_REJECTED':
        return AppColors.dangerText;
      default:
        return AppColors.violet;
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationsCubit>().markRead(notification.id);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.xs),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.white : AppColors.goldSoft,
          borderRadius: AppRadius.md,
          border: notification.isRead
              ? null
              : Border.all(color: AppColors.gold.withAlpha(60)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withAlpha(20),
                borderRadius: AppRadius.sm,
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.ink,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.micro),
                  Text(
                    notification.body,
                    style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                  ),
                  SizedBox(height: AppSpacing.micro),
                  Text(
                    _timeAgo(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mute,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
