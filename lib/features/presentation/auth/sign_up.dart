import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _companyNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Create Account",
                  style: AppTextStyle(
                      fontSize: 24.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Text("Sign up to get started",
                  style: AppTextStyle(fontSize: 14.sp)),
              SizedBox(height: 30.h),
              _buildTextField(label: "Name", controller: _nameCtrl),
              SizedBox(height: 15.h),
              _buildTextField(label: "Surname", controller: _surnameCtrl),
              SizedBox(height: 15.h),
              _buildTextField(
                label: "Company Name",
                controller: _companyNameCtrl,
              ),
              SizedBox(height: 15.h),
              _buildTextField(
                label: "Email",
                controller: _emailCtrl,
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
              ),
              SizedBox(height: 15.h),
              _buildTextField(
                label: "Phone Number",
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 15.h),
              _buildTextField(
                label: "Address",
                controller: _addressCtrl,
              ),
              SizedBox(height: 15.h),
              _buildPasswordField(
                label: "Password",
                controller: _passwordCtrl,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              SizedBox(height: 15.h),
              _buildPasswordField(
                label: "Confirm Password",
                controller: _confirmPasswordCtrl,
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm Password is required';
                  } else if (value != _passwordCtrl.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.all(8.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        try {
                          final response =
                              await Supabase.instance.client.auth.signUp(
                            email: _emailCtrl.text.trim(),
                            password: _passwordCtrl.text,
                            data: {
                              'name': _nameCtrl.text.trim(),
                              'phone': _phoneCtrl.text.trim(),
                            },
                          );
                          if (response.user != null) {
                            final user = response.user!;
                            await Supabase.instance.client
                                .from('profiles')
                                .insert({
                              'id': user.id,
                              'name': _nameCtrl.text.trim(),
                              'surname': _surnameCtrl.text.trim(),
                              'company_name': _companyNameCtrl.text.trim(),
                              'email': _emailCtrl.text.trim(),
                              'phone': _phoneCtrl.text.trim(),
                              'address': _addressCtrl.text.trim(),
                            });
                            if (context.mounted) {
                              Widgets.customSnackbar(context,
                                  AppColors.blueGrey, 'Signup Successful!');
                              Navigator.pop(context);
                            }
                          } else {
                            if (context.mounted) {
                              Widgets.customSnackbar(context, AppColors.red,
                                  'Signup failed. Try again.');
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
                                'Signup failed: ${e.toString()}');
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
                    //       final credential = await FirebaseAuth.instance
                    //           .createUserWithEmailAndPassword(
                    //         email: _emailCtrl.text.trim(),
                    //         password: _passwordCtrl.text,
                    //       );
                    //       Widgets.customSnackbar(context, AppColors.blueGrey.withValues(alpha: 0.6),
                    //           'User Register Successful');
                    //       Navigator.pop(context);
                    //     } on FirebaseAuthException catch (e) {
                    //       String message = 'Signup failed';
                    //       if (e.code == 'email-already-in-use') {
                    //         message = 'Email is already in use.';
                    //       } else if (e.code == 'invalid-email') {
                    //         message = 'Invalid email address.';
                    //       } else if (e.code == 'weak-password') {
                    //         message = 'Password is too weak.';
                    //       }
                    //       Widgets.customSnackbar(
                    //           context, AppColors.red, message);
                    //     } finally {
                    //       setState(() => _isLoading = false);
                    //     }
                    //   }
                    // },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.blueGrey.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Sign Up",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: AppTextStyle(fontSize: 13.sp)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text("Sign In",
                        style: AppTextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    final keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyle(fontSize: 14.sp),
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) return '$label is required';
            return null;
          },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyle(fontSize: 12.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        filled: true,
        fillColor: AppColors.scaffoldBackgroundColor,
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTextStyle(fontSize: 14.sp),
      obscureText: obscure,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) return '$label is required';
            if (value.length < 6) return 'Minimum 6 characters required';
            return null;
          },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyle(fontSize: 12.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        filled: true,
        fillColor: AppColors.scaffoldBackgroundColor,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.white,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
