import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/ac_model.dart';
import '../services/ad_service.dart';
import '../services/ir_service.dart';
import '../services/ac_protocols/haier_encoder.dart';

class AcRemoteScreen extends StatefulWidget {
  const AcRemoteScreen({super.key});
  @override
  State<AcRemoteScreen> createState() => _AcRemoteScreenState();
}

class _AcRemoteScreenState extends State<AcRemoteScreen> {
  BannerAd? _banner;
  bool _bannerReady = false;
  int _temp = 24;
  int _modeIndex = 0;
  int _fanIndex = 0;
  bool _swingOn = false;
  bool _isOn = true;

  final _modes = ['Cool', 'Heat', 'Fan', 'Dry', 'Auto'];
  final _modeIcons = [
    Icons.ac_unit_rounded,
    Icons.wb_sunny_rounded,
    Icons.air_rounded,
    Icons.water_drop_rounded,
    Icons.autorenew_rounded,
  ];
  final _fanSpeeds = ['Low', 'Medium', 'High', 'Auto'];

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _banner = AdService.createBannerAd();
    _banner!.load().then((_) {
      if (mounted) setState(() => _bannerReady = true);
    });
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
    final codes = context.read<RemoteAppState>().acCodes;
    if (codes == null) return;
    await IrService.sendIrCode(codes.parseIrCode(code));
  }

  bool get _isHaier =>
      context.read<RemoteAppState>().acCodes?.protocol == 'haier_hsu07';

  // Map this screen's UI mode/fan order to the Haier protocol's native values.
  int get _haierMode {
    switch (_modes[_modeIndex]) {
      case 'Cool':
        return HaierEncoder.modeCool;
      case 'Heat':
        return HaierEncoder.modeHeat;
      case 'Fan':
        return HaierEncoder.modeFan;
      case 'Dry':
        return HaierEncoder.modeDry;
      default:
        return HaierEncoder.modeAuto;
    }
  }

  int get _haierFan {
    switch (_fanSpeeds[_fanIndex]) {
      case 'Low':
        return HaierEncoder.fanLow;
      case 'Medium':
        return HaierEncoder.fanMed;
      case 'High':
        return HaierEncoder.fanHigh;
      default:
        return HaierEncoder.fanAuto;
    }
  }

  Future<void> _sendHaier(int command) async {
    HapticFeedback.lightImpact();
    final pattern = HaierEncoder.build(
      command: command,
      tempC: _temp,
      mode: _haierMode,
      fan: _haierFan,
      swingV: _swingOn ? HaierEncoder.swingChange : HaierEncoder.swingOff,
    );
    await IrService.sendIrCode(pattern);
  }

  void _goBack() {
    AdService.showInterstitialOnTransition(() {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RemoteAppState>();
    final brand = appState.selectedBrand;
    final codes = appState.acCodes;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      body: SafeArea(
        child: Column(children: [
          _topBar(brand?.name),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const SizedBox(height: 12),
                _powerButton(codes),
                const SizedBox(height: 20),
                _tempCard(codes),
                const SizedBox(height: 14),
                _modeCard(codes),
                const SizedBox(height: 14),
                _fanCard(codes),
                const SizedBox(height: 14),
                _swingCard(codes),
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

  Widget _topBar(String? brandName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: _goBack,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFFF2F5F9), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1A1A2E)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(brandName ?? 'AC Remote',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A1A2E))),
            const Text('AC Control', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ]),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: const Color(0xFFF2F5F9), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.ac_unit_rounded, size: 18, color: Color(0xFF2FB6A8)),
        ),
      ]),
    );
  }

  Widget _powerButton(AcCodeModel? codes) {
    return GestureDetector(
      onTap: () {
        if (_isHaier) {
          setState(() => _isOn = !_isOn);
          _sendHaier(_isOn ? HaierEncoder.cmdOn : HaierEncoder.cmdOff);
        } else {
          _send(codes?.power);
        }
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF7A7A), Color(0xFFE63946)]),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFE63946).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: const Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _tempCard(AcCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _tempStepBtn(Icons.remove_rounded, () {
          setState(() => _temp = (_temp - 1).clamp(16, 30));
          if (_isHaier) {
            _sendHaier(HaierEncoder.cmdTempDown);
          } else {
            _send(codes?.tempDown);
          }
        }),
        Column(children: [
          Text('$_temp°',
              style: const TextStyle(
                  fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
          const Text('Temperature', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ]),
        _tempStepBtn(Icons.add_rounded, () {
          setState(() => _temp = (_temp + 1).clamp(16, 30));
          if (_isHaier) {
            _sendHaier(HaierEncoder.cmdTempUp);
          } else {
            _send(codes?.tempUp);
          }
        }),
      ]),
    );
  }

  Widget _tempStepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6FD0F7), Color(0xFF3AA8EE)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF3AA8EE).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _modeCard(AcCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mode',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() => _modeIndex = (_modeIndex + 1) % _modes.length);
            if (_isHaier) {
              _sendHaier(HaierEncoder.cmdMode);
            } else {
              _send(codes?.mode);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F6FD), borderRadius: BorderRadius.circular(12)),
              child: Icon(_modeIcons[_modeIndex], color: const Color(0xFF4DB6E8), size: 22),
            ),
            const SizedBox(width: 12),
            Text(_modes[_modeIndex],
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            const Spacer(),
            const Icon(Icons.swap_horiz_rounded, color: Color(0xFF9E9E9E), size: 20),
          ]),
        ),
      ]),
    );
  }

  Widget _fanCard(AcCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Fan Speed',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() => _fanIndex = (_fanIndex + 1) % _fanSpeeds.length);
            if (_isHaier) {
              _sendHaier(HaierEncoder.cmdFan);
            } else {
              _send(codes?.fanSpeed);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.air_rounded, color: Color(0xFF43B97F), size: 22),
            ),
            const SizedBox(width: 12),
            Text(_fanSpeeds[_fanIndex],
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            const Spacer(),
            const Icon(Icons.swap_horiz_rounded, color: Color(0xFF9E9E9E), size: 20),
          ]),
        ),
      ]),
    );
  }

  Widget _swingCard(AcCodeModel? codes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: SwitchListTile(
        value: _swingOn,
        onChanged: (v) {
          setState(() => _swingOn = v);
          if (_isHaier) {
            _sendHaier(HaierEncoder.cmdSwing);
          } else {
            _send(codes?.swing);
          }
        },
        activeColor: const Color(0xFF4DB6E8),
        title: const Text('Swing',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        secondary: const Icon(Icons.swap_vert_rounded, color: Color(0xFF7C4DFF)),
      ),
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }
}
