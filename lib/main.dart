import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/ad_service.dart';
import 'models/brand_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await AdService.initialize();
  await AdService.loadInterstitialAd();
  runApp(const MyApp());
}

class RemoteAppState extends ChangeNotifier {
  BrandModel? selectedBrand;
  IrCodeModel? irCodes;
  bool hasIr = false;

  void setBrand(BrandModel brand, IrCodeModel codes) {
    selectedBrand = brand;
    irCodes = codes;
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
    return ChangeNotifierProvider(
      create: (_) => RemoteAppState(),
      child: MaterialApp(
        title: 'Universal TV Remote',
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
      ),
    );
  }
}