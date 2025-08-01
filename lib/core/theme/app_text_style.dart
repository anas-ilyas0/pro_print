import 'package:flutter/material.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/theme/app_colors.dart';

class AppTextStyle extends TextStyle {
  const AppTextStyle({
    required double super.fontSize,
    double? height,
    double? letterSpacing,
    super.fontWeight,
    super.fontFamily = AppConstants.poppins,
    super.fontStyle,
    super.color = AppColors.white,
    super.decoration = TextDecoration.none
  }) : super(
          height: height == null ? null : height / fontSize,
          letterSpacing:
              letterSpacing == null ? null : letterSpacing / fontSize,
        );
}
