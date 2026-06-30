import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/ir_service.dart';
import '../services/ad_service.dart';
import '../models/brand_model.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});
  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _bannerReady = false;
  int _pressCount = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = AdService.createBannerAd();
    _bannerAd!.load().then((_) => setState(() => _bannerReady = true));
  }

  Future<void> _sendCode(String? code) async {
    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signal not available for this button'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 800),
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    final codes = context.read<RemoteAppState>().irCodes;
    if (codes == null) return;
    final pattern = codes.parseIrCode(code);
    await IrService.sendIrCode(pattern);
    _pressCount++;
    if (_pressCount % 20 == 0) AdService.showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RemoteAppState>();
    final brand = appState.selectedBrand;
    final codes = appState.irCodes;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(brand),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildPowerMuteRow(codes),
                    const SizedBox(height: 16),
                    _buildMainRemoteCard(codes),
                    const SizedBox(height: 16),
                    _buildBottomRow(codes),
                    const SizedBox(height: 16),
                    _buildNumberPad(codes),
                    const SizedBox(height: 16),
                    _buildChannelProgramRow(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (_bannerReady && _bannerAd != null)
              Container(
                height: _bannerAd!.size.height.toDouble(),
                color: Colors.white,
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ──
  Widget _buildTopBar(BrandModel? brand) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16,
                  color: Color(0xFF1A1A2E)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand?.name ?? 'TV Remote',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    )),
                const Text('Universal Remote',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          // WiFi icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wifi_rounded, size: 18,
                color: Color(0xFF4DB6E8)),
          ),
          const SizedBox(width: 8),
          // Settings icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grid_view_rounded, size: 18,
                color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
    );
  }

  // ── Power + Mute Row ──
  Widget _buildPowerMuteRow(IrCodeModel? codes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _topIconBtn(Icons.power_settings_new, const Color(0xFFFF6B6B),
            const Color(0xFFFFEEEE), () => _sendCode(codes?.power)),
        // Vol & Chan labels row
        Row(
          children: [
            _volChanPill('VOL', codes?.volUp, codes?.volDown),
            const SizedBox(width: 10),
            _volChanPill('CH', codes?.chanUp, codes?.chanDown),
          ],
        ),
        _topIconBtn(Icons.volume_off_rounded, const Color(0xFF4DB6E8),
            const Color(0xFFE8F6FD), () => _sendCode(codes?.mute)),
      ],
    );
  }

  Widget _topIconBtn(IconData icon, Color iconColor, Color bgColor,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _volChanPill(String label, String? upCode, String? downCode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _sendCode(downCode),
            child: const Icon(Icons.remove, size: 16, color: Color(0xFF9E9E9E)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E))),
          ),
          GestureDetector(
            onTap: () => _sendCode(upCode),
            child: const Icon(Icons.add, size: 16, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  // ── Main Remote Card (Nav pad) ──
  Widget _buildMainRemoteCard(IrCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Up arrow
          _arrowBtn(Icons.keyboard_arrow_up_rounded,
              () => _sendCode(codes?.up)),
          const SizedBox(height: 8),
          // Left - DPad circle - Right
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _arrowBtn(Icons.keyboard_arrow_left_rounded,
                  () => _sendCode(codes?.left)),
              const SizedBox(width: 8),
              _dPadCenter(codes),
              const SizedBox(width: 8),
              _arrowBtn(Icons.keyboard_arrow_right_rounded,
                  () => _sendCode(codes?.right)),
            ],
          ),
          const SizedBox(height: 8),
          // Down arrow
          _arrowBtn(Icons.keyboard_arrow_down_rounded,
              () => _sendCode(codes?.down)),
          const SizedBox(height: 20),
          // Action row below nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallActionBtn(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  onTap: () => _sendCode(codes?.menu)),
              _smallActionBtn(
                  icon: Icons.arrow_back_rounded,
                  label: 'Return',
                  onTap: () => _sendCode(codes?.back)),
              _smallActionBtn(
                  icon: Icons.more_horiz_rounded,
                  label: '—',
                  onTap: () => _sendCode(null)),
              _smallActionBtn(
                  icon: Icons.replay_rounded,
                  label: 'Back',
                  onTap: () => _sendCode(codes?.back)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 26, color: const Color(0xFF555555)),
      ),
    );
  }

  Widget _dPadCenter(IrCodeModel? codes) {
    return GestureDetector(
      onTap: () => _sendCode(codes?.ok),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5BC8F5), Color(0xFF2196F3)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: const Center(
          child: Text('OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 1,
              )),
        ),
      ),
    );
  }

  Widget _smallActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF555555)),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  // ── Bottom row: 3D Mode, Mic, Keyboard ──
  Widget _buildBottomRow(IrCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomFeatureBtn(Icons.threed_rotation, '3D Mode',
              () => _sendCode(null)),
          Container(width: 1, height: 30,
              color: const Color(0xFFEEEEEE)),
          _bottomFeatureBtn(Icons.mic_rounded, 'Voice',
              () => _sendCode(null)),
          Container(width: 1, height: 30,
              color: const Color(0xFFEEEEEE)),
          _bottomFeatureBtn(Icons.keyboard_rounded, 'Keyboard',
              () => _sendCode(null)),
        ],
      ),
    );
  }

  Widget _bottomFeatureBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4DB6E8)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 12,
                  color: Color(0xFF555555), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Number Pad ──
  Widget _buildNumberPad(IrCodeModel? codes) {
    final nums = [
      ['1', codes?.num1], ['2', codes?.num2], ['3', codes?.num3],
      ['4', codes?.num4], ['5', codes?.num5], ['6', codes?.num6],
      ['7', codes?.num7], ['8', codes?.num8], ['9', codes?.num9],
      ['', null],         ['0', codes?.num0], ['', null],
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12, offset: const Offset(0, 2))
        ],
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: nums.map((n) {
          if (n[0] == '') return const SizedBox();
          return GestureDetector(
            onTap: () => _sendCode(n[1]),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Center(
                child: Text(n[0]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Channel & Program List ──
  Widget _buildChannelProgramRow() {
    return Row(
      children: [
        Expanded(
          child: _listBtn('Channel List', Icons.list_alt_rounded,
              const Color(0xFF4DB6E8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _listBtn('Program List', Icons.video_library_rounded,
              const Color(0xFF7C4DFF)),
        ),
      ],
    );
  }

  Widget _listBtn(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _tabController.dispose();
    super.dispose();
  }
}