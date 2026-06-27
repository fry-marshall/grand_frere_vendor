import 'package:flutter/material.dart';

abstract class AppShadows {
  static const xs = [
    BoxShadow(color: Color(0x0F5B1E0F), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const sm = [
    BoxShadow(color: Color(0x145B1E0F), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const md = [
    BoxShadow(color: Color(0x1A5B1E0F), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static const lg = [
    BoxShadow(color: Color(0x245B1E0F), blurRadius: 36, offset: Offset(0, 14)),
  ];

  static const button = [
    BoxShadow(color: Color(0x265B1E0F), blurRadius: 0, offset: Offset(0, 4)),
  ];

  static const focusGold = [
    BoxShadow(color: Color(0x38E8B54A), blurRadius: 0, spreadRadius: 3),
  ];

  static const focusDanger = [
    BoxShadow(color: Color(0x26C43B2B), blurRadius: 0, spreadRadius: 3),
  ];

  static const violetCard = [
    BoxShadow(color: Color(0x667A52C2), blurRadius: 28, offset: Offset(0, 12)),
  ];
}
