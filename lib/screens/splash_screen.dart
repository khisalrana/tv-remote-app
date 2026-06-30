import 'package:flutter/material.dart';
import '../services/ir_service.dart';
import 'brand_list_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    final hasIr = await IrService.hasIrBlaster();
    context.read<RemoteAppState>().setHasIr(hasIr);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const BrandListScreen()));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

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
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6FD),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DB6E8).withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(Icons.tv_rounded, size: 56,
                      color: Color(0xFF4DB6E8)),
                ),
                const SizedBox(height: 28),
                const Text('Universal TV Remote',
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    )),
                const SizedBox(height: 6),
                const Text('Control any TV with ease',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 48),
                SizedBox(
                  width: 36, height: 36,
                  child: CircularProgressIndicator(
                    color: const Color(0xFF4DB6E8),
                    strokeWidth: 2.5,
                    backgroundColor: const Color(0xFF4DB6E8).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}