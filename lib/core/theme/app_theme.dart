import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';

class AppTheme {
  static final theme = ThemeData(
    fontFamily: AppConstants.poppins,
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
    splashFactory: InkRipple.splashFactory,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor:
            WidgetStateProperty.all(AppColors.black.withValues(alpha: 0.1)),
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.white),
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.scaffoldBackgroundColor,
      titleSpacing: -5,
      titleTextStyle: AppTextStyle(
        fontSize: 18.sp,
        color: AppColors.white,
        fontWeight: FontWeight.w500,
        fontFamily: AppConstants.poppins,
      ),
      iconTheme: IconThemeData(color: AppColors.white, size: 18.sp),
      actionsIconTheme: IconThemeData(color: AppColors.white, size: 21.sp),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppColors.white),
      displayMedium: TextStyle(color: AppColors.white),
      displaySmall: TextStyle(color: AppColors.white),
      headlineLarge: TextStyle(color: AppColors.white),
      headlineMedium: TextStyle(color: AppColors.white),
      headlineSmall: TextStyle(color: AppColors.white),
      titleLarge: TextStyle(color: AppColors.white),
      titleMedium: TextStyle(color: AppColors.white),
      titleSmall: TextStyle(color: AppColors.white),
      bodyLarge: TextStyle(color: AppColors.white),
      bodyMedium: TextStyle(color: AppColors.white),
      bodySmall: TextStyle(color: AppColors.white),
      labelLarge: TextStyle(color: AppColors.white),
      labelMedium: TextStyle(color: AppColors.white),
      labelSmall: TextStyle(color: AppColors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.white, width: 2),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.white.withValues(alpha: 0.6),
      selectionHandleColor: AppColors.white.withValues(alpha: 0.6),
      selectionColor:
          AppColors.white.withValues(alpha: 0.6).withValues(alpha: 0.3),
    ),
  );
}
