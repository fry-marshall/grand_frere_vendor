import 'package:flutter/material.dart';

import '../config/app_env.dart';

class EnvBanner extends StatelessWidget {
  const EnvBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppEnv.current.isProduction) return child;
    return Banner(
      message: AppEnv.current.name.toUpperCase(),
      location: BannerLocation.topEnd,
      color: Colors.deepOrange,
      child: child,
    );
  }
}
