import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'invoice_preview_screen.dart';

final _formKey = GlobalKey<FormState>();

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  final vatController = TextEditingController();
  final billToController = TextEditingController();
  final shipToController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final telController = TextEditingController();

  @override
  void dispose() {
    vatController.dispose();
    billToController.dispose();
    shipToController.dispose();
    nameController.dispose();
    emailController.dispose();
    telController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Name',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Email',
                        controller: emailController,
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
                      _buildTextField(
                        label: 'Telephone',
                        controller: telController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Telephone is required';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'VAT Reg. No',
                        controller: vatController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'VAT Reg. No is required';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Bill To',
                        controller: billToController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bill To is required';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Ship To',
                        controller: shipToController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ship To is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueGrey.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoicePreviewScreen(
                          vatRegNo: vatController.text,
                          billTo: billToController.text,
                          shipTo: shipToController.text,
                          name: nameController.text,
                          email: emailController.text,
                          telNo: telController.text,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Check Out',
                  style: AppTextStyle(color: AppColors.white, fontSize: 16.sp),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    final keyboardType = TextInputType.text,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) return '$label is required';
              return null;
            },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: AppTextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyle(
            fontSize: 12.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          filled: true,
          fillColor: AppColors.scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
