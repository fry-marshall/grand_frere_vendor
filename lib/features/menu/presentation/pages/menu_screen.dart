import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/vendor_item.dart';
import '../cubit/items_cubit.dart';
import '../cubit/items_state.dart';
import '../widgets/item_card.dart';
import '../widgets/item_form_sheet.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _pickAndUpload(BuildContext context, VendorItem item) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (file == null) return;
    if (!context.mounted) return;
    await context.read<ItemsCubit>().uploadImage(item.id, file.path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemsCubit, ItemsState>(
      listener: (ctx, state) {
        if (state is ItemsActionError) {
          AppToast.show(ctx, state.message, isError: true);
          ctx.read<ItemsCubit>().dismissActionError();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(
          backgroundColor: AppColors.paper,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Mon menu',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.maroon, size: 26),
              onPressed: () => ItemFormSheet.show(context),
            ),
          ],
        ),
        body: BlocBuilder<ItemsCubit, ItemsState>(
          builder: (ctx, state) {
            if (state is ItemsInitial || state is ItemsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            if (state is ItemsError) {
              return _ErrorState(
                message: state.message,
                onRetry: () => ctx.read<ItemsCubit>().refresh(),
              );
            }

            final loaded = state is ItemsLoaded
                ? state
                : (state as ItemsActionError).previous;

            if (loaded.items.isEmpty) {
              return _EmptyState(
                onAdd: () => ItemFormSheet.show(context),
              );
            }

            return RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () => ctx.read<ItemsCubit>().refresh(),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  if (loaded.active.isNotEmpty) ...[
                    _SectionLabel(
                      label: 'Disponibles',
                      count: loaded.active.length,
                      color: AppColors.success,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    ...loaded.active.map(
                      (item) => ItemCard(
                        item: item,
                        isActing: loaded.actionItemId == item.id,
                        onEdit: () => ItemFormSheet.show(context, item: item),
                        onImageTap: () => _pickAndUpload(context, item),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                  ],
                  if (loaded.inactive.isNotEmpty) ...[
                    _SectionLabel(
                      label: 'Désactivés',
                      count: loaded.inactive.length,
                      color: AppColors.mute,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    ...loaded.inactive.map(
                      (item) => ItemCard(
                        item: item,
                        isActing: loaded.actionItemId == item.id,
                        onEdit: () => ItemFormSheet.show(context, item: item),
                        onImageTap: () => _pickAndUpload(context, item),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: AppTextStyles.label.copyWith(color: AppColors.mute),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant_menu_outlined,
              color: AppColors.line,
              size: 52,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Votre menu est vide',
              style: AppTextStyles.h3.copyWith(color: AppColors.ink),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Ajoutez vos premiers articles pour commencer à recevoir des commandes.',
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonSmallV,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDeep],
                  ),
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Ajouter un article',
                      style: AppTextStyles.buttonSmall
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                  style: AppTextStyles.buttonSmall.copyWith(color: AppColors.brown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
