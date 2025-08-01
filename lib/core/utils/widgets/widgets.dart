import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';

class Widgets {
  static customSnackbar(
    BuildContext context,
    Color backgroundColor,
    String text,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          text,
          style: AppTextStyle(fontSize: 14.sp, color: AppColors.white),
        ),
      ),
    );
  }
}
