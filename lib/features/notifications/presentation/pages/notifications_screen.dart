import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.maroon,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
        ),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (ctx, state) {
              if (state is! NotificationsLoaded || state.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () => ctx.read<NotificationsCubit>().markAllRead(),
                child: Text(
                  'Tout lire',
                  style: AppTextStyles.buttonSmall
                      .copyWith(color: AppColors.maroon),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (ctx, state) {
          if (state is NotificationsInitial || state is NotificationsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          if (state is NotificationsError) {
            return _ErrorState(
              message: state.message,
              onRetry: () => ctx.read<NotificationsCubit>().refresh(),
            );
          }

          final loaded = state as NotificationsLoaded;

          if (loaded.notifications.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () => ctx.read<NotificationsCubit>().refresh(),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              itemCount: loaded.notifications.length,
              itemBuilder: (_, i) =>
                  NotificationCard(notification: loaded.notifications[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.line,
            size: 52,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Aucune notification',
            style: AppTextStyles.body.copyWith(color: AppColors.mute),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.line, size: 48),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonSmallV,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Réessayer',
                  style:
                      AppTextStyles.buttonSmall.copyWith(color: AppColors.brown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
