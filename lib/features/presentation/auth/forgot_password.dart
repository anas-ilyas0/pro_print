import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> sendResetEmail() async {
    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(_emailCtrl.text.trim());
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            title: Icon(Icons.mark_email_read_rounded,
                size: 60.sp, color: AppColors.blueGrey.withValues(alpha: 0.6)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Check your email",
                    style: AppTextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text(
                  "We’ve sent a reset token to your email. Please check your email inbox and use the token to reset the password",
                  textAlign: TextAlign.center,
                  style: AppTextStyle(
                      fontSize: 14.sp,
                      color: AppColors.blueGrey.withValues(alpha: 0.6)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK',
                    style: AppTextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueGrey.withValues(alpha: 0.6))),
              )
            ],
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        Widgets.customSnackbar(context, AppColors.red, e.message);
      }
    } catch (e) {
      if (mounted) {
        Widgets.customSnackbar(
            context, AppColors.red, 'Unexpected error: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Future<void> sendResetEmail() async {
  //   setState(() => _isLoading = true);

  //   try {
  //     await FirebaseAuth.instance
  //         .sendPasswordResetEmail(email: _emailCtrl.text.trim());

  //     showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (_) => AlertDialog(
  //         backgroundColor: AppColors.white,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  //         title: Icon(Icons.mark_email_read_rounded,
  //             size: 60.sp, color: AppColors.blueGrey.withValues(alpha: 0.6)),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               "Check your email",
  //               style:
  //                   AppTextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 8.h),
  //             Text(
  //               "We’ve sent a password reset link to your email. Follow the instructions to reset your password.",
  //               textAlign: TextAlign.center,
  //               style: AppTextStyle(fontSize: 14.sp, color: AppColors.blueGrey.withValues(alpha: 0.6)),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               Navigator.pop(context);
  //             },
  //             child: Text('OK',
  //                 style: AppTextStyle(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: AppColors.blueGrey.withValues(alpha: 0.6))),
  //           )
  //         ],
  //       ),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     String msg = 'Something went wrong';
  //     if (e.code == 'user-not-found') {
  //       msg = 'No user found with this email';
  //     } else if (e.code == 'invalid-email') {
  //       msg = 'Invalid email address';
  //     }
  //     Widgets.customSnackbar(context, AppColors.red, msg);
  //   } catch (e) {
  //     Widgets.customSnackbar(
  //         context, AppColors.red, 'Unexpected error: ${e.toString()}');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(12.r),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blueGrey
                  .withValues(alpha: 0.6)
                  .withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text("Forgot Password?",
                      style: AppTextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  Text(
                    "Enter your registered email and we’ll send you a reset link.",
                    style: AppTextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: AppTextStyle(fontSize: 12.sp),
                      hintText: 'example@email.com',
                      hintStyle: AppTextStyle(
                        fontSize: 12.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      filled: true,
                      fillColor: AppColors.scaffoldBackgroundColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await sendResetEmail();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.blueGrey.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: AppColors.white)
                          : Text("Send Reset Link",
                              style: AppTextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
