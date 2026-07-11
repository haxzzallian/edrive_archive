import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get h1 => TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5);
  static TextStyle get h2 => TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3);
  static TextStyle get h3 => TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get h4 => TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle get body1 => TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get body2 => TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get caption => TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w400, color: AppColors.textHint);

  static TextStyle get label  => TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get button => TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.2);

  static TextStyle get price  => TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
}
