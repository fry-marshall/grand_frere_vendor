import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vendor_item.dart';
import '../cubit/items_cubit.dart';
import '../cubit/items_state.dart';

class ItemFormSheet extends StatefulWidget {
  const ItemFormSheet({super.key, this.item});

  final VendorItem? item;

  static Future<void> show(BuildContext context, {VendorItem? item}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ItemsCubit>(),
        child: ItemFormSheet(item: item),
      ),
    );
  }

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _description;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _price = TextEditingController(
      text: widget.item != null ? widget.item!.price.toString() : '',
    );
    _description = TextEditingController(text: widget.item?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final name = _name.text.trim();
    final price = int.parse(_price.text.trim());
    final description = _description.text.trim();

    if (isEdit) {
      await context.read<ItemsCubit>().updateItem(
            widget.item!.id,
            name: name != widget.item!.name ? name : null,
            price: price != widget.item!.price ? price : null,
            description: description.isNotEmpty
                ? (description != widget.item!.description ? description : null)
                : null,
          );
    } else {
      await context.read<ItemsCubit>().createItem(
            name: name,
            price: price,
            description: description.isNotEmpty ? description : null,
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return BlocListener<ItemsCubit, ItemsState>(
      listener: (_, state) {
        if (state is ItemsActionError && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                isEdit ? 'Modifier l\'article' : 'Nouvel article',
                style: AppTextStyles.h2.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: AppSpacing.lg),
              _Field(
                controller: _name,
                label: 'Nom',
                hint: 'Riz sauce tomate…',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _price,
                label: 'Prix (FCFA)',
                hint: '1 500',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1) return 'Prix invalide';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _description,
                label: 'Description (optionnel)',
                hint: 'Riz blanc avec sauce graine…',
                maxLines: 2,
              ),
              SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: _saving ? null : _submit,
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                  decoration: BoxDecoration(
                    gradient: _saving
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.gold, AppColors.goldDeep],
                          ),
                    color: _saving ? AppColors.line : null,
                    borderRadius: AppRadius.pill,
                    boxShadow: _saving ? null : AppShadows.md,
                  ),
                  alignment: Alignment.center,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.gold,
                          ),
                        )
                      : Text(
                          isEdit ? 'Enregistrer' : 'Ajouter',
                          style: AppTextStyles.buttonLabel
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.mute),
            filled: true,
            fillColor: AppColors.paper,
            border: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.dangerText),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.inputVertical,
            ),
          ),
        ),
      ],
    );
  }
}
