import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/brand_model.dart';
import 'models/ac_model.dart';
import 'screens/splash_screen.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await AdService.initialize();
  await AdService.loadInterstitialAd();
  runApp(
    ChangeNotifierProvider(
      create: (_) => RemoteAppState(),
      child: const MyApp(),
    ),
  );
}

enum DeviceCategory { tv, ac }

class RemoteAppState extends ChangeNotifier {
  DeviceCategory? selectedCategory;
  BrandModel? selectedBrand;
  IrCodeModel? irCodes;
  AcCodeModel? acCodes;
  bool hasIr = false;

  void setTvBrand(BrandModel brand, IrCodeModel codes) {
    selectedCategory = DeviceCategory.tv;
    selectedBrand = brand;
    irCodes = codes;
    acCodes = null;
    notifyListeners();
  }

  void setAcBrand(BrandModel brand, AcCodeModel codes) {
    selectedCategory = DeviceCategory.ac;
    selectedBrand = brand;
    acCodes = codes;
    irCodes = null;
    notifyListeners();
  }

  void setHasIr(bool value) {
    hasIr = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Univercel Remote - TV Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6E8),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F5F9),
      ),
      home: const SplashScreen(),
    );
  }
}