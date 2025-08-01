import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (newPassword != confirmPassword) {
      Widgets.customSnackbar(context, AppColors.red, "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth
          .verifyOTP(token: token, type: OtpType.recovery, email: email);

      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: newPassword));
      if (mounted) {
        Widgets.customSnackbar(context, AppColors.blueGrey,
            "Password reset successfully! Please login again.");
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        Widgets.customSnackbar(context, AppColors.red, e.message);
      }
    } catch (e) {
      if (mounted) {
        Widgets.customSnackbar(context, AppColors.red, e.toString());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Reset Your Password",
                  style: AppTextStyle(
                      fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(val)) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.h),
              TextFormField(
                controller: _tokenCtrl,
                keyboardType: TextInputType.text,
                style: AppTextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Reset Token',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15.h),
              TextFormField(
                controller: _newPasswordCtrl,
                obscureText: true,
                style: AppTextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.length < 6
                    ? 'Minimum 6 characters'
                    : null,
              ),
              SizedBox(height: 15.h),
              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: true,
                style: AppTextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.length < 6
                    ? 'Minimum 6 characters'
                    : null,
              ),
              SizedBox(height: 25.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueGrey.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: AppColors.white)
                      : Text("Reset Password",
                          style: AppTextStyle(
                              fontSize: 16.sp,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
