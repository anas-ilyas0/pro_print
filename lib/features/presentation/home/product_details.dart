import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/models/cart_model.dart';
import 'package:proprint/core/providers/cart_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:provider/provider.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String image = args?['image_url'] ?? '';
    final String name = args?['name'] ?? '';
    final String category = args?['category'] ?? '';
    final int quantity = args?['quantity'] ?? 0;
    final double price = args?['price'] ?? 0;
    final String prodDesc = args?['prodDesc'] ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              image,
              width: double.infinity,
              height: 300.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),
            Text(
              name,
              style: AppTextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),
            Text(
              "Category: $category",
              style: AppTextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              quantity == 0 || quantity == 1
                  ? "Available: $quantity piece"
                  : "Available: $quantity pieces",
              style: AppTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Product Description",
              style: AppTextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              prodDesc,
              style: AppTextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "€${price.toStringAsFixed(1)}",
                  style: AppTextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: () {
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      cartProvider.addItem(
                          CartItem(
                              id: name,
                              name: name,
                              image: image,
                              price: price,
                              stock: quantity,
                              description: prodDesc),
                          context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.blueGrey.withValues(alpha: 0.6),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: AppTextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
