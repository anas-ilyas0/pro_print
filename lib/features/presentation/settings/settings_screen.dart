import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/providers/dashboard_provider.dart';
import 'package:proprint/core/providers/username_provider.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/theme/app_text_style.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.white),
        );
      },
    );
    try {
      await Supabase.instance.client.auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userEmail');
      await Future.delayed(Duration(milliseconds: 1000));
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.login,
          (route) => false,
        );
        Widgets.customSnackbar(
            context, AppColors.blueGrey, 'Logout Successful');
        Provider.of<UserNameProvider>(context, listen: false).clearUserData();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        Widgets.customSnackbar(
            context, AppColors.red, 'Logout failed. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = (
      dashboard: Provider.of<DashboardProvider>(context),
      userName: Provider.of<UserNameProvider>(context),
    );
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.blueGrey
                      .withValues(alpha: 0.6)
                      .withValues(alpha: 0.1),
                  child:
                      Icon(Icons.person, color: AppColors.white, size: 30.sp),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome,', style: AppTextStyle(fontSize: 14.sp)),
                    Text(providers.userName.name,
                        style: AppTextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30.h),
            buildSettingItem(Icons.dashboard, 'Dashboard', onTap: () {
              providers.dashboard.setSelectedIndex(0);
            }),
            buildSettingItem(Icons.person, 'My Cart', onTap: () {
              providers.dashboard.setSelectedIndex(1);
            }),
            buildSettingItem(Icons.history, 'Order History', onTap: () async {
              Navigator.pushNamed(context, AppConstants.orderHistory);
            }),
            buildSettingItem(
              Icons.logout,
              'Logout',
              color: Colors.red,
              onTap: () async {
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
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.white),
                      ),
                    );
                    await logout(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingItem(IconData icon, String title,
      {VoidCallback? onTap, Color? color}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color ?? AppColors.white),
          title: Text(title,
              style: AppTextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              )),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 16.sp, color: Colors.white),
          onTap: onTap,
        ),
        Divider(height: 1.h, color: Colors.grey.shade300),
      ],
    );
  }
}
