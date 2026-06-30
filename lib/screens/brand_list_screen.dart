import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/brand_model.dart';
import '../services/ir_service.dart';
import '../services/ad_service.dart';
import 'remote_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class BrandListScreen extends StatefulWidget {
  const BrandListScreen({super.key});
  @override
  State<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends State<BrandListScreen> {
  List<BrandModel> _brands = [];
  List<BrandModel> _filtered = [];
  bool _loading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  BannerAd? _bannerAd;
  bool _bannerReady = false;

  // Brand accent colors
  final List<Color> _colors = [
    const Color(0xFF4DB6E8),
    const Color(0xFF7C4DFF),
    const Color(0xFFFF6B6B),
    const Color(0xFF43B97F),
    const Color(0xFFFF8C42),
    const Color(0xFF2196F3),
  ];

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadBanner();
  }

  Future<void> _loadBrands() async {
    final brands = await IrService.loadBrands();
    setState(() { _brands = brands; _filtered = brands; _loading = false; });
  }

  void _loadBanner() {
    _bannerAd = AdService.createBannerAd();
    _bannerAd!.load().then((_) => setState(() => _bannerReady = true));
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? _brands
          : _brands.where((b) =>
              b.name.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  Future<void> _selectBrand(BrandModel brand) async {
    final codes = await IrService.loadIrCodes(brand.fileIndex);
    if (codes == null) return;
    context.read<RemoteAppState>().setBrand(brand, codes);
    AdService.showInterstitialAd();
    if (mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RemoteScreen()));
    }
  }

  Color _colorFor(String name) => _colors[name.length % _colors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F6FD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tv_rounded, size: 20,
                            color: Color(0xFF4DB6E8)),
                      ),
                      const SizedBox(width: 10),
                      const Text('Select Your TV',
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          )),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _search,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        hintText: 'Search brand (LG, Sony, Samsung...)',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFF9E9E9E), size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Brand count chip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F6FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${_filtered.length} brands',
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: Color(0xFF4DB6E8),
                        )),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4DB6E8)))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 60,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text('Brand not found',
                                  style: TextStyle(
                                      color: Color(0xFF9E9E9E), fontSize: 14)),
                            ],
                          ))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final brand = _filtered[i];
                            final color = _colorFor(brand.name);
                            return GestureDetector(
                              onTap: () => _selectBrand(brand),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46, height: 46,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          brand.name.substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(brand.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: Color(0xFF1A1A2E),
                                              )),
                                          const Text('Universal TV Remote',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF9E9E9E))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14, color: color),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Banner Ad
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

  @override
  void dispose() { _bannerAd?.dispose(); _searchCtrl.dispose(); super.dispose(); }
}