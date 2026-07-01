import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/brand_model.dart';

class IrService {
  static const MethodChannel _channel = MethodChannel('com.clicktv.universalremote/ir');

  static Future<bool> hasIrBlaster() async {
    try {
      return await _channel.invokeMethod('hasIrBlaster') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> sendIrCode(List<int> pattern) async {
    if (pattern.isEmpty) return;
    try {
      await _channel.invokeMethod('transmit', {
        'frequency': 38000,
        'pattern': pattern,
      });
    } catch (_) {}
  }

  static Future<IrCodeModel?> loadIrCodes(int index) async {
    try {
      final data = await rootBundle.loadString('assets/ir_codes/$index.json');
      return IrCodeModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  static Future<List<BrandModel>> loadBrands() async {
    try {
      final data = await rootBundle.loadString('assets/brands/brand.json');
      final list = jsonDecode(data) as List;
      return list.asMap().entries
          .map((e) => BrandModel.fromJson(e.value, e.key))
          .toList();
    } catch (_) {
      return [];
    }
  }
}