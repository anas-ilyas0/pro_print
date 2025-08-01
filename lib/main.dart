import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/constants/app_constants.dart';
import 'package:proprint/core/providers/cart_provider.dart';
import 'package:proprint/core/providers/category_provider.dart';
import 'package:proprint/core/providers/dashboard_provider.dart';
import 'package:proprint/core/providers/product_provider.dart';
import 'package:proprint/core/providers/username_provider.dart';
import 'package:proprint/core/routes/app_routes.dart';
import 'package:proprint/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://asjlaybldlzzdyxevxty.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzamxheWJsZGx6emR5eGV2eHR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3NDk3MDUsImV4cCI6MjA2NzMyNTcwNX0.IcVutv9IJSLe-i4a12U2jKMMAOrYJxelp7mBqsVeQCc',
    );
    print('✅ Supabase initialized');
  } catch (e) {
    print('❌ Supabase init error: $e');
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  final user = Supabase.instance.client.auth.currentUser;

  runApp(MyApp(
    initialRoute: (isLoggedIn && user != null)
        ? AppConstants.dashboard
        : AppConstants.login,
  ));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({required this.initialRoute, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ScreenUtilInit(
        designSize: const Size(AppConstants.screenW, AppConstants.screenH),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DashboardProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => UserNameProvider()),
              ChangeNotifierProvider(create: (_) => CategoryProvider()),
              ChangeNotifierProvider(create: (_) => ProductProvider()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.theme,
              initialRoute: widget.initialRoute,
              routes: AppRoutes.getRoutes(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
