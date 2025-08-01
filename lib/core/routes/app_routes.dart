import 'package:flutter/material.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/features/presentation/auth/forgot_password.dart';
import 'package:proprint/features/presentation/auth/login.dart';
import 'package:proprint/features/presentation/auth/reset_password.dart';
import 'package:proprint/features/presentation/auth/sign_up.dart';
import 'package:proprint/features/presentation/cart/checkOut.dart';
import 'package:proprint/features/presentation/dashboard/dashboard_screen.dart';
import 'package:proprint/features/presentation/home/add_category.dart';
import 'package:proprint/features/presentation/home/add_product.dart';
import 'package:proprint/features/presentation/home/product_details.dart';
import 'package:proprint/features/presentation/settings/order_history.dart';

class AppRoutes {
  static const String login = AppConstants.login;
  static const String signUp = AppConstants.signUp;
  static const String forgatPass = AppConstants.forgotPass;
  static const String resetPass = AppConstants.resetPass;
  static const String dashboard = AppConstants.dashboard;
  static const String addCategory = AppConstants.addCategory;
  static const String addProduct = AppConstants.addProduct;
  static const String productDetails = AppConstants.productDetails;
  static const String orderHistory = AppConstants.orderHistory;
  static const String checkOut = AppConstants.checkOut;

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const Login(),
      signUp: (context) => const SignUp(),
      forgatPass: (context) => const ForgotPassword(),
      resetPass: (context) => const ResetPassword(),
      dashboard: (context) => DashboardScreen(),
      addCategory: (context) => const AddCategory(),
      addProduct: (context) => const AddProduct(),
      productDetails: (context) => const ProductDetails(),
      orderHistory: (context) => const OrderHistory(),
      checkOut: (context) => CheckOut(),
    };
  }
}
