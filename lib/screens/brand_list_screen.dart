import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/brand_model.dart';
import '../services/ad_service.dart';
import '../services/ir_service.dart';
import 'remote_screen.dart';
import 'ac_remote_screen.dart';

class BrandListScreen extends StatefulWidget {
  final DeviceCategory category;
  const BrandListScreen({super.key, required this.category});
  @override
  State<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends State<BrandListScreen> {
  List<BrandModel> _all = [], _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();
  BannerAd? _banner;
  bool _bannerReady = false;

  bool get _isTv => widget.category == DeviceCategory.tv;

  final _colors = [
    const Color(0xFF4DB6E8), const Color(0xFF7C4DFF),
    const Color(0xFFFF6B6B), const Color(0xFF43B97F),
    const Color(0xFFFF8C42), const Color(0xFF2196F3),
  ];

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadBanner();
  }

  Future<void> _loadBrands() async {
    final brands = _isTv ? await IrService.loadBrands() : await IrService.loadAcBrands();
    if (mounted) setState(() { _all = brands; _filtered = brands; _loading = false; });
  }

  void _loadBanner() {
    _banner = AdService.createBannerAd();
    _banner!.load().then((_) { if (mounted) setState(() => _bannerReady = true); });
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = q.isEmpty ? _all
          : _all.where((b) => b.name.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  Future<void> _select(BrandModel brand) async {
    if (_isTv) {
      final codes = await IrService.loadIrCodes(brand.fileIndex);
      if (codes == null || !mounted) return;
      context.read<RemoteAppState>().setTvBrand(brand, codes);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RemoteScreen()));
    } else {
      final codes = await IrService.loadAcCodes(brand.fileIndex);
      if (codes == null || !mounted) return;
      context.read<RemoteAppState>().setAcBrand(brand, codes);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AcRemoteScreen()));
    }
  }

  Color _colorFor(String name) => _colors[name.isEmpty ? 0 : name.length % _colors.length];

  @override
  Widget build(BuildContext context) {
    final title = _isTv ? 'Select your TV brand' : 'Select your AC brand';
    final headerLabel = _isTv ? 'Univercel Remote' : 'AC Remote';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: const Color(0xFFF2F5F9),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1A2E)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6FD), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_isTv ? Icons.tv_rounded : Icons.ac_unit_rounded,
                      size: 22, color: const Color(0xFF4DB6E8)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(headerLabel,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                  Text(title,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                ]),
              ]),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F9), borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  controller: _search,
                  onChanged: _onSearch,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                  decoration: InputDecoration(
                    hintText: _isTv ? 'Search brand (LG, Sony, Samsung...)' : 'Search AC brand',
                    hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9E9E9E), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ]),
          ),

          // Count chip
          if (!_loading && _all.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6FD), borderRadius: BorderRadius.circular(20)),
                  child: Text('${_filtered.length} brands',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: Color(0xFF4DB6E8))),
                ),
              ]),
            ),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6E8)))
                : _all.isEmpty
                    ? _emptyState()
                    : _filtered.isEmpty
                        ? const Center(child: Text('Brand not found',
                            style: TextStyle(color: Color(0xFF9E9E9E))))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) {
                              final b = _filtered[i];
                              final c = _colorFor(b.name);
                              return GestureDetector(
                                onTap: () => _select(b),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 8, offset: const Offset(0, 2))],
                                  ),
                                  child: Row(children: [
                                    Container(
                                      width: 46, height: 46,
                                      decoration: BoxDecoration(
                                        color: c.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12)),
                                      child: Center(child: Text(
                                          b.name.isNotEmpty ? b.name.substring(0, 1).toUpperCase() : '?',
                                          style: TextStyle(color: c, fontSize: 20,
                                              fontWeight: FontWeight.w700))),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(b.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600,
                                                fontSize: 15, color: Color(0xFF1A1A2E))),
                                        const Text('Tap to control',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                                      ],
                                    )),
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: c.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.arrow_forward_ios_rounded,
                                          size: 14, color: c),
                                    ),
                                  ]),
                                ),
                              );
                            }),
          ),

          // Banner Ad
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

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.hourglass_top_rounded, size: 48, color: Color(0xFFBBBBBB)),
          const SizedBox(height: 16),
          const Text('AC brands coming soon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          const Text('We\'re adding verified AC brand codes in an upcoming update.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        ]),
      ),
    );
  }

  @override
  void dispose() { _banner?.dispose(); _search.dispose(); super.dispose(); }
}
