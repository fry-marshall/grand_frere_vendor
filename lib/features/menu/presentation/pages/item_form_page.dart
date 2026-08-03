import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vendor_item.dart';
import '../cubit/items_cubit.dart';
import '../cubit/items_state.dart';

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({super.key, this.item});

  final VendorItem? item;

  static Future<void> push(BuildContext context, {VendorItem? item}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ItemsCubit>(),
          child: ItemFormPage(item: item),
        ),
      ),
    );
  }

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _description;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  XFile? _pickedImage;

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

  Future<void> _pickImage() async {
    final source = await _pickImageSource();
    if (source == null) return;
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (file == null) return;
    if (!mounted) return;
    setState(() => _pickedImage = file);
  }

  Future<ImageSource?> _pickImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: AppRadius.pill,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.maroon),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.maroon),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.gallery),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final cubit = context.read<ItemsCubit>();
    final name = _name.text.trim();
    final price = int.parse(_price.text.trim());
    final description = _description.text.trim();

    if (isEdit) {
      await cubit.updateItem(
        widget.item!.id,
        name: name,
        price: price,
        description: description.isNotEmpty
            ? description
            : null,
        status: widget.item?.status
      );
      if (_pickedImage != null && cubit.state is! ItemsActionError) {
        await cubit.uploadImage(widget.item!.id, _pickedImage!.path);
      }
    } else {
      await cubit.createItem(
        name: name,
        price: price,
        description: description.isNotEmpty ? description : null,
        imagePath: _pickedImage?.path,
      );
    }

    if (mounted && cubit.state is! ItemsActionError) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.ink, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            isEdit ? 'Modifier l\'article' : 'Nouvel article',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              _ImagePicker(
                currentUrl: widget.item?.imageUrl,
                pickedFile: _pickedImage,
                onTap: _saving ? null : _pickImage,
                hasPendingImage:
                    _pickedImage == null && (widget.item?.hasPendingImage ?? false),
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
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: _saving ? null : _submit,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.buttonVertical),
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
            ],
          ),
        ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.currentUrl,
    required this.pickedFile,
    required this.onTap,
    this.hasPendingImage = false,
  });

  final String? currentUrl;
  final XFile? pickedFile;
  final VoidCallback? onTap;
  final bool hasPendingImage;

  @override
  Widget build(BuildContext context) {
    final hasImage = currentUrl != null || pickedFile != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.xs,
          image: hasImage
              ? DecorationImage(
                  image: currentUrl != null && pickedFile == null
                      ? NetworkImage(currentUrl!) as ImageProvider
                      : FileImage(File(pickedFile!.path)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (!hasImage)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.mute,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajouter une photo',
                    style: AppTextStyles.body.copyWith(color: AppColors.mute),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Touchez pour prendre une photo ou en choisir une',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.line),
                  ),
                ],
              ),
            if (hasImage)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: AppRadius.pill,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Changer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (hasPendingImage)
              Positioned(
                left: 10,
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: AppRadius.pill,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Nouvelle photo en attente de validation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.ink)),
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
            fillColor: AppColors.white,
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
