import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/helpers/auth_helper.dart';
import 'package:proprint/core/models/cart_model.dart';
import 'package:proprint/core/providers/cart_provider.dart';
import 'package:proprint/core/providers/category_provider.dart';
import 'package:proprint/core/providers/product_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:proprint/features/presentation/home/add_category.dart';
import 'package:proprint/features/presentation/home/add_product.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      categoryProvider.fetchCategories();
      productProvider.fetchProducts();
    });
  }

  final supabase = Supabase.instance.client;
  void _showCategoryOptions(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      backgroundColor: AppColors.scaffoldBackgroundColor,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: AppColors.white,
            ),
            title: Text("Edit Category", style: AppTextStyle(fontSize: 16.sp)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCategory(category: category),
                ),
              );
            },
          ),
          ListTile(
              leading: const Icon(
                Icons.delete,
                color: AppColors.white,
              ),
              title:
                  Text("Delete Category", style: AppTextStyle(fontSize: 16.sp)),
              onTap: () async {
                try {
                  await Provider.of<CategoryProvider>(context, listen: false)
                      .deleteCategory(category.id, context);
                  if (context.mounted) {
                    Navigator.pop(context);
                    await Provider.of<CategoryProvider>(context, listen: false)
                        .fetchCategories();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Widgets.customSnackbar(
                        context, AppColors.red, 'Failed to delete category $e');
                  }
                }
              }),
        ],
      ),
    );
  }

  void _showProductOptions(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      backgroundColor: AppColors.scaffoldBackgroundColor,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: AppColors.white,
            ),
            title: Text(
              "Edit Product",
              style: AppTextStyle(fontSize: 16.sp),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProduct(product: product),
                ),
              );
            },
          ),
          ListTile(
              leading: const Icon(
                Icons.delete,
                color: AppColors.white,
              ),
              title:
                  Text("Delete Product", style: AppTextStyle(fontSize: 16.sp)),
              onTap: () async {
                try {
                  await Provider.of<ProductProvider>(context, listen: false)
                      .deleteProduct(product.id, context);
                  if (context.mounted) {
                    Navigator.pop(context);
                    await Provider.of<ProductProvider>(context, listen: false)
                        .fetchProducts();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Widgets.customSnackbar(
                        context, AppColors.red, 'Failed to delete product $e');
                  }
                }
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = (
      categoryProvider: Provider.of<CategoryProvider>(context),
      productProvider: Provider.of<ProductProvider>(context),
    );
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: AppColors.white,
        color: AppColors.blueGrey.withValues(alpha: 0.6),
        onRefresh: () async {
          await provider.categoryProvider.fetchCategories();
          await provider.productProvider.fetchProducts();
        },
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (val) =>
                    provider.productProvider.setSearchQuery(val),
                style: AppTextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: AppTextStyle(fontSize: 16.sp),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.white),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.white),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories',
                      style: AppTextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (provider.productProvider.selectedCategory == 'Products')
                    FutureBuilder<bool>(
                      future: AuthHelper.isAdmin(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppConstants.addCategory);
                            },
                            child:
                                Icon(Icons.add_circle, color: AppColors.white),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  // InkWell(
                  //     onTap: () {
                  //       Navigator.pushNamed(
                  //           context, AppConstants.addCategory);
                  //     },
                  //     child: Icon(Icons.add_circle, color: AppColors.white)),
                ],
              ),
              SizedBox(height: 10.h),
              provider.categoryProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: AppColors.white,
                    ))
                  : provider.categoryProvider.categories.isEmpty
                      ? const Center(child: Text('No category found'))
                      : SizedBox(
                          height: 100.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                provider.categoryProvider.categories.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              final category =
                                  provider.categoryProvider.categories[index];
                              final isSelected =
                                  provider.productProvider.selectedCategory ==
                                      category.name;
                              return GestureDetector(
                                onTap: () {
                                  provider.productProvider
                                      .setCategory(category.name);
                                },
                                onLongPress: () async {
                                  if (await AuthHelper.isAdmin()) {
                                    if (context.mounted) {
                                      _showCategoryOptions(context, category);
                                    }
                                  }
                                },
                                // onLongPress: () {
                                //   _showCategoryOptions(context, category);
                                // },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.blueGrey
                                                  .withValues(alpha: 0.6)
                                              : Colors.grey.shade300,
                                          width: 2.w,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(6.r),
                                      child: CircleAvatar(
                                        radius: 30.r,
                                        backgroundColor: Colors.grey.shade100,
                                        backgroundImage:
                                            NetworkImage(category.imageUrl),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      category.name,
                                      style: AppTextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(provider.productProvider.selectedCategory,
                      style: AppTextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (provider.productProvider.selectedCategory == 'Products')
                    FutureBuilder<bool>(
                      future: AuthHelper.isAdmin(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppConstants.addProduct);
                            },
                            child:
                                Icon(Icons.add_circle, color: AppColors.white),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  // InkWell(
                  //     onTap: () {
                  //       Navigator.pushNamed(context, AppConstants.addProduct);
                  //     },
                  //     child: Icon(Icons.add_circle, color: AppColors.white)),
                ],
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: provider.productProvider.isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: AppColors.white))
                    : provider.productProvider.filteredProducts.isEmpty
                        ? const Center(child: Text('No product found'))
                        : GridView.builder(
                            itemCount: provider
                                .productProvider.filteredProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) {
                              final product = provider
                                  .productProvider.filteredProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppConstants.productDetails,
                                      arguments: {
                                        'image_url': product.imageUrl,
                                        'name': product.name,
                                        'category': product.category,
                                        'quantity': product.quantity,
                                        'price': product.price,
                                        'prodDesc': product.prodDesc,
                                      });
                                },
                                onLongPress: () async {
                                  if (await AuthHelper.isAdmin()) {
                                    if (context.mounted) {
                                      _showProductOptions(context, product);
                                    }
                                  }
                                },
                                // onLongPress: () {
                                //   _showProductOptions(context, product);
                                // },
                                child: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 8,
                                        color: AppColors.black
                                            .withValues(alpha: 0.2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              child: Image.network(
                                                product.imageUrl,
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(Icons.error),
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                    color: AppColors.white,
                                                  ));
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              top: 8.r,
                                              left: 8.r,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: AppColors.blueGrey
                                                      .withValues(alpha: 0.6)
                                                      .withValues(alpha: 0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.r),
                                                ),
                                                child: Text(
                                                  "€${product.price.toStringAsFixed(2)}",
                                                  style: AppTextStyle(
                                                    fontSize: 12.sp,
                                                    color: AppColors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        product.name,
                                        style: AppTextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        product.quantity == 0 ||
                                                product.quantity == 1
                                            ? "${product.quantity} piece available"
                                            : "${product.quantity} pieces available",
                                        style: AppTextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: SizedBox(
                                          height: 35.h,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors
                                                  .blueGrey
                                                  .withValues(alpha: 0.6),
                                            ),
                                            onPressed: () {
                                              final cartProvider =
                                                  Provider.of<CartProvider>(
                                                      context,
                                                      listen: false);
                                              cartProvider.addItem(
                                                  CartItem(
                                                      id: product.name,
                                                      name: product.name,
                                                      image: product.imageUrl,
                                                      price: product.price,
                                                      stock: product.quantity,
                                                      description:
                                                          product.prodDesc),
                                                  context);
                                            },
                                            child: Text(
                                              'Add',
                                              style: AppTextStyle(
                                                  fontSize: 16.sp,
                                                  color: AppColors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
