import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/providers/dashboard_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

Future<void> saveLoginState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 60.sp, color: AppColors.white),
                      SizedBox(height: 10.h),
                      Text("Welcome Back",
                          style: AppTextStyle(
                              fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      Text("Login to continue",
                          style: AppTextStyle(
                            fontSize: 14.sp,
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                TextFormField(
                  controller: _emailCtrl,
                  style: AppTextStyle(fontSize: 14.sp),
                  keyboardType: TextInputType.emailAddress,
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
                  decoration: InputDecoration(
                    hintText: "example@email.com",
                    hintStyle:
                        AppTextStyle(fontSize: 12.sp, color: AppColors.white),
                    labelText: 'Email',
                    labelStyle: AppTextStyle(fontSize: 12.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    filled: true,
                    fillColor: AppColors.scaffoldBackgroundColor
                        .withValues(alpha: 0.1),
                  ),
                ),
                SizedBox(height: 15.h),
                TextFormField(
                  controller: _passwordCtrl,
                  style: AppTextStyle(fontSize: 14.sp),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Minimum 6 characters required';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      hintText: "••••••••",
                      labelText: 'Password',
                      hintStyle:
                          AppTextStyle(fontSize: 12.sp, color: AppColors.white),
                      labelStyle: AppTextStyle(fontSize: 12.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.white,
                        ),
                        onPressed: () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                      ),
                      filled: true,
                      fillColor: AppColors.scaffoldBackgroundColor
                          .withValues(alpha: 0.1)),
                ),
                SizedBox(height: 10.h),
                // Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppConstants.forgotPass);
                    },
                    child: Text("Forgot Password?",
                        style: AppTextStyle(
                          fontSize: 13.sp,
                        )),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      side: BorderSide(color: AppColors.white),
                      tristate: false,
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppColors.blueGrey.withValues(alpha: 0.6),
                    ),
                    Text("Remember me", style: AppTextStyle(fontSize: 13.sp)),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(12.r),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          try {
                            final response = await Supabase.instance.client.auth
                                .signInWithPassword(
                              email: _emailCtrl.text.trim(),
                              password: _passwordCtrl.text,
                            );
                            if (response.user != null) {
                              if (context.mounted) {
                                Widgets.customSnackbar(context,
                                    AppColors.blueGrey, 'Login Successful!');
                              }
                              if (rememberMe) {
                                await saveLoginState();
                              }
                              if (context.mounted) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.pushNamed(
                                      context, AppConstants.dashboard);
                                });
                              }
                              dashboardProvider.setSelectedIndex(0);
                            } else {
                              if (context.mounted) {
                                Widgets.customSnackbar(context, AppColors.red,
                                    'Invalid credentials');
                              }
                            }
                          } on AuthException catch (e) {
                            if (context.mounted) {
                              Widgets.customSnackbar(
                                  context, AppColors.red, e.message);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Widgets.customSnackbar(context, AppColors.red,
                                  'Login failed: ${e.toString()}');
                            }
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },

                      // onPressed: () async {
                      //   if (_formKey.currentState!.validate()) {
                      //     setState(() => _isLoading = true);
                      //     try {
                      //       final userCredential = await FirebaseAuth.instance
                      //           .signInWithEmailAndPassword(
                      //         email: _emailCtrl.text.trim(),
                      //         password: _passwordCtrl.text,
                      //       );
                      //       Widgets.customSnackbar(
                      //           context, AppColors.blueGrey.withValues(alpha: 0.6), 'Login Successful');
                      //       if (rememberMe) {
                      //         await saveLoginState();
                      //       }
                      //       Navigator.pushNamed(
                      //           context, AppConstants.dashboard);
                      //       dashboardProvider.setSelectedIndex(0);
                      //     } on FirebaseAuthException catch (e) {
                      //       String message = 'Login failed';
                      //       if (e.code == 'user-not-found') {
                      //         message = 'User does not exist';
                      //       } else if (e.code == 'wrong-password') {
                      //         message = 'Incorrect password';
                      //       } else if (e.code == 'invalid-email') {
                      //         message = 'Invalid email address';
                      //       }
                      //       Widgets.customSnackbar(
                      //           context, AppColors.red, message);
                      //     } catch (e) {
                      //       Widgets.customSnackbar(context, AppColors.red,
                      //           'Something went wrong: ${e.toString()}');
                      //     } finally {
                      //       setState(() => _isLoading = false);
                      //     }
                      //   }
                      // },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.blueGrey.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Login",
                              style: AppTextStyle(
                                fontSize: 16.sp,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppConstants.signUp);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyle(fontSize: 13.sp),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: AppTextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
