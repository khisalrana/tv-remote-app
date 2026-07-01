import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/brand_model.dart';
import '../services/ad_service.dart';
import '../services/ir_service.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});
  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  BannerAd? _banner;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _banner = AdService.createBannerAd();
    _banner!.load().then((_) { if (mounted) setState(() => _bannerReady = true); });
  }

  Future<void> _send(String? code) async {
    if (code == null || code.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Signal not available'),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(milliseconds: 700),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
      return;
    }
    HapticFeedback.lightImpact();
    final codes = context.read<RemoteAppState>().irCodes;
    if (codes == null) return;
    await IrService.sendIrCode(codes.parseIrCode(code));
  }

  void _goBack() {
    // Show the interstitial (if ready) only here — a natural stopping point
    // where the user is done controlling this TV — never mid-button-press.
    AdService.showInterstitialOnTransition(() {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RemoteAppState>();
    final brand = appState.selectedBrand;
    final codes = appState.irCodes;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      body: SafeArea(
        child: Column(children: [
          _topBar(brand),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const SizedBox(height: 8),
                _powerRow(codes),
                const SizedBox(height: 14),
                _navCard(codes),
                const SizedBox(height: 14),
                _volChanRow(codes),
                const SizedBox(height: 14),
                _numPad(codes),
                const SizedBox(height: 14),
                _mediaRow(codes),
                const SizedBox(height: 14),
                _colorRow(codes),
                const SizedBox(height: 14),
                _bottomRow(codes),
                const SizedBox(height: 8),
              ]),
            ),
          ),
          if (_bannerReady && _banner != null)
            Container(
              height: _banner!.size.height.toDouble(),
              color: Colors.white,
              child: AdWidget(ad: _banner!),
            ),
        ]),
      ),
    );
  }

  // ── Top Bar ──
  Widget _topBar(BrandModel? brand) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
      child: Row(children: [
        GestureDetector(
          onTap: _goBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF2F5F9),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1A1A2E)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(brand?.name ?? 'TV Remote',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16,
                  color: Color(0xFF1A1A2E))),
          const Text('Univercel Remote', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFFF2F5F9),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.wifi_rounded, size: 18, color: Color(0xFF4DB6E8))),
      ]),
    );
  }

  // ── Power + Mute ──
  Widget _powerRow(IrCodeModel? codes) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _powerBtn(() => _send(codes?.power)),
      _iconBtn(Icons.volume_off_rounded, 'Mute',
          const Color(0xFF4DB6E8), const Color(0xFFE8F6FD),
          () => _send(codes?.mute)),
      _iconBtn(Icons.info_outline_rounded, 'Info',
          const Color(0xFF7C4DFF), const Color(0xFFEEEDFE),
          () => _send(codes?.info)),
      _iconBtn(Icons.menu_book_rounded, 'Guide',
          const Color(0xFF43B97F), const Color(0xFFEAF3DE),
          () => _send(codes?.guide)),
    ]);
  }

  Widget _powerBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFFF7A7A), Color(0xFFE63946)]),
            boxShadow: [BoxShadow(color: const Color(0xFFE63946).withValues(alpha: 0.35),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 4),
        const Text('Power', style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, String label, Color c, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: c.withValues(alpha: 0.2),
                blurRadius: 8, offset: const Offset(0, 3))]),
          child: Icon(icon, color: c, size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
      ]),
    );
  }

  // ── Navigation D-Pad ──
  Widget _navCard(IrCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20, offset: const Offset(0, 4))]),
      child: Column(children: [
        _arrowBtn(Icons.keyboard_arrow_up_rounded, () => _send(codes?.up)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _arrowBtn(Icons.keyboard_arrow_left_rounded, () => _send(codes?.left)),
          const SizedBox(width: 8),
          _okBtn(() => _send(codes?.ok)),
          const SizedBox(width: 8),
          _arrowBtn(Icons.keyboard_arrow_right_rounded, () => _send(codes?.right)),
        ]),
        const SizedBox(height: 6),
        _arrowBtn(Icons.keyboard_arrow_down_rounded, () => _send(codes?.down)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _smallBtn(Icons.arrow_back_rounded, 'Back', () => _send(codes?.back)),
          _smallBtn(Icons.format_list_bulleted_rounded, 'Ch. List', () => _send(codes?.chlist)),
          _smallBtn(Icons.menu_rounded, 'Menu', () => _send(codes?.menu)),
          _smallBtn(Icons.exit_to_app_rounded, 'Exit', () => _send(codes?.exit)),
        ]),
      ]),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF6FD0F7), Color(0xFF3AA8EE)]),
          boxShadow: [BoxShadow(color: const Color(0xFF3AA8EE).withValues(alpha: 0.28),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _okBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF5BC8F5), Color(0xFF2196F3)]),
          boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withValues(alpha: 0.35),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: const Center(child: Text('OK',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                fontSize: 18, letterSpacing: 1))),
      ),
    );
  }

  Widget _smallBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: const Color(0xFFF2F5F9),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: const Color(0xFF555555)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
      ]),
    );
  }

  // ── Vol + Chan ──
  Widget _volChanRow(IrCodeModel? codes) {
    return Row(children: [
      Expanded(child: _volChan('Volume', Icons.volume_up,
          () => _send(codes?.volUp), () => _send(codes?.volDown))),
      const SizedBox(width: 12),
      Expanded(child: _volChan('Channel', Icons.live_tv,
          () => _send(codes?.chanUp), () => _send(codes?.chanDown))),
    ]);
  }

  Widget _volChan(String label, IconData icon, VoidCallback onUp, VoidCallback onDown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(onTap: onDown,
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF2F5F9),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.remove, size: 18, color: Color(0xFF555555)))),
        Column(children: [
          Icon(icon, size: 16, color: const Color(0xFF4DB6E8)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E))),
        ]),
        GestureDetector(onTap: onUp,
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF2F5F9),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add, size: 18, color: Color(0xFF555555)))),
      ]),
    );
  }

  // ── Number entry (uses the phone's own keyboard) ──
  Widget _numPad(IrCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 2))]),
      child: GestureDetector(
        onTap: () => _openNumberEntry(codes),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dialpad_rounded, color: Color(0xFF4DB6E8), size: 20),
            const SizedBox(width: 10),
            const Text('Enter Channel Number',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          ],
        ),
      ),
    );
  }

  String? _codeForDigit(IrCodeModel codes, String digit) {
    switch (digit) {
      case '0': return codes.num0;
      case '1': return codes.num1;
      case '2': return codes.num2;
      case '3': return codes.num3;
      case '4': return codes.num4;
      case '5': return codes.num5;
      case '6': return codes.num6;
      case '7': return codes.num7;
      case '8': return codes.num8;
      case '9': return codes.num9;
      default: return null;
    }
  }

  Future<void> _openNumberEntry(IrCodeModel? codes) async {
    if (codes == null) return;
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type a channel number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            const Text('Each digit is sent to the TV as you type it.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 22, letterSpacing: 4),
              decoration: InputDecoration(
                hintText: '000',
                filled: true,
                fillColor: const Color(0xFFF2F5F9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                if (value.isEmpty) return;
                final digit = value[value.length - 1];
                _send(_codeForDigit(codes, digit));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Media Controls ──
  Widget _mediaRow(IrCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _mediaBtn(Icons.skip_previous_rounded, () => _send(codes?.rewind)),
        _mediaBtn(Icons.fast_rewind_rounded, () => _send(codes?.rewind)),
        _mediaBtn(Icons.play_arrow_rounded, () => _send(codes?.play), large: true),
        _mediaBtn(Icons.pause_rounded, () => _send(codes?.pause), large: true),
        _mediaBtn(Icons.fast_forward_rounded, () => _send(codes?.forward)),
        _mediaBtn(Icons.stop_rounded, () => _send(codes?.stop)),
      ]),
    );
  }

  Widget _mediaBtn(IconData icon, VoidCallback onTap, {bool large = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: large ? 50 : 38, height: large ? 50 : 38,
        decoration: BoxDecoration(
          color: large ? const Color(0xFF4DB6E8).withValues(alpha: 0.15)
              : const Color(0xFFF2F5F9),
          shape: BoxShape.circle,
          border: large ? Border.all(color: const Color(0xFF4DB6E8).withValues(alpha: 0.4)) : null,
        ),
        child: Icon(icon,
          color: large ? const Color(0xFF4DB6E8) : const Color(0xFF555555),
          size: large ? 26 : 20),
      ),
    );
  }

  // ── Color Buttons ──
  Widget _colorRow(IrCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _colorBtn(Colors.red, 'Red', () => _send(codes?.red)),
        _colorBtn(Colors.green, 'Green', () => _send(codes?.green)),
        _colorBtn(Colors.yellow, 'Yellow', () => _send(codes?.yellow)),
        _colorBtn(Colors.blue, 'Blue', () => _send(codes?.blue)),
      ]),
    );
  }

  Widget _colorBtn(Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(width: 60, height: 18,
            decoration: BoxDecoration(color: color,
                borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
      ]),
    );
  }

  // ── Bottom Row ──
  Widget _bottomRow(IrCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _featureBtn(Icons.threed_rotation, '3D Mode', () => _send(codes?.threeD)),
        Container(width: 1, height: 28, color: const Color(0xFFEEEEEE)),
        _featureBtn(Icons.bedtime_rounded, 'Sleep', () => _send(codes?.sleep)),
        Container(width: 1, height: 28, color: const Color(0xFFEEEEEE)),
        _featureBtn(Icons.dashboard_customize_rounded, 'Smart', () => _send(codes?.smart)),
      ]),
    );
  }

  Widget _featureBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF4DB6E8)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF555555),
            fontWeight: FontWeight.w500)),
      ]),
    );
  }

  @override
  void dispose() { _banner?.dispose(); super.dispose(); }
}