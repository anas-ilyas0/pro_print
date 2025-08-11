import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/constants/app_images.dart';
import 'package:proprint/core/models/cart_model.dart';
import 'package:proprint/core/providers/cart_provider.dart';
import 'package:proprint/core/providers/dashboard_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = (
      dashboard: Provider.of<DashboardProvider>(context),
      cart: Provider.of<CartProvider>(context),
    );
    return Scaffold(
      body: provider.cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      height: 200.h,
                      AppImages.emptyCart,
                      color: AppColors.blueGrey.withValues(alpha: 0.6),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Your cart is empty',
                      style: AppTextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Looks like you haven’t added anything to your cart yet.\nGo to the product page and explore items.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle(
                        fontSize: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.blueGrey.withValues(alpha: 0.6),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () {
                          provider.dashboard.setSelectedIndex(0);
                        },
                        child: Text(
                          'Add Products to Cart',
                          style: AppTextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.only(right: 6, left: 8, bottom: 0, top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.cart.items.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        CartItem item = provider.cart.items[index];
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: AppColors.white),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 8.h, right: 10.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 0, 0, 8),
                                                child: Container(
                                                  height: 100.h,
                                                  width: 100.w,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: NetworkImage(
                                                              item.image))),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            '€${item.price.toStringAsFixed(1)}')
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 24.h, left: 8.w),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  provider.cart
                                                      .decreaseQuantity(
                                                          item.id);
                                                },
                                                child: Container(
                                                    height: 20.h,
                                                    width: 20.w,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: AppColors
                                                                .black
                                                                .withValues(
                                                                    alpha:
                                                                        0.1)),
                                                        color: AppColors
                                                            .blueGrey
                                                            .withValues(
                                                                alpha: 0.6)
                                                            .withValues(
                                                                alpha: 0.2)),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 15,
                                                      ),
                                                    )),
                                              ),
                                              SizedBox(width: 5.w),
                                              Text(item.quantity.toString()),
                                              SizedBox(width: 5.w),
                                              GestureDetector(
                                                onTap: () {
                                                  provider.cart
                                                      .increaseQuantity(
                                                          item.id, context);
                                                },
                                                child: Container(
                                                    height: 20.h,
                                                    width: 20.w,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: AppColors
                                                                .black
                                                                .withValues(
                                                                    alpha:
                                                                        0.1)),
                                                        color: AppColors
                                                            .blueGrey
                                                            .withValues(
                                                                alpha: 0.6)
                                                            .withValues(
                                                                alpha: 0.2)),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 15,
                                                      ),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                    ),
                                    onPressed: () {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .removeItem(item.id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(
                      color: AppColors.blueGrey
                          .withValues(alpha: 0.6)
                          .withValues(alpha: 0.6)),
                  Consumer<CartProvider>(
                    builder: (context, cart, child) => Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '€${cart.totalAmount.toStringAsFixed(1)}',
                                style: AppTextStyle(fontSize: 18.sp),
                              ),
                              Text(
                                'Total',
                                style: AppTextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Divider(
                            color: AppColors.blueGrey
                                .withValues(alpha: 0.6)
                                .withValues(alpha: 0.6)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              backgroundColor:
                                  AppColors.blueGrey.withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppConstants.checkOut);
                            },
                            child: Text(
                              'Check Out',
                              style: AppTextStyle(
                                  fontSize: 16.sp, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h)
                ],
              ),
            ),
    );
  }
}
