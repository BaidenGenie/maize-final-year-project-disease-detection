import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/navigation.dart';
import 'features/splash/presentation/pages/splash_page.dart';

// Providers
import 'core/providers/auth_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/disease_detection_provider.dart';
import 'core/providers/farm_records_provider.dart';
import 'core/providers/marketplace_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/store_locator_provider.dart';
import 'features/language/presentation/providers/language_provider.dart';
import 'features/crop_doctor/provider/crop_diagnosis_provider.dart';
import 'features/marketplace/presentation/providers/translation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartFarmGhanaApp());
}

class SmartFarmGhanaApp extends StatelessWidget {
  const SmartFarmGhanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
            ChangeNotifierProvider(create: (_) => DiseaseDetectionProvider()),
            ChangeNotifierProvider(create: (_) => FarmRecordsProvider()),
            ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
            ChangeNotifierProvider(create: (_) => TranslationProvider()),
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            ChangeNotifierProvider(create: (_) => StoreLocatorProvider()),
            ChangeNotifierProvider(create: (_) => CropDiagnosisProvider()),
          ],
          child: Consumer2<LanguageProvider, TranslationProvider>(
            builder: (context, languageProvider, translationProvider, child) {
              // Sync language between providers
              if (translationProvider.currentLanguage != languageProvider.currentLanguageName) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  translationProvider.setLanguage(languageProvider.currentLanguageName);
                });
              }

              return MaterialApp(
                title: 'Go Agro',
                navigatorKey: Navigation.navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.green,
                  primaryColor: AppColors.primary,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    brightness: Brightness.light,
                  ),
                  useMaterial3: true,
                ),
                locale: languageProvider.currentLocale,
                home: const SplashScreen(),
              );
            },
          ),
        );
      },
    );
  }
}