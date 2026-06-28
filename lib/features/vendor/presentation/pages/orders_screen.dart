import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Text(
          'Commandes — Sprint 3',
          style: AppTextStyles.body.copyWith(color: AppColors.mute),
        ),
      ),
    );
  }
}
