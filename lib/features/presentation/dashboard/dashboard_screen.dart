import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/constants/app_images.dart';
import 'package:proprint/core/constants/app_strings.dart';
import 'package:proprint/core/providers/dashboard_provider.dart';
import 'package:proprint/core/providers/username_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:proprint/features/presentation/cart/cart_screen.dart';
import 'package:proprint/features/presentation/home/home_screen.dart';
import 'package:proprint/features/presentation/settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum BottomNavBarItem {
  home,
  cart,
  settings;

  String get icon => switch (this) {
        home => AppImages.home,
        cart => AppImages.cart,
        settings => AppImages.settings,
      };

  String get selectedIcon => switch (this) {
        home => AppImages.home,
        cart => AppImages.cart,
        settings => AppImages.settings,
      };

  String get label => switch (this) {
        home => AppStrings.home,
        cart => AppStrings.cart,
        settings => AppStrings.settings,
      };
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserNameProvider>(context, listen: false).fetchUserData();
  }

  final List<Widget> _screens = [
    HomeScreen(),
    const CartScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (!didPop) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.scaffoldBackgroundColor,
                  title: const Text('Logout'),
                  content: const Text('Are you sure you wants to logout?'),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  AppColors.blueGrey.withValues(alpha: 0.6))),
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle(
                                fontSize: 16.sp, color: AppColors.white),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(AppColors.red)),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Logout',
                            style: AppTextStyle(
                                fontSize: 16.sp, color: AppColors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
              if (confirm == true) {
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                );
                await Supabase.instance.client.auth.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('isLoggedIn');
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, AppConstants.login, (route) => false);
                Widgets.customSnackbar(
                    context, AppColors.blueGrey, 'Logout Successful');
                Provider.of<UserNameProvider>(context, listen: false)
                    .clearUserData();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: -40,
              leading: Text(''),
              title: Image.asset(
                height: 40.h,
                AppImages.proPrintLogo,
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    dashboardProvider.setSelectedIndex(1);
                  },
                  child: Image.asset(
                    height: 30.h,
                    AppImages.cart,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 15.w),
              ],
            ),
            body: _screens[dashboardProvider.selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: AppColors.scaffoldBackgroundColor,
              currentIndex: dashboardProvider.selectedIndex,
              onTap: (index) {
                dashboardProvider.setSelectedIndex(index);
              },
              selectedItemColor: AppColors.white,
              unselectedItemColor: AppColors.white,
              selectedLabelStyle:
                  AppTextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              unselectedLabelStyle:
                  AppTextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              type: BottomNavigationBarType.fixed,
              items: [
                for (var item in BottomNavBarItem.values)
                  _BottomNavBarItem(
                      dashboardProvider.selectedIndex == item.index, item),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavBarItem extends BottomNavigationBarItem {
  final bool selected;
  final BottomNavBarItem item;
  _BottomNavBarItem(this.selected, this.item)
      : super(
          icon: SizedBox(
            width: selected ? 26.r : 24.r,
            height: selected ? 26.r : 24.r,
            child: Image.asset(
              color: AppColors.white,
              selected ? item.selectedIcon : item.icon,
            ),
          ),
          label: item.label,
        );
}
