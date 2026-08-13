import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/vendor_item.dart';
import '../cubit/items_cubit.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.isActing,
    required this.onEdit,
    required this.onImageTap,
  });

  final VendorItem item;
  final bool isActing;
  final VoidCallback onEdit;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.xs,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemImage(item: item, onTap: onImageTap, isActing: isActing),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: item.isActive
                                ? AppColors.ink
                                : AppColors.mute,
                          ),
                        ),
                      ),
                      if (isActing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.gold,
                          ),
                        )
                      else
                        _StatusToggle(item: item),
                    ],
                  ),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.micro),
                    Text(
                      item.description!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        '${formatXof(item.price)} FCFA',
                        style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
                      ),
                      const Spacer(),
                      _IconAction(
                        icon: Icons.edit_outlined,
                        color: AppColors.violet,
                        onTap: onEdit,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      _IconAction(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.dangerText,
                        onTap: () => _confirmDelete(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        title: Text(
          'Supprimer l\'article ?',
          style: AppTextStyles.h3.copyWith(color: AppColors.ink),
        ),
        content: Text(
          'Cette action est irréversible.',
          style: AppTextStyles.body.copyWith(color: AppColors.mute),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ItemsCubit>().deleteItem(item.id);
            },
            child: Text(
              'Supprimer',
              style: AppTextStyles.body.copyWith(color: AppColors.dangerText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({
    required this.item,
    required this.onTap,
    required this.isActing,
  });

  final VendorItem item;
  final VoidCallback onTap;
  final bool isActing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: AppRadius.sm,
          image: item.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(item.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: item.imageUrl == null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.gold,
                    size: 28,
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: AppRadius.pill,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: AppRadius.pill,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.item});
  final VendorItem item;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.75,
      alignment: Alignment.centerRight,
      child: Switch(
        value: item.isActive,
        activeThumbColor: AppColors.success,
        activeTrackColor: AppColors.successSurface,
        inactiveThumbColor: AppColors.mute,
        inactiveTrackColor: AppColors.line,
        onChanged: (_) => context.read<ItemsCubit>().toggleStatus(item),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
