import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/ir_service.dart';
import 'brand_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    final hasIr = await IrService.hasIrBlaster();
    if (mounted) context.read<RemoteAppState>().setHasIr(hasIr);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const BrandListScreen()));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6FD),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DB6E8).withValues(alpha: 0.3),
                        blurRadius: 30, offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(Icons.tv_rounded, size: 64, color: Color(0xFF4DB6E8)),
                ),
                const SizedBox(height: 28),
                const Text('Univercel Remote',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 6),
                const Text('TV Controller',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 48),
                CircularProgressIndicator(
                  color: const Color(0xFF4DB6E8),
                  strokeWidth: 2.5,
                  backgroundColor: const Color(0xFF4DB6E8).withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}