import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'constants/app_constants.dart';
import 'services/api_service.dart';
import 'services/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authService = AuthService(prefs, apiService);
  final authProvider = AuthProvider(authService: authService);
  await authProvider.init();

  if (authProvider.isLoggedIn) {
    final token = authService.getToken();
    if (token != null) {
      apiService.setAuthToken(token);
    }
  }
  
  final serviceProvider = ServiceProvider(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        Provider.value(value: serviceProvider),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          secondary: AppConstants.accentColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: AppConstants.accentColor),
          titleTextStyle: TextStyle(
            color: AppConstants.accentColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppConstants.defaultBorderRadius,
            ),
            elevation: AppConstants.buttonElevation,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: AppConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: AppConstants.defaultBorderRadius,
          ),
        ),
      ),
      initialRoute: auth.isLoggedIn ? Routes.root : Routes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}